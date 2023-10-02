/*   ==================================================================
     >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
     ------------------------------------------------------------------
     Copyright (c) 2006-2018 by Lattice Semiconductor Corporation
     ALL RIGHTS RESERVED
     ------------------------------------------------------------------

     IMPORTANT: THIS FILE IS AUTO-GENERATED BY LATTICE RADIANT Software.

     Permission:

        Lattice grants permission to use this code pursuant to the
        terms of the Lattice Corporation Open Source License Agreement.

     Disclaimer:

        Lattice provides no warranty regarding the use or functionality
        of this code. It is the user's responsibility to verify the
        user Software design for consistency and functionality through
        the use of formal Software validation methods.

     ------------------------------------------------------------------

     Lattice Semiconductor Corporation
     111 SW Fifth Avenue, Suite 700
     Portland, OR 97204
     U.S.A

     Email: techsupport@latticesemi.com
     Web: http://www.latticesemi.com/Home/Support/SubmitSupportTicket.aspx
     ================================================================== */

#include "i2c_master.h"
#include "i2c_master_regs.h"
#include "reg_access.h"
#include <stddef.h>

uint8_t i2c_master_init(struct i2cm_instance *this_i2cm,
			uint32_t base_addr)
{
	if (NULL == this_i2cm) {
        return 1;
	}

    this_i2cm->base_address = base_addr;
    this_i2cm->addr_mode = 0;
    this_i2cm->state = I2CM_STATE_IDLE;
    this_i2cm->interrupts_en = 0;
    this_i2cm->rx_buff = NULL;
    this_i2cm->rcv_length = 0;

	return 0;
}

uint8_t i2c_master_config(struct i2cm_instance * this_i2cm,
			  uint8_t i2c_mode, uint16_t interrupts_en, uint16_t pre_scaler)
{
	if (NULL == this_i2cm) {
        return 1;
	}

	if(interrupts_en != this_i2cm->interrupts_en)
	{
		this_i2cm->interrupts_en = interrupts_en;
	    reg_8b_write(this_i2cm->base_address | REG_INT_ENABLE1,interrupts_en);
	    reg_8b_write(this_i2cm->base_address | REG_INT_ENABLE2,interrupts_en >> 8);
	}

    // address mode set, 7-bit/10-bit mode
	if(this_i2cm->addr_mode != i2c_mode)
	{
		this_i2cm->addr_mode = i2c_mode;
		if (i2c_mode == I2CM_ADDR_10BIT_MODE) {
			reg_8b_modify(this_i2cm->base_address | REG_MODE,
					I2C_ADDR_MODE, I2C_ADDR_MODE);
		}
	}

	//set the pre_scaler to tune the i2c clock
	reg_8b_modify(this_i2cm->base_address | REG_MODE,
			I2C_CLK_DIV_HIGH, pre_scaler>>8);
	reg_8b_write(this_i2cm->base_address | REG_CLK_DIV_LSB,pre_scaler);

	return 0;
}


