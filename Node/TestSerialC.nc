// $Id: TestSerialC.nc,v 1.6 2007/09/13 23:10:21 scipio Exp $

/*									tab:4
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Application to test that the TinyOS java toolchain can communicate
 * with motes over the serial port. 
 *
 *  @author Gilman Tolle
 *  @author Philip Levis
 *  
 *  @date   Aug 12 2005
 *
 **/
#include "printf.h"
#include "Timer.h"
#include "TestSerial.h"

module TestSerialC {
  uses {
    interface SplitControl as Control;
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface Packet;
	interface Random;
  }
}
implementation {
  const int packetNum=8;
  message_t packet;
  
  bool locked = FALSE;
  uint8_t MatrixG;
  uint8_t MatrixGsend;
  uint16_t PayLoad;
  uint16_t SendPayLoad[8]={1,2,3,4,5,6,7,8}; 
  uint8_t BinaryMatrix[8];
  uint8_t  firstbit;

  int i,j;
  int counter=0;
  
  
  event void Boot.booted() {
    call Control.start();
	
  }
  
  event void Control.startDone(error_t err) {
    if (err == SUCCESS) {
      call MilliTimer.startPeriodic(1000);
	  
    }
	else {
		call Control.start();
	}
  }
  event void Control.stopDone(error_t err) {}  
  
  
  
  
  event void MilliTimer.fired() {
	j=packetNum-1;
	counter++;
    call Leds.led0Toggle();
	PayLoad=0;
	while(1)
	{
		MatrixGsend=call Random.rand32();
		MatrixG=MatrixGsend;
		if(((call Random.rand16())%2)==1)
		{
		MatrixG=MatrixGsend|0x80000000;
		}
		MatrixGsend=MatrixG;
		if(MatrixGsend!=0)
		{
		break;
		}
	}
	//encode  
	for(i=0;i<packetNum;i++)
	{
	BinaryMatrix[i]=0;
	}
	  while(1)
	{
	if(MatrixG!=0)
		{
			BinaryMatrix[j]=MatrixG%2;
			MatrixG=MatrixG/2;
			j--;
		}
	else if(MatrixG==0)
	break;
	}
  PayLoad=0;
  
  for(i=0;i<packetNum;i++)
	{	
	PayLoad=SendPayLoad[i]*BinaryMatrix[i]^PayLoad;
	}   
	//encode


	
	
    if (locked) {
      return;
    }
    else {
      test_serial_msg_t* rcm = (test_serial_msg_t*)call Packet.getPayload(&packet, sizeof(test_serial_msg_t));
      if (rcm == NULL) {return;}
      if (call Packet.maxPayloadLength() < sizeof(test_serial_msg_t)) {
	return;
      }

	  rcm->MatrixG=MatrixGsend;
	  rcm->PayLoad=PayLoad;
	  
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS) {
	locked = TRUE;
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
				   
   
      return bufPtr;

  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }


}




