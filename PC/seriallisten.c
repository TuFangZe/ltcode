#include <stdio.h>
#include <stdlib.h>

#include "serialsource.h"

static char *msgs[] = {
  "unknown_packet_type",
  "ack_timeout"	,
  "sync"	,
  "too_long"	,
  "too_short"	,
  "bad_sync"	,
  "bad_crc"	,
  "closed"	,
  "no_memory"	,
  "unix_error"
};

void stderr_msg(serial_source_msg problem)
{
  fprintf(stderr, "Note: %s\n", msgs[problem]);
}


	  
int main(int argc, char **argv)
{
  serial_source src;

  if (argc != 3)
    {
      fprintf(stderr, "Usage: %s <device> <rate> - dump packets from a serial port\n", argv[0]);
      exit(2);
    }
  src = open_serial_source(argv[1], platform_baud_rate(argv[2]), 0, stderr_msg);
  if (!src)
    {
      fprintf(stderr, "Couldn't open serial port at %s:%s\n",
	      argv[1], argv[2]);
      exit(1);
    }
	
	int receiveNum=0;
	int a;	
	const int packetNum=8;
      int len, i,j;
	  int binaryMatrix[8];
	  int SendPayLoad[8]={1,2,3,4,5,6,7,8}; 
	  int Send;
	  int H[8][8]={0};
	  unsigned char  Y[8]={0};
	  unsigned char MatrixG;
	  int PayLoad;
	  int PayLoadtemp;
	  
while(1)
    {	
      const unsigned char *packet = read_serial_packet(src, &len);	  
      if (!packet)
	exit(0);
	   
	  MatrixG=packet[8]; 
      PayLoad=packet[10];
	  PayLoadtemp=PayLoad;
	  for (i=packetNum-1;i>=0;i--)
		{
		 binaryMatrix[i]=MatrixG%2;
		 MatrixG=MatrixG/2;
		} 
		
	
	

			
			
	while(1)
	{
		
		a=556; 
		for(i=0;i<packetNum;i++)
		{
			if(binaryMatrix[i]==1)
			{
				a=i;
				break;
			}
		}
		if(a==556)
		{
			break;
		}
		
		if (H[a][a]!=1)
		{
			for(j=0;j<packetNum;j++)
			{
				H[a][j]=binaryMatrix[j];
				
			}		
			Y[a]=PayLoad;	
			receiveNum=receiveNum+1;
			printf("ReceiveNum=%d\n",receiveNum);
			/*for(i=0;i<packetNum;i++)
			{  printf("\n");
				for(j=0;j<packetNum;j++)
				{
					printf("%d ",H[i][j]);					
				}
			}
			*/	
			break;
		}
		else
		{	for(j=0;j<packetNum;j++)
			binaryMatrix[j]=(binaryMatrix[j]+H[a][j])%2;
			PayLoad=PayLoad^Y[a];	
		}	
				
	}
	

	
      for (i = 0; i < len; i++)
	  printf("%02x ", packet[i]);
      putchar('\n');
	  printf("The Send=%02x\n",PayLoadtemp);
	  printf("The Binary G");
	  for(i=0;i<packetNum;i++)
	  {
	  printf("%d",binaryMatrix[i]);
	  }
	  printf("\n");
      free((void *)packet);
	  
	  if(receiveNum==8)
	  {
	  break;
	  } 
    }
		for(i=0;i<packetNum;i++)
			{  printf("\n");
				for(j=0;j<packetNum;j++)
				{
					printf("%d ",H[i][j]);					
				}
			}
			
			printf("\n");
	for(i=0;i<packetNum;i++) 
	printf("Y[%d]=%d\n",i,Y[i]);
	
	for(i=packetNum-1;i>0;i--)
	{
		for(j=0;j<i;j++)
		{
			if(H[j][i]==1)
			{
				H[j][i]=0;
				Y[j]=Y[j]^Y[i];
			}
		}
	}
	
	for(i=0;i<packetNum;i++)
	printf("%d\t",Y[i]);
}