uint8_t i2c_master_read(struct i2cm_instance * this_i2cm,
			uint16_t address,
			uint8_t read_length, uint8_t * data_buffer)
{
	uint8_t fifo_status = 0;
	uint8_t i2c_int2 = 0;
	uint8_t data_count = 0;
	uint8_t i2c_status = 1;
	// assert this_i2cm and data_buffer
	if (NULL == this_i2cm ||NULL == data_buffer )
	{
		return 1;
	}

	// config the register before issue the transaction
	reg_8b_write(this_i2cm->base_address | REG_BYTE_CNT, read_length);

    reg_8b_write(this_i2cm->base_address | REG_SLAVE_ADDR_LOW,
              address & 0x7F);

    if(this_i2cm->addr_mode==I2CM_ADDR_10BIT_MODE)  // 10-bit mode
    {
        reg_8b_write(this_i2cm->base_address | REG_SLAVE_ADDR_HIGH,
                  (address>>7) & 0x03);
    }

    // set ti read mode
    reg_8b_modify(this_i2cm->base_address | REG_MODE, I2C_TXRX_MODE, I2C_TXRX_MODE);


    if(this_i2cm->state == I2CM_STATE_IDLE)
    {
    	this_i2cm->state = I2CM_STATE_READ;
    	reg_8b_write(this_i2cm->base_address | REG_CONFIG, I2C_START);
    }
    else
    {
    	return 1;
    }
	// check i2c status

#if !INT_MODE
    // clear I2C_ERR bits if set
    reg_8b_read(this_i2cm->base_address | REG_INT_STATUS2, &i2c_int2);
    reg_8b_write(this_i2cm->base_address | REG_INT_STATUS2, i2c_int2);

	while(1){

		reg_8b_read(this_i2cm->base_address | FIFO_STATUS_REG, &fifo_status);

		// if rx fifo not empty, read a byte
		if ( (fifo_status & RX_FIFO_EMPTY_MASK) == 0 )
	    {
            if (data_count <= read_length) {

            	reg_8b_read(this_i2cm->base_address |
                        REG_DATA_BUFFER, data_buffer);
            }
            // update the counter and data buffer pointer
            data_buffer++;
            data_count++;
	    }

	    if(read_length == data_count)
	    {
	    	i2c_status = 0;
	    	this_i2cm->state = I2CM_STATE_IDLE;
	    	break;
	    }

	    // check for I2C errors
	    reg_8b_read(this_i2cm->base_address | REG_INT_STATUS2, &i2c_int2);
        if (i2c_int2 & I2C_ERR)
        {
			// reset the i2c master
			reg_8b_modify(this_i2cm->base_address | REG_CONFIG, I2C_MASTER_RESET, I2C_MASTER_RESET);
			reg_8b_modify(this_i2cm->base_address | REG_CONFIG, I2C_MASTER_RESET, ~I2C_MASTER_RESET);

        	i2c_status = 1;
        	this_i2cm->state = I2CM_STATE_IDLE;
            break;
        }
	}
#else
    this_i2cm->rx_buff = data_buffer;
    this_i2cm->rcv_length = 0;
#endif
	return i2c_status;
}

