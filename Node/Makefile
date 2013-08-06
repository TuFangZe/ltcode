COMPONENT=TestSerialAppC
BUILD_EXTRA_DEPS += TestSerial.class
CLEAN_EXTRA = *.class TestSerialMsg.java
CFLAGS += -I$(TOSDIR)/lib/printf
CFLAGS += -I$(TOSDIR)/lib/T2Hack
TestSerial.class: $(wildcard *.java) TestSerialMsg.java
	javac -target 1.7 -source 1.7 *.java

TestSerialMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=TestSerialMsg TestSerial.h test_serial_msg -o $@


include $(MAKERULES)

