# REFERNCE | POLOLU ENCODER
API for Pololu 2-phase micro-metal motor with encoder

## Morimoto's Lab
Developed under Professor Morimoto for the EV-Vine Project.

## Notes
- Utilizes a PID controler to achieve accurate position
  - Varies PWM sen to motor
  - PID Values are hardcoded
- Confirms proper encoder operation with boolean values
  - If improper encoder function, no counts will be recorded

## API

### Creating an Object

```
Motor object = Motor(m1, m2, pin1, pin2)
```
#### Parameters:
- M1: Motor Phase A
- M2: Motor Phase B
- Pin1: Encoder A pin
- Pin2: Encoder B pin

### Parent Instance

Intended for use as the parent class to another class. Use the following example to impliment the Encoder instance as the parent to a child class:

```
Child(..., byte m1, byte m2, byte pA, byte pB):Motor(m1, m2, pA, pB) {...}
```
#### Parameters:
- M1: Motor Phase A
- M2: Motor Phase B
- Pin1: Encoder A pin
- Pin2: Encoder B pin
- ...: Self-included parameters and executions.

### Encoder Interrupt

Include the following block of code within the setup() function of the main program:
```
attachInterrupt(digitalPinToInterrupt(Pin1), ISR, CHANGE);
attachInterrupt(digitalPinToInterrupt(Pin2), ISR, CHANGE);
```
##### Parameters:
- Pin1: Encoder A pin
- Pin2: Encoder B pin
- ISR: The ISR to call when the interrupt occurs; this function must take no parameters and return nothing. This function is sometimes referred to as an interrupt service routine. More info [here](https://www.arduino.cc/reference/en/language/functions/external-interrupts/attachinterrupt/). Example ISR to class:
```
void en1A() {tendon[0].encoderA();}
```

## Callable Functions

```
void encoderA()
```
- Only to be called by the pointer ISR function
- Updates count when encoder A is tripped
- Return: Void

```
void encoderB()
```
- Only to be called by the pointer ISR function
- Updates count when encoder B is tripped
- Return: Void

```
void getCount()
```
- Return: absolute count of the encoder (int)

```
void setCounts(int val)
```
- Set the deseired counts the motor should be driven to
- Turn on the motor to drive it to this set count
```
void setRads(float val)
```
- Set the deseired rads the motor should be driven to
- Turn on the motor to drive it to this set radians
```
void getRad()
```
- Return: absolute rad of the encoder (float)

```
void zero()
```
- Home (zero) the count and setCount values of the motor

## Parameters

```
float gearRatio = 1000;
```
- Mechanical Advantage within Mico-Motor Gearbox
```
float radPerCount = 0;
```
- Conversion of Counts to Rads
- Encoder and Gearbox Specific

## Contributors
- Parker Knopf (MAE)
- Noah Jones (MAE)
- Karlo Gregorio (ECE | CS)