uint8_t i2c_master_write(struct i2cm_instance * this_i2cm,
			 uint16_t address,
			 uint8_t data_size, uint8_t * data_buffer)
{
	uint8_t data_count = 0;
	uint8_t i2c_status = 0;
	uint8_t status = 0;
	uint8_t i2c_int2 = 0;
	uint8_t fifo_status = 0;

	if (NULL == this_i2cm || NULL == data_buffer )
	{
		return 1;
	}

	// config the register before issue the transaction
	reg_8b_write(this_i2cm->base_address | REG_BYTE_CNT, data_size);

	reg_8b_write(this_i2cm->base_address | REG_SLAVE_ADDR_LOW,
		      address & 0x7F);

    if(this_i2cm->addr_mode==I2CM_ADDR_10BIT_MODE)  // 10-bit mode
    {
        reg_8b_write(this_i2cm->base_address | REG_SLAVE_ADDR_HIGH,
	              (address>>8) & 0x03);
    }

    // set to write mode
    reg_8b_modify(this_i2cm->base_address | REG_MODE, I2C_TXRX_MODE, 0);

    // clear status bits
    reg_8b_read(this_i2cm->base_address | REG_INT_STATUS1, &status);
    reg_8b_write(this_i2cm->base_address | REG_INT_STATUS1, status);
    reg_8b_read(this_i2cm->base_address | REG_INT_STATUS2, &i2c_int2);
    reg_8b_write(this_i2cm->base_address | REG_INT_STATUS2, i2c_int2);

    while (data_count < data_size)
    {
    	// check tx fifo level,
        reg_8b_read(this_i2cm->base_address | REG_INT_STATUS1, &status);

		// if tx fifo is full, stop loading fifo for now, resume in interrupt or polling loop
		if ( (status & TX_FIFO_FULL_MASK) != 0 ) {
			break;
		}

        reg_8b_write(this_i2cm->base_address | REG_DATA_BUFFER, *data_buffer);  // push the data into tx buffer

        // update the counter and data buffer pointer
        data_buffer++;
        data_count++;
    }

    if(this_i2cm->state == I2CM_STATE_IDLE)
    {
    	// start the transaction
    	this_i2cm->state = I2CM_STATE_WRITE;
    	reg_8b_write(this_i2cm->base_address | REG_CONFIG, I2C_START);
    }
    else
    {
    	return 1;
    }

#if !INT_MODE
    // check the status until transfer done
    while(1)
    {
    	// cycle completes when all bytes are transmitted or a NACK is received or an ERROR is detected
    	reg_8b_read(this_i2cm->base_address | REG_INT_STATUS1, &status);
        if (status & I2C_TRANSFER_COMP_MASK)
        {
        	this_i2cm->state = I2CM_STATE_IDLE;
            break;
        }


    	// still have bytes to send
		if (data_count < data_size)
		{
			// load any additional bytes into tx fifo when it becomes almost empty
			reg_8b_read(this_i2cm->base_address | FIFO_STATUS_REG, &fifo_status);
			if (fifo_status & TX_FIFO_AEMPTY_MASK)	// if tx fifo is almost empty
			{
				reg_8b_write(this_i2cm->base_address | REG_DATA_BUFFER, *data_buffer);  // push the data into tx buffer

				// update the counter and data buffer pointer
				data_buffer++;
				data_count++;
			}
        }

        // check for I2C errors including NACK
    	reg_8b_read(this_i2cm->base_address | REG_INT_STATUS2, &i2c_int2);
        if (i2c_int2 & I2C_ERR)
        {
			// reset the i2c master
			reg_8b_modify(this_i2cm->base_address | REG_CONFIG, I2C_MASTER_RESET, I2C_MASTER_RESET);
			reg_8b_modify(this_i2cm->base_address | REG_CONFIG, I2C_MASTER_RESET, ~I2C_MASTER_RESET);

        	i2c_status = 1;
        	this_i2cm->state = I2CM_STATE_IDLE;
            break;
        }
    }
#endif
	return i2c_status;
}


void i2c_master_isr(void *ctx)
{
	uint8_t i2c_int1 = 0;
	uint8_t i2c_int2 = 0;

	volatile struct i2cm_instance* this_i2cm = (struct i2cm_instance *)ctx;

	reg_8b_read(this_i2cm->base_address | REG_INT_STATUS1, &i2c_int1);
	reg_8b_read(this_i2cm->base_address | REG_INT_STATUS2, &i2c_int2);

	reg_8b_write(this_i2cm->base_address | REG_INT_STATUS1, i2c_int1);
	reg_8b_write(this_i2cm->base_address | REG_INT_STATUS2, i2c_int2);

	if(i2c_int1 & I2C_TRANSFER_COMP_MASK)
	{
		this_i2cm->state = I2CM_STATE_IDLE;
	}

	if(i2c_int1 & RX_FIFO_RDY_MASK)
	{
		if((this_i2cm->state == I2CM_STATE_READ) && (this_i2cm->rx_buff != NULL))
		{
			reg_8b_read(this_i2cm->base_address |
			                        REG_DATA_BUFFER, this_i2cm->rx_buff);

			this_i2cm->rx_buff ++;
			this_i2cm->rcv_length ++;
		}
	}

	if(i2c_int2 & I2C_ERR)
	{
		// reset the i2c master
		reg_8b_modify(this_i2cm->base_address | REG_CONFIG, I2C_MASTER_RESET, I2C_MASTER_RESET);

		this_i2cm->state = I2CM_STATE_IDLE;

	}
}

