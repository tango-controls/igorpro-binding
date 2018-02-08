#pragma TextEncoding = "UTF-8"
#pragma rtGlobals = 2
#pragma version = 1.0
#pragma IgorVersion = 6.0

//==============================================================================
// tango_reg_test.ipf - N.Leclercq - SOLEIL - 07/2007
//==============================================================================
// This file contains a "using the TANGO API for Igor Pro" tutorial. It also
// acts as a regression test for the binding itself. It provides very detailed 
// examples. A "must read" for any new commer to TANGO under Igor Pro.
//
// What is the prerequisite for programming with the TANGO API for Igor Pro? 
// The minimum is to be confortable with the TANGO concepts of <attribute> and
// <command>.
//
// This tutorial use the <TangoTest> device. An instance of this device must be
// running into your control system in order to run this test/tutorial. Once you
// have a living TangoTest, just pass its device name to the test functions [e.g.
// test_tango_cmd_io("tango/tangotest/1")]. You can also test everything by using
// the "tango_test_all" function.
//
//  Table of Content :
//  ------------------
//    - Chapter I   : Executing a TANGO command
//    - Chapter II  : Reading one (or more) attribute(s) on a TANGO device
//    - Chapter III : Writing one (or more) attribute(s) on a TANGO device
//
// This doc may contain some errors. Please let me know.
//
// Happy reading!
//
// Nicolas Leclercq - SOLEIL
//==============================================================================

//==============================================================================
// DEPENDENCIES
//==============================================================================
//- include the Tango API (required in each procedure using the Tango API)
#include "tango"

//==============================================================================
// TUTORIAL CHAPTER I : Executing a TANGO command
//==============================================================================
// The TANGO API defines a single structure for both the input (argin) and the 
// output (argout) arguments of a TANGO command. This structure called <CmdArgIO> 
// is defined in the <Tango.ipf> file.
//
// In order to execute a command on a tango device, we will systematically use
// the 'tango_cmd_inout' function. This function has the following signature:
//
// 		function tango_cmd_inout (dev, cmd, [arg_in, arg_out, dest_path])
//
//	The 'dev' parameter is the the name of the TANGO device on which the command 
// is executed. The name of the command is specified by the 'cmd' parmeter. As
// you can see, the 'tango_cmd_inout' has some optional parmeters: arg_in, arg_out
// and dest_path. Both 'arg_in' and 'arg_out' are 'CmdArgIO' structures:     
//
//  Structure CmdArgIO
//		//- var: command argin or argout for any type of numeric scalar
//    Variable var_val         
//		//- str: command argin or argout for a string scalar
//    String str_val   
//		//- full path to argin or argout for nay scalar type
//    String val_path   
//    //- full path to argin or argout wave for of numeric arrays        
//    String num_wave_path 
//    //- full path to argin or argout wave for string arrays
//    String str_wave_path  
//  EndStructure
//
// Why are 'arg_in' and 'arg_out' optional parameters?
// ---------------------------------------------------
// The TANGO provides support for 23 types of data for both input (i.e. argin)
// and output (i.e. argout) command arguments . The type of argin and argout can 
// be any of the following:
//
// DEV_VOID...................none (means no argument)
// DEV_STATE..................enumeration [mapped to Igor Variable]                 
// DEV_BOOLEAN................boolean [mapped to Igor Variable]  
// DEV_UCHAR..................8-bits unsigned integer [mapped to Igor Variable]              
// DEV_SHORT..................16-bits signed integer [mapped to Igor Variable] 
// DEV_USHORT.................16-bits unsigned integer [mapped to Igor Variable]                   
// DEV_LONG...................32-bits signed integer [mapped to Igor Variable] 
// DEV_ULONG..................32-bits unsigned integer [mapped to Igor Variable]                  
// DEV_FLOAT..................32-bits real [mapped to Igor Variable]                 
// DEV_DOUBLE.................64-bits real [mapped to Igor Variable]                
// DEV_STRING.................String [mapped to Igor String]
// DEV_VARBOOLEANARRAY........boolean array [mapped to Igor Wave/U/B]                 
// DEV_VARCHARARRAY...........8-bits unsigned integer array [mapped to Igor Wave/U/B]         
// DEV_VARSHORTARRAY..........16-bits signed integer array [mapped to Igor Wave/W]    
// DEV_VARUSHORTARRAY.........16-bits unsigned integer array [mapped to Igor Wave/U/W]        
// DEV_VARLONGARRAY...........32-bits signed integer array [mapped to Igor Wave/I]
// DEV_VARULONGARRAY..........32-bits unsigned integer array [mapped to Igor Wave/U/I]        
// DEV_VARFLOATARRAY..........32-bits real array [mapped to Igor Wave]         
// DEV_VARDOUBLEARRAY.........64-bits real array [mapped to Igor Wave/D]         
// DEV_VARSTRINGARRAY.........String array [mapped to Igor Wave/T] 
// DEV_VARLONGSTRINGARRAY.....composite type [mapped to Igor Wave/I + Wave/T]
// DEV_VARDOUBLESTRINGARRAY...composite type [mapped to Igor Wave/D + Wave/T]
//
// A TANGO command signature can be any combination of these types and making the
// 'arg_in' and 'arg_out' parameters of 'tango_cmd_inout' optional provides a way
// to take into account that the input AND/OR the ouput argument can be of type
// DEV_VOID. Here are some 'tango_cmd_inout' syntax examples for the different 
// situations (forget the 'dest_path' argument for the moment):
//
// Command where argin == DEV_VOID and argout == DEV_VOID
// ------------------------------------------------------
// 		'->  tango_cmd_inout (dev, cmd)
//
// Command where argin == DEV_VOID and argout != DEV_VOID
// ------------------------------------------------------
// 		'->  tango_cmd_inout (dev, cmd, arg_out = my_argout)
//
// Command where argin != DEV_VOID and argout == DEV_VOID
// ------------------------------------------------------
// 		'->  tango_cmd_inout (dev, cmd, arg_in = my_argin)
//
// Command where argin != DEV_VOID and argout != DEV_VOID
// ------------------------------------------------------
// 		'->  tango_cmd_inout (dev, cmd, arg_in = my_argin, arg_out = my_argout)
//
// to be continued....
//
// In the proposed examples, argin and argout always have the same type (this due to the 
// way the TangoTest device is implemented). Anyway, if you need to execute a command
// for which argin and argout are different (99% of the cases), just mix the "argin part"
// of the example corresponding to "your" argin type with the "argout part" of the example
// corresponding to "your" argout type.
//
// TangoTest has a command for each TANGO argument type. Each command is named
// with the name of the associated type and returns in <argout> a copy of <argin> 
// (i.e. echo like behaviour). It means that we can easily test and valide the 
// TANGO API for Igor by comparing <argin> with <argout> (they should equal each 
// other). The proposed examples just setup argin, execute the command then check
// the result by comparing <argin> with <argout>.    
//==============================================================================
function test_tango_cmd_io (dev_name)

	//- function arg: the name of the device on which the commands will be executed 
	String dev_name
  
	//- verbose
	print "\rStarting <Tango-API::tango_cmd_io> test...\r"
  
	//- let's declare our <argin> and <argout> structures. 
	//- be aware that <argout> will be overwritten (and reset) each time we execute a 
	//- command it means that you must use another <CmdArgOut> if case you want to 
	//- store more than one command result at a time. here we reuse both argin and 
	//- argout for each command.

	//- argin
	Struct CmdArgIO argin
	tango_init_cmd_argio (argin)
	
	//- argout 
	Struct CmdArgIO argout
	tango_init_cmd_argio (argout)
	
	//- populate argin: <dev> struct member
	//- the name of the device on which the command will be executed
	//- since the commands are executed on the same device (i.e. dev_name), we set the 
	//- <CmdArgIn.dev> struct member only once (i.e. no need to set it not each time 
	//- we execute a command)
	String dev = dev_name

	//-------------------------------------------------------------------------------------------
	// DEV_VOID/DEV_VOID COMMAND  
	//-------------------------------------------------------------------------------------------
	//- an example of a command that does not have any <in> nor <out> argument. In such a case, 
	//- <tango_cmd_in>.

	//- populate argin: <CmdArgIn.cmd> struct member
	//- name of the command to be executed on <argin.dev> 
	String cmd = "DevVoid"
  
	//- verbose
	print " \rexecuting <" + cmd + ">...\r"
 
	//- for perf measurement purpose , we start a µs timer
	Variable mst_ref = StartMSTimer
	 
	//- actual cmd execution 
	//- ALWAYS CHECK THE CMD RESULT: 0 means NO_ERROR, -1 means ERROR
	if (tango_cmd_inout(dev, cmd) == -1)
		//- the cmd failed, display error...
		tango_display_error()
		//- ... then return error
		return -1
	endif
	
	//- stop the timer and get elapsed µs
	Variable mst_dt = StopMSTimer(mst_ref)
	
	//- print out the perf result
	print "\t'-> took " + num2str(mst_dt / 1000) + " ms to complete"
	
	print "\t'-> cmd passed\r"
  
	//- congratulations you only just executed your first command on a TANGO device!
	//- note that there is no previous connection to the device (it is implicitely done for you)  

	//-------------------------------------------------------------------------------------------
	// DEV_BOOL/DEV_BOOL COMMAND  
	//-------------------------------------------------------------------------------------------
	//- an example of a command where argin and argout are a single boolean (i.e. not an array 
	//- of boolean). In such a case, <tango_cmd_inout>.

	//- populate argin: <CmdArgIn.cmd> struct member
	//- name of the command to be executed on <argin.dev> 
	cmd = "DevBoolean"

	//- verbose
	print "\rexecuting <" + cmd + ">...\r"
  
	//- since the command input argument is a numeric scalar (i.e. single numeric value of type
	//- boolean), we stored its value into the <var> member of the <CmdArgIn> structure. This is 
	//- true for any numeric scalar type (see following examples).
	//- for a boolean, 0 means FALSE, 1 means TRUE
	argin.var_val = 1
  
	mst_ref = StartMSTimer
  
	//- actual cmd execution
	//- if an error occurs during command execution, argout is undefined (null or empty members)
	//- ALWAYS CHECK THE CMD RESULT BEFORE TRYING TO ACCESS ARGOUT: 0 means NO_ERROR, -1 means ERROR
	if (tango_cmd_inout(dev, cmd, arg_in = argin, arg_out = argout) == -1) 
		//- the cmd failed, display error...
		tango_display_error()
		//- ... then return error
		return -1
	endif

	mst_dt = StopMSTimer(mst_ref)
	print "\t'-> took " + num2str(mst_dt / 1000) + " ms to complete"
	
	//- <argout> is populated (i.e. filled) by <tango_cmd_inout> upon return of the command.
	//- since the command ouput argument is a numeric scalar (i.e. single numeric value), it 
	//- is stored in the <var> member of the <CmdArgOut> structure. This is true for any numeric 
	//- scalar type (see following examples).
	//- as previously explained, we are testing our TANGO binding on a TangoTest device. 
	//- consequently, we check that <argin.var = argout.var> in order to be sure that everything is ok
	if (argin.var_val != argout.var_val)
		//- the cmd failed, display error...
		tango_display_error_str("ERROR:DevBoolean:unexpected cmd result - aborting test")
		//- ... then return error
		return -1
	endif
  
	//- verbose
	print "\t'-> cmd passed\r"
  
	//- ok you know how to a execute a command with a scalar numeric arg for argin and/or argout
	//- let's test the remaining "scalar numeric" commands using a dedicated generic function (less 
	//- boring than copy/paste the code)
  
	//- test DevShort
	if (test_num_scalar_cmd (dev_name, "DevShort", -128) == -1)
		return -1
	endif

	//- test DevUShort
	if (test_num_scalar_cmd (dev_name, "DevUShort", 128) == -1)
		return -1
	endif

	//- test DevLong
	if (test_num_scalar_cmd (dev_name, "DevLong", -2048) == -1)
		return -1
	endif

	//- test DevULong
	if (test_num_scalar_cmd (dev_name, "DevULong", 2048) == -1)
		return -1
	endif

	//- test DevFloat
	if (test_num_scalar_cmd (dev_name, "DevFloat", -3.14159) == -1)
		//- ignore numeric error - numeric rounding (double to float) generates 
		//- a side effect when comparing argin.var to argout.var 
		if (tango_error() != 0)
			//- error comes from TANGO: abort test, continue otherwise
			return -1
		endif
	endif 

	//- test DevDouble
	if (test_num_scalar_cmd (dev_name, "DevDouble", 3.14159) == -1)
		return -1
	endif 
  
	//- ok "numeric scalar" commands are tested and seems to work properly
	//- now, let's try with a string scalar arg...

	//-------------------------------------------------------------------------------------------
	// DEV_STRING/DEV_STRING COMMAND  
	//-------------------------------------------------------------------------------------------
	//- an example of a command where argin and argout are a single string (i.e. not an array 
	//- of strings). In such a case, <tango_cmd_inout>. 
  
	//- populate argin: <CmdArgIn.cmd> struct member
	//- name of the command to be executed on <argin.dev> 
	cmd = "DevString"

	//- verbose
	print "\rexecuting <" + cmd + ">...\r"
  
	//- since the command argin is a string scalar (i.e. single string), we stored its its value 
	//- into the <str> member of the <CmdArgIn> structure. 
	argin.str_val = "hello world"
  
	mst_ref = StartMSTimer
  
	//- actual cmd execution
	//- if an error occurs during command execution, argout is undefined (null or empty members)
	//- ALWAYS CHECK THE CMD RESULT BEFORE TRYING TO ACCESS ARGOUT: 0 means NO_ERROR, -1 means ERROR
	if (tango_cmd_inout(dev, cmd, arg_in = argin, arg_out = argout) == -1)
		//- the cmd failed, display error...
		tango_display_error()
		//- ... then return error
		return -1
	endif
  
	mst_dt = StopMSTimer(mst_ref)
	print "\t'-> took " + num2str(mst_dt / 1000) + " ms to complete"
	
	//- <argout> is populated (i.e. filled) by <tango_cmd_inout> uppon return of the command.
	//- since the command ouput argument is a string scalar (i.e. single string), it is stored 
	//- in the <str> member of the <CmdArgOut> structure.

	//- as previously explained, we are testing our TANGO binding on a TangoTest device. 
	//- consequently, we check that <argin.str = argout.str> in order to be sure that everything is ok
	if (cmpstr(argin.str_val, argout.str_val) != 0)
		//- the cmd failed, display error...
		tango_display_error_str("ERROR:DevString:unexpected cmd result - aborting test")
		//- ... then return error
		return -1
	endif
  
	//- verbose
	print "\t'-> cmd passed\r"
  
	//- ok all "scalar" commands are tested and seems to work properly
	//- now, let's try with arrays...

	//-------------------------------------------------------------------------------------------
	// DEV_VARLONGARRAY/DEV_VARLONGARRAY COMMAND
	//-------------------------------------------------------------------------------------------
	//- an example of a command where argin and argout are both an array of longs. Here again, we
	//- use <tango_cmd_inout> in order to execute the comand.
  
	//- populate argin: <cmd> struct member
	//- name of the command to be executed on <argin.dev> 
	cmd = "DevVarLongArray"
  
	//- verbose
	print "\rexecuting <" + cmd + ">...\r"
  
	//- build the argin wave...
	//- be aware that its data type must match the exact TANGO argin type. the simplest way to 
	//- do that is to use the provided helper function <tango_argin_type_to_wave_type>. this
	//- function of the TANGO API returns the correct wave data type for the specified device
	//- and command. the /Y option of Make will do the rest. 
	//- so get the wave data type...
	Variable wave_type = tango_argin_type_to_wave_type(dev, cmd)
	//- ...then the argin wave   
	Make /O /N=128 /Y=(wave_type) argin_wave = abs(enoise(1024))

	//- we do not actually pass the wave to <tango_cmd_inout> - what is required is the full path 
	//- to the argin wave. in fact we need to provide the TANGO API with the location of the argin 
	//- wave (this due to an Igor Pro limitation in the management of the TANGO genericity). 
	//- since argin is a numeric wave, its path is stored into the <num_wave_path> of the <CmdArgIn>
	//- structure. this is true for any numeric argin wave. an utility function, <GetWavesDataFolder> 
	//- is provided in order to ease this process  
	argin.num_wave_path = GetWavesDataFolder(argin_wave, 2)

	//- here we specify the path to the destination wave 
	argout.num_wave_path = GetDataFolder(1) + "argout_wave"
	
	mst_ref = StartMSTimer
  	
	//- actual cmd execution
	//- if an error occurs during command execution, argout is undefined (null or empty members)
	//- ALWAYS CHECK THE CMD RESULT BEFORE TRYING TO ACCESS ARGOUT: 0 means NO_ERROR, -1 means ERROR
	if (tango_cmd_inout(dev, cmd, arg_in = argin, arg_out = argout) == -1)
		//- the cmd failed, display error...
		tango_display_error()
		//- ... then return error
		return -1
	endif
	mst_dt = StopMSTimer(mst_ref)
	print "\t'-> took " + num2str(mst_dt / 1000) + " ms to complete"
	
	//- <argout> is populated (i.e. filled) by <tango_cmd_inout> uppon return of the command.
	//- since the command ouput argument is a numeric array of long, it is stored in the 
	//- <num_wave> member of the <CmdArgOut> structure. this is true for any numeric argout array.   
	//- in order to access the command result, we first need to obtain a reference to argout.num_wave ...
	WAVE argout_wave = $argout.num_wave_path
  
	//- as previously explained, we are testing our TANGO binding on a TangoTest device. 
	//- consequently, we check that <argin = argout> in order to be sure that everything is ok
	//- we use the Igor's <x> operator in order for the comparaison. just magic!
	if (!EqualWaves(argin_wave, argout_wave, 1))
		//- the cmd failed, display error...
		tango_display_error_str("ERROR:DevVarLongStringArray:unexpected cmd result - aborting test")
		//- ... then return error
		return -1
	endif
  
	//- verbose
	print "\t'-> cmd passed\r"
  
	//- cleanup (suppose that waves are no longer needed)
	KillWaves/Z argin_wave, argout_wave   
  
	//- ok, you know how to a execute a command with a numeric array arg for argin and/or argout
	//- let's test the remaining commands using a dedicated generic function (less boring than 
	//- copy/paste the code)
  
	//- test DevVarCharArray
	if (test_num_array_cmd (dev_name, "DevVarCharArray") == -1)
		return -1
	endif

	//- test DevVarShortArray
	if (test_num_array_cmd (dev_name, "DevVarShortArray") == -1)
		return -1
	endif

	//- test DevVarUShortArray
	if (test_num_array_cmd (dev_name, "DevVarUShortArray") == -1)
		return -1
	endif

	//- test DevVarULongArray
	if (test_num_array_cmd (dev_name, "DevVarULongArray") == -1)
		return -1
	endif

	//- test DevVarFloatArray
	if (test_num_array_cmd (dev_name, "DevVarFloatArray") == -1)
		//- ignore numeric error - numeric rounding (double to float) generates 
		//- a side effect when comparing argin.num_wave to argout.num_wave 
		if (tango_error() != 0)
			//- error does comes from TANGO: abort test, continue otherwise
			return -1
		endif
	endif

	//- test DevVarDoubleArray
	if (test_num_array_cmd (dev_name, "DevVarDoubleArray") == -1)
		return -1
	endif 

	//- ok numeric all numeric array commands are tested and seems to work properly
	//- now, let's try with an array of strings argin...

	//-------------------------------------------------------------------------------------------
	// DEVVAR_STRINGARRAY/DEVVAR_STRINGARRAY COMMAND  
	//-------------------------------------------------------------------------------------------
	//- an example of a command where argin and argout are both an array of strings. We still 
	//- use <tango_cmd_inout> 
  
	//- populate argin: <cmd> struct member
	//- name of the command to be executed on <argin.dev> 
	cmd = "DevVarStringArray"
  
	//- verbose
	print "\rexecuting <" + cmd + ">...\r"
  
	//- build the argin wave - be aware that it must be of the expected type
	//- note the /T option - it tells Make taht we want to create a text wave (i.e. array of strings) 
	Make /O /N=128 /T argin_str_wave = "hello world"

	//- here again, we do not actually pass the wave to <tango_cmd_inout> - what is required is the 
	//- full path to the argin wave. in fact we need to provide the TANGO API with the location of 
	//- the argin wave (i.e. the datafolder in which the wave is located). since argin is a text 
	//- wave, its path is stored into the <str_wave_path> of the <CmdArgIn>. 
	argin.str_wave_path = GetWavesDataFolder(argin_str_wave, 2)
  
	//- here we specify the path to the destination wave. 
	argout.str_wave_path = GetDataFolder(1) + "argout_wave"
	
	mst_ref = StartMSTimer
  	
	//- actual cmd execution
	//- if an error occurs during command execution, argout is undefined (null or empty members)
	//- ALWAYS CHECK THE CMD RESULT BEFORE TRYING TO ACCESS ARGOUT: 0 means NO_ERROR, -1 means ERROR
	if (tango_cmd_inout(dev, cmd, arg_in = argin, arg_out = argout) == -1)
		//- the cmd failed, display error...
		tango_display_error()
		//- ... then return error
		return -1
	endif
  
	mst_dt = StopMSTimer(mst_ref)
	print "\t'-> took " + num2str(mst_dt / 1000) + " ms to complete"
	
	//- <argout> is populated (i.e. filled) by <tango_cmd_inout> uppon return of the command.
	//- since the command ouput arg is an array of strings, it is stored in the <str_wave> member 
	//- of the <CmdArgOut> structure. 
	//- as previously explained, we are testing our TANGO binding on a TangoTest device. 
	//- consequently, we check that <argin = argout> in order to be sure that everything is ok
	//- we first need to obtain a reference to argout.str_wave ...
	WAVE/T argout_str_wave = $argout.str_wave_path
	//- ... then we use the Igor's <x> operator in order for the comparaison. just magic!
	if (!EqualWaves(argin_str_wave, argout_str_wave, 1))
		//- the cmd failed, display error...
		tango_display_error_str("ERROR:DevVarStringArray:unexpected cmd result - aborting test")
		//- ... then return error
		return -1
	endif
  
	//- verbose
	print "\t'-> cmd passed\r"
  
	//- cleanup (suppose that waves are no longer needed)
	KillWaves/Z $argin.str_wave_path, $argout.str_wave_path
  
	//- now, let's try with the TANGO composite arrays: DevVar[Long and Double]StringArray

	//-------------------------------------------------------------------------------------------
	// DEVVAR_DOUBLESTRINGARRAY/DEVVAR_DOUBLESTRINGARRAY
	//-------------------------------------------------------------------------------------------
	//- an example of a command where argin and argout are both an DEVVAR_DOUBLESTRINGARRAY (i.e.
	//- a TANGO composite type containing an array of double and an array of strings).The TANGO API
	//- function <tango_cmd_inout still do the job. this example is just a mix of DevVarDoubleArray 
	//- and the DevVarStringArray examples. here we use both the numeric and the text part of both 
	//- <CmdArgIn> and <CmdArgOut>. 

	//- populate argin: <cmd> struct member
	//- name of the command to be executed on <argin.dev> 
	cmd = "DevVarDoubleStringArray"

	//- verbose
	print "\rexecuting <" + cmd + ">...\r"

	//- get wave type for the numeric part of argin
	wave_type = tango_argin_type_to_wave_type(dev, cmd)

	//- build the numeric part of argin - the /Y option is used to specify the right data type
	Make /O /N=128 /Y=(wave_type) argin_num_wave = enoise(1024)

	//- build the text part of argin - note the /T for text wave 
	Make /O /N=256 /T argin_str_wave = "hello world"

	//- did you note that the num and str waves may not have the same number of points ?
 
	//- set paths to both part of argin
	argin.num_wave_path = GetWavesDataFolder(argin_num_wave, 2)
	argin.str_wave_path = GetWavesDataFolder(argin_str_wave, 2)

	//- set paths to both part of argout
	argout.num_wave_path = GetDataFolder(1) + "argout_nwave"
	argout.str_wave_path = GetDataFolder(1) + "argout_swave"
	
	//- actual cmd execution
	//- if an error occurs during command execution, argout is undefined (null or empty members)
	//- ALWAYS CHECK THE CMD RESULT BEFORE TRYING TO ACCESS ARGOUT: 0 means NO_ERROR, -1 means ERROR
	if (tango_cmd_inout(dev, cmd, arg_in=argin, arg_out=argout) == -1)
		//- the cmd failed, display error...
		tango_display_error()
		//- ... then return error
		return -1
	endif

	//- Tangotest specific ckecking...

	//- first check result for the txt part...
	WAVE/T argout_str_wave = $argout.str_wave_path
	//- ... then we use the Igor's <x> operator in order for the comparaison. just magic!
	if (!EqualWaves(argin_str_wave, argout_str_wave, 1))
		//- the cmd failed, display error...
		tango_display_error_str("ERROR:DevVarDoubleStringArray:unexpected cmd result on text part - aborting test")
		//- ... then return error 
		return -1
	endif

	//- then check result for the numeric part...
	WAVE argout_num_wave = $argout.num_wave_path
	//- ... then we use the Igor's <x> operator in order for the comparaison. just magic!
	if (!EqualWaves(argin_num_wave, argout_num_wave, 1))
		//- the cmd failed, display error...
		tango_display_error_str("ERROR:DevVarDoubleStringArray:unexpected cmd result on numeric part - aborting test")
		//- ... then return error
		return -1
	endif

	//- verbose
	print "\t'-> cmd passed\r"

	//- cleanup (suppose that waves no are longer needed)
	KillWaves/Z $argin.num_wave_path, $argout.num_wave_path
	KillWaves/Z $argin.str_wave_path, $argout.str_wave_path
   
	//-------------------------------------------------------------------------------------------
	// DEVVAR_LONGSTRINGARRAY/DEVVAR_LONGSTRINGARRAY
	//-------------------------------------------------------------------------------------------
	//- an example of a command where argin and argout are both an DEVVAR_LONGSTRINGARRAY (i.e.
	//- a TANGO composite type containing an array of double and an array of strings).The TANGO API
	//- function <tango_cmd_inout still do the job. this example is just a mix of DevVarDoubleArray 
	//- and the DevVarStringArray examples. here we use both the numeric and the text part of both 
	//- <CmdArgIn> and <CmdArgOut>. 

	//- populate argin: <cmd> struct member
	//- name of the command to be executed on <argin.dev> 
	cmd = "DevVarLongStringArray"

	//- verbose
	print "\rexecuting <" + cmd + ">...\r"

	//- get wave type for the numeric part of argin
	wave_type = tango_argin_type_to_wave_type(dev, cmd)

	//- build the numeric part of argin - the /Y option is used to specify the right data type
	Make /O /N=128 /Y=(wave_type) argin_num_wave = enoise(1024)

	//- build the text part of argin - note the /T for text wave 
	Make /O /N=256 /T argin_str_wave = "hello world"

	//- did you note that the num and str waves may not have the same number of points ?
 
	//- set paths to both part of argin
	argin.num_wave_path = GetWavesDataFolder(argin_num_wave, 2)
	argin.str_wave_path = GetWavesDataFolder(argin_str_wave, 2)

	//- set paths to both part of argout
	argout.num_wave_path = GetDataFolder(1) + "argout_nwave"
	argout.str_wave_path = GetDataFolder(1) + "argout_swave"
	
	//- actual cmd execution
	//- if an error occurs during command execution, argout is undefined (null or empty members)
	//- ALWAYS CHECK THE CMD RESULT BEFORE TRYING TO ACCESS ARGOUT: 0 means NO_ERROR, -1 means ERROR
	if (tango_cmd_inout(dev, cmd, arg_in=argin, arg_out=argout) == -1)
		//- the cmd failed, display error...
		tango_display_error()
		//- ... then return error
		return -1
	endif

	//- Tangotest specific ckecking...

	//- first check result for the txt part...
	WAVE/T argout_str_wave = $argout.str_wave_path
	if (!EqualWaves(argin_str_wave, argout_str_wave, 1))
		//- the cmd failed, display error...
		tango_display_error_str("ERROR:DevVarLongStringArray:unexpected cmd result on text part - aborting test")
		//- ... then return error
		return -1
	endif

	//- then check result for the numeric part...
	WAVE argout_num_wave = $argout.num_wave_path
	//- ... then we use the Igor's <x> operator in order for the comparaison. just magic!
	if (!EqualWaves(argin_num_wave, argout_num_wave,1))
		//- the cmd failed, display error...
		tango_display_error_str("ERROR:DevVarLongStringArray:unexpected cmd result on numeric part - aborting test")
		//- ... then return error
		return -1
	endif

	//- verbose
	print "\t'-> cmd passed\r"

	//- cleanup (suppose that waves no are longer needed)
	KillWaves/Z $argin.num_wave_path, $argout.num_wave_path
	KillWaves/Z $argin.str_wave_path, $argout.str_wave_path
    
	//- no error - great!
	print "\r<Tango-API::tango_cmd_io> : TEST PASSED\r"
	return 0
end

//==============================================================================
// TUTORIAL CHAPTER II : Reading one (or more) attribute(s) on a TANGO device
//==============================================================================
// The TANGO API defines and use the same structure for both reading and writing 
// an attribue: <AttributeValue>. This structue is defined in the <Tango.ipf> file. 
//
// <AttributeValue> has the following structure:
// ---------------------------------------------
//  Structure AttributeValue
//    String dev           //- device name
//    String attr          //- attribute name
//    int16 format         //- attribute format: kSCALAR, kSPECTRUM or kIMAGE
//    int16 type           //- attribute data type : kSTRING, kLONG, kDOUBLE, ... 
//    double ts            //- timestamp in seconds since "Igor's time reference"
//    String str_val       //- attribute value for string Scalar attributes
//    Variable var_val     //- attribute value for numeric Scalar attributes
//    Wave wave_val        //- attribute value for any Spectrum or Image attribute 
//    String val_path      //- full path to <wave_val> (datafolder)
//  EndStructure
//
//  When reading an attribute you must specify the device and the attribute
//  name. Others <AttributeValue> structure members are not required and will
//  be filled by the reading function <tango_read_attr>.
//
//  Note about <AttributeValue.format>: 
//  -----------------------------------
//  The attribute format: kSCALAR, kSPECTRUM or kIMAGE.
//  Placed in <AttributeValue> in order to ease "generic" data processing. 
//  Not really usefull in 99% of the use cases. This struct member is filled 
//  by the TANGO API reading function <tango_read_attr>. 
//  
//  Note about <AttributeValue.type>: 
//  ---------------------------------
//  The attribute data type : kSTRING, kLONG, kDOUBLE, ...
//  Placed in <AttributeValue> in order to ease "generic" data processing. 
//  Not really usefull in 99% of the use cases. This struct member is filled 
//  by the TANGO API reading function <tango_read_attr>. 
//
//  Note about <AttributeValue.ts>: 
//  ----------------
//  The timestamp of the attribute. We use the Igor's <DateTime> format. See
//  Igor's DateTime documentation for more info. 
//
//  Note about <AttributeValue.str_val>: 
//  ------------------------------------
//  Attribute value for string <Scalar> attributes (i.e. for single string).
//  Valid if <format> = kSCALAR and <type> = kSTRING, undefined otherwise.
//  Also undefined in case of error during attribute reading - it means that 
//  you should **ALWAYS** check the error code returned by <tango_read_attr> 
//  before trying to access this string.
//
//  Note about <AttributeValue.var_val>: 
//  ------------------------------------
//  Attribute value for numeric <Scalar> attributes (i.e. for single numeric 
//  value). Valid if <format> = kSCALAR and <type> != kSTRING, undefined otherwise.
//  Also undefined in case of error during attribute reading - it means that 
//  you should always check the error code returned by <tango_read_attr> before 
//  trying to access this variable.
//
//  Note about <AttributeValue.wave_val>: 
//  -------------------------------------
//  Attribute value any <Spectrum> or <Image> attributes (i.e. any array, even arrays
//  of stings). The nature of <wave_val> depends on the attribute format:
//  if <format> = kSCALAR, undefined - <str_val> or <val_var> is used instead
//  If <format> = SPECTRUM, <wave_val> is a 1D wave of <type> 
//  If <format> = IMAGE, <wave_val> is 2D wave of <type>
//  As you can see, <wave_val> is only valid for any data type if the attribute a either 
//  spectrum or an image. Also undefined in case of error during attribute reading - it 
//  means that you should **ALWAYS** check the error code returned by <tango_read_attr> 
//  before trying to access this wave. Be aware that this is a global object overwritten 
//  each time the attribute is read. This member is used when reading an attribute (set 
//  by the reading function). It can't be used for writing an attribute.
//
//  Note about <AttributeValue.val_path>: 
//  ------------------------------------------
//  When reading a SPECTRUM or IMAGE (i.e. a WAVE), you can use this struct member in 
//  order to specify in which datafolder the result should be placed. If you don't care
//  about the result location, just forget it and leave the API do it for you. In this case,
//  the TANGO API will use the a default "tmp" datafolder. The reading function 
//  <tango_read_attr(s)> will fill <AttributeValue.val_path> with the fully qualified 
//  path (from root:) to the wave attribute value so that you can easily retreive the 
//  data wherever it is located (default or user specified datafolder). Note that 
//  <val_path> has no sense for SCALAR attributes since their value is always stored 
//  into <str_val> or <var_val>.   
//
// Reading several attributes in one call 
// --------------------------------------
// The TANGO API for Igor Pro provides a way to read several attributes on the SAME
// device in a single call. In such a cas, the function <tango_read_attrs> is used 
// (note the 's' in the function name). In order to achieve such a magical feature,
// we need an data structure capable of storing more than one attribute value. The
// <AttributeValues> structure has been introduced for this purpose (again, note 
// the 's' in the structure name). <AttributeValues> has the following members:
//
//  Structure AttributeValues
//    String dev                                //- the name of device
//    int16 nattrs                              //- actual the num of attributes to read
//    String df                                 //- destination datafolder for SPECTRUM ans IMAGE
//    Strut AttributeValue vals[kMAX_NUM_ATTR]  //- an array of <AttributeValues>
//  EndStructure
//
//  Note about <AttributeValues.nattrs>: 
//  ------------------------------------
//  Actual the num of attributes to read - must be <= kMAX_NUM_ATTR. Should 
//  obviously equal the number of valid <AttributeValue>s you pass in the 
//  <vals> member. Its value must be <= kMAX_NUM_ATTR. This // is defined
//  in the Tango.ipf file and set to 16. If you need to read more than 16 
//  attributes on the SAME device, edit the Tango.ipf file and change kMAX_NUM_ATTR
//  to the appropriate value. 
//
//  Note about <AttributeValues.vals>: 
//  ----------------------------------
//  An array of kMAX_NUM_ATTR <AttributeValue> is used to stored the attribute values.
//  Uppon return of the reading function <tango_read_attrs>, <AttributeValues.nattrs>
//  attribute values are actually valid in the array. In case of error during attributes 
//  reading, the content of <AttributeValues.vals> is undefined. That's why you should 
//  **ALWAYS** check the error code returned by <tango_read_attr> before trying to use 
//  the content of <AttributeValues.vals>.
//
//  Note about <AttributeValues.df>: 
//  ------------------------------------------
//  When reading a SPECTRUM or IMAGE (i.e. a WAVE), you can use this struct member in 
//  order to specify in which datafolder the results should be placed. If you don't care
//  about the results location, just forget it and let the API to do it for you. In this case,
//  the TANGO API will use the a default "tmp" datafolder. The reading function 
//  <tango_read_attr(s)> will fill each <AttributeValue.val_path> with the fully qualified 
//  path (from root:) to the wave attribute value so that you can easily retreive the 
//  data wherever it is located (default or user specified datafolder). Note that 
//  <df> has no sense for SCALAR attributes since their value is always stored 
//  into <str_val> or <var_val>. 
//
// The following <test_tango_read_attr> function gives an example for each TANGO 
// attribute type. The usage of <AttributeValue> is detailed.
//
// The <test_tango_read_attrs> function (see below) provides a how to for reading
// more several attributes in one call.
//
// TangoTest has an attribute for each TANGO type. Each attribute is named with 
// the name of the associated type.    
//==============================================================================
//==============================================================================
// TUTORIAL CHAPTER II : READING ONE ATTRIBUTE
//==============================================================================
function test_tango_read_attr (dev_name)

	//- function arg: the name of the device on which the attributes will be read
	String dev_name
  
	//- verbose
	print "\rStarting <Tango-API::tango_read_attr> test...\r"
  
   	//- create a root:tmp datafolder and make it the current datafolder
  	//- this function is kind enough to create all the datafolder along
  	//- the speciifed path in case they don't exist. great, isn't it?
  	tools_df_make("root:tmp", 1)
  	
	//- let's declare our <AttributeValue> structure. 
	//- be aware that <av> will be overwritten (and reset) each time we read
	//- an attribute. it means that you must use another <AttributeValue> if case 
	//- you want to store more than one attribue value at a time. here we reuse 
	//- <av> for each attribute reading 
	Struct AttributeValue av
  
	//- for 'technical reasons', the AttributeValue must be initialized 
	//- this ensures that everything is properly setup 
	tango_init_attr_val(av)
  
	//- populate attr_val: <dev> struct member
	//- the name of the device on which the attribute will be read
	//- NB: since the attributes will be read on the same device (i.e. dev_name), 
	//- we set the <AttributeValue.dev> struct member only once (i.e. no need to 
	//- set it not each time we execute a command)  
	av.dev = dev_name

	//- populate attr_val: <attr> struct member
	//- it's simply the name of the attribute to read
	av.attr = "short_scalar"

	//- for perf measurement purpose , we start a µs timer
	Variable mst_ref = StartMSTimer
	 
	//- no need to fill any other <AttributeValue> members in order to read an 
	//- attribute. so let's read it...
	if (tango_read_attr (av) == -1)
		//- could not read the attribute, display error..
		tango_display_error()
		//- ... then return error
		return -1
	endif
	
	//- stop the timer and get elapsed µs
 	Variable mst_dt = StopMSTimer(mst_ref)
 	
	//- let's play with the attribute value...
	//- we printout <av>. observe that <av.var_val> is the only valid "value member" 
	//- in the "returned" struct. here the struct member <av.var_val> contains the 
	//- value of the <long_scalar> attribute. all other struct "value member" is 
	//- undefined and should not be used
	tango_dump_attribute_value (av)
	
	//- print out the perf result
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
	
	//- let's read 'long_scalar' attribute now...
	av.attr = "long_scalar"
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
	
	//- read 'boolean_scalar' attribute now...
	av.attr = "boolean_scalar"
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
	
	//- read all other scalar attributes...
	av.attr = "uchar_scalar"
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	av.attr = "ushort_scalar"
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	av.attr = "double_scalar"
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	//- State is a special attribute 
	av.attr = "State"
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	//- we printout <av>. here the struct member <av.var_val> contains the value 
	//- of the <State> attribute. all others are undefined. The following state 
	//- constants are defined in the <Tango.ipf> file. the TANGO API provides
	//- the 'tango_get_state_str' function in order to obtain the state in a more
	//- readable way (see example below).
	//- kDeviceStateON      = 0
	//- kDeviceStateOFF     = 1
	//- kDeviceStateCLOSE   = 2
	//- kDeviceStateOPEN    = 3
	//- kDeviceStateINSERT  = 4 
	//- kDeviceStateEXTRACT = 5
	//- kDeviceStateMOVING  = 6
	//- kDeviceStateSTANDBY = 7
	//- kDeviceStateFAULT   = 8
	//- kDeviceStateINIT    = 9
	//- kDeviceStateRUNNING = 10
	//- kDeviceStateALARM   = 11
	//- kDeviceStateDISABLE = 12
	//- kDeviceStateUNKNOWN = 13
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
	print "\t-Current device state is: " + tango_get_state_str(av.var_val)
  
	//- let's try reada string scalar attribute now.
	//- no real change (compared to previous examples) except that the value is now
	//- returned in the <str_val> member of <AttributeValue>
	av.attr = "string_scalar"
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	//- 'Status' is also a string attribute...
	av.attr = "Status"
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	//- do the same read test with some SPECTRUM attributes. 
	//- here the value is not actually returned. upon return of the 'tango_read_attr' 
	//- function the <val_path> member of the <AttributeValue> structure points to
	//- wave containing the attribute value. we will access the wave using the "WAVE"
	//- keyword (i.e. wave reference).
	av.attr = "boolean_spectrum"
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took " + num2str(mst_dt / 1000) + " ms to complete"
	
	WAVE/Z attr_value = $av.val_path
	if (WaveExists(attr_value) == 0)
		tango_display_error_str("Oops, there is something wrong! The wave desappered!")
		return -1
	endif
  
   //- read next spectrum attribute
	av.attr = "uchar_spectrum"
	//- the previous read set 'av.val_path' to the location of the 'boolean_spectrum'
	//- (i.e. to the full path to the wave containing the boolean_spectrum value). since
	//- we always reuse the same AttributeValue (i.e. av) for reading, we have to reset
	//- the 'av.val_path' member. otherwise, the 'uchar_spectrum' value will be placed
	//- in the same location pointed the current content of 'av.val_path'. we definitively
	//- don't want 'uchar_spectrum' value to be named 'boolean_spectrum'! by reseting, 
	//- 'av.val_path' we ask the TANGO API to place the value (i.e. the wave into the 
	//- current datafolder and use the attribute name as wave name (i.e. boolean_spectrum) 
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	av.attr = "ushort_spectrum"
	av.val_path=""
	mst_ref = StartMSTimer
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	av.attr = "short_spectrum"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	av.attr = "long_spectrum"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	av.attr = "float_spectrum"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  
	av.attr = "double_spectrum"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete" 
  	
	//- and finally read some IMAGE attributes...
	//- here again the value is not actually returned. upon return of the 'tango_read_attr' 
	//- function the <val_path> member of the <AttributeValue> structure points to wave 
	//- containing the attribute value. we will access the wave using the "WAVE" keyword 
	av.attr = "boolean_image"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
 	WAVE/Z attr_value = $av.val_path
	if (WaveExists(attr_value) == 0)
		tango_display_error_str("Oops, there is something wrong! The wave desappered!")
		return -1
	endif
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  	
	av.attr = "uchar_image"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  	
	av.attr = "ushort_image"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  	
	av.attr = "short_image"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  	
	av.attr = "long_image"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  	
	av.attr = "float_image"
	av.val_path=""
	mst_ref = StartMSTimer 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  	
	av.attr = "double_image"
	av.val_path=""
	mst_ref = StartMSTimer  
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
 	mst_dt = StopMSTimer(mst_ref)
	tango_dump_attribute_value (av)
	print "\t-read took......." + num2str(mst_dt / 1000) + " ms to complete"
  	
	//- no error - great!
	print "\r<Tango-API::tango_read_attr> : TEST PASSED\r"
	
	//- for test purpose will delete any datafolder created in this function
	tools_df_delete("root:tmp")
	
	return 0
end
//==============================================================================
// TUTORIAL CHAPTER II : READING SEVERAL ATTRIBUTES
//==============================================================================
function test_tango_read_attrs (dev_name)

	//- function arg: the name of the device on which the attributes will be read
	String dev_name

	//- verbose
	print "\rStarting <Tango-API::tango_read_attrs> test...\r"
  
  	//- save the current datafolder
  	String cur_df = GetDataFolder(1)
  	
  	//- create a 'root:foo:bar' datafolder and make it the current datafolder
  	//- this function is kind enough to create all the datafolder along
  	//- the speciifed path in case they don't exist. great, isn't it?
  	tools_df_make("root:foo:bar", 1)
  	
 	//- let's declare a <AttributeValues> structure. 
 	//- this structure wil be used in our first reading example
	Struct AttributeValues avs
	
	//- for 'technical reasons', the <AttributeValues> must be initialized 
	//- this makes sure that everything is properly setup/initialized 
	//-------------------------------------------------------------------------
	//- it is possible to read up to kMAX_NUM_ATTR in one call. this 
	//- // is defined into 'Tango.ipf' and can eventually be changed
	//-------------------------------------------------------------------------
	//- in order to optimize the initialization process, we specify that
	//- we will read up to 4 attributes (note the 'nattrs=4' syntax). if
	//- we don't explicitely tell the 'tango_init_attr_vals' how many 
	//- attributes will be read, it will initialize the kMAX_NUM_ATTR
	//- <AttributeValue> structs embedded into the <AttributeValues>
	//-------------------------------------------------------------------------- 
	tango_init_attr_vals(avs, nattrs=4)
 
	//- all attributes are (obviously) read on the same device 
	avs.dev = dev_name
	
	//- specify the attributes to read and their associated location
	//----------------------------------------------------------------------------
	//- The TANGO API is really powerfull and offers several ways to 
	//- retrieve the data. This flexibility may generates some complexity.
	//- Please read the following carrefully...
	//----------------------------------------------------------------------------
	//- The <AttributeValues.df> member is used to specify in which datafolder
	//- the attribute values (i.e. waves) associated with SPECTRUMs and IMAGEs 
	//- should be created. If an empty string is passed (as set by the 
	//- 'tango_init_attr_vals' function), the waves are created into the current
	//- datafolder. Here we choose the later approach and leave the 'avs.df'
	//- empty (i.e. the default since we properly initialized our <AttributeValues>
	//- using 'tango_init_attr_vals' 
	//-----------------------------------------------------------------------------
	//- For SCALAR attributes, the value is normally returned into the 'str_val'
	//- our 'var_val' member of the <AttributeValue> struct. However, it may be 
	//- necessary to make the value 'persistent'. In this case, we want the 
	//- String or Variable object to persist into a given datafolder instead of
	//- disappearing with the <AttributeValue> when the function returns. In order
	//- to obtain this behaviour, we just have to specified the full path to the
	//- object we want to to maintain in the AttributeValue.val_path> member. In
	//- this case, the value can be both retrieve from the 'str_val' or 'var_val'
	//- member and the 'val_path' member (using a reference). 
	//-----------------------------------------------------------------------------
	//- Let's illustrate every case with an example...
	//-----------------------------------------------------------------------------
	//- we want to read 'short_scalar_ro' and make its value persist as a global
	//- variable into a 'specific_dest' datatafolder that we want to create into 
	//- the current datafolder. we also want this global variable to be named with
	//- the name of the attribute. it gives...
	//-----------------------------------------------------------------------------
	avs.vals[0].attr = "short_scalar_ro"
	avs.vals[0].val_path = GetDataFolder(1) + "specific_dest:short_scalar_ro"
	//-----------------------------------------------------------------------------
	//- let's read the 'short_spectrum_ro' attribute. since it's a SPECTRUM, its
	//- value will persist as a wave (no choice). however, we want this wave to be
	//- placed into the 'specific_dest' datatafolder and make its name changed to
	//- 'sspec_ro'(instead of using to attribute name). it gives...
	//-----------------------------------------------------------------------------
	avs.vals[1].attr = "short_spectrum_ro"
	avs.vals[1].val_path = GetDataFolder(1) + "specific_dest:sspec_ro"
	//-----------------------------------------------------------------------------
	//- we also want to read the 'short_image_ro'. again, since it's an IMAGE, its 
	//- value will persist as a wave (no choice). here we want this wave to be placed
	//- into the current datafolder and named using the attribute name. it gives...
	//-----------------------------------------------------------------------------
	avs.vals[2].attr = "short_image_ro"
	//-----------------------------------------------------------------------------
	//- finally, we add the 'Status' attribute to our reading list. here, we would 
	//- like its value to persist as a global String into 'another_dest' datatafolder 
	//- and change its name to 'status_str'. it gives...
	//-----------------------------------------------------------------------------  
	avs.vals[3].attr = "Status"
	avs.vals[3].val_path = "root:another_dest:status_str"
	//-----------------------------------------------------------------------------  
	//- in order to avoid any ambiguity be sure to always, pass the full path to
	//- the object - from root: to the actual name of the object - e.g. 
	//- root:my_df:my_var_name, root:my_wave_name, ...
	//-----------------------------------------------------------------------------
	
 	//- ok, we can finally read the attributes...
	if (tango_read_attrs (avs) == -1)
		tango_display_error()
		return -1
	endif
 
	//- make sure results are as expected: short_scalar_ro
	NVAR/Z short_scalar_v = :specific_dest:short_scalar_ro
	if (! NVAR_Exists(short_scalar_v))
		tango_display_error_str("There is no 'short_scalar_ro' variable in 'specific_dest'!")
		return -1
	endif
	//- make sure results are as expected: short_spectrum_ro
	WAVE/Z short_spectrum_w = :specific_dest:sspec_ro
	if (! WaveExists(short_spectrum_w))
		tango_display_error_str("There is no 'sspec_ro' wave in 'specific_dest'!")
		return -1
	endif
	//- make sure results are as expected: short_image_ro
	WAVE/Z short_image_w = short_image_ro
	if (! WaveExists(short_image_w))
		tango_display_error_str("There is no 'short_image_ro' wave in the current df!")
		return -1
	endif
	//- make sure results are as expected: Status
	SVAR/Z status_s = root:another_dest:status_str
	if (! SVAR_Exists(status_s))
		tango_display_error_str("There is no 'status_str' wave in 'another_dest'!")
		return -1
	endif
	
	Variable n
	for (n = 0; n < avs.nattrs; n += 1)
		tango_dump_attribute_value(avs.vals[n])
	endfor

	//- ok, we just seen how to read several attributes in one call using the <AttributeValues> 
	//- structure. while the method is easy to use and flexible, there a limitation that could
	//- make it unusable in some contexts. the Igor structures can "live" outside the context 
	//- of a function. it means that you can declare a structure in 'your' function and pass it 
	//- to any another fonction but it will be destroyed upon return of the function in which it
	//- as been created. in other words, a structure can't be global - it can't be stored as is 
	//- in a datafolder. too bad, no? 
	//- suppose you write a background task (see Igor doc for more info on this topic) and want
	//- to read the same attributes at each iteration. using the <AttributeValues> struct, you
	//- will have to rebuild the whole struct each type you enter the task function. for such
	//- contexts, the TANGO API provides the 'tango_read_attrs_list' function. this function
	//- uses a 1D or 2D text wave to specify both the attributes to read and the destination
	//- of the associated values. be aware that all values will be persistent. however, this is
	//- the kind of behaviour one need in situations such as a background task. 
	//- the idea is to create a text wave, to populate it with the names of the attributes (and
	//- optionally the specific destination of the values). since we can only read several 
	//- attributes on the SAME device, one should maintain an attribute list per device.
	//- here is some examples...      	
	//------------------------------------------------------------------------------------

  	//- create a 'root:bckg_task' datafolder and make it the current datafolder
	//- this just for example purpose (not required otherwise) 
  	tools_df_make("root:bckg_task", 1)
	
	//- here we choose to put the results into the current datafolder and use the attribute
	//- names to name the attribute values (i.e. each read attribute will be associated with
	//- a value of the same name). in this, case we just have to create a 1D text wave 
	//- containing the name of the attribute to read. it gives...
	Make/O/T/N=(4) attr_list = {"short_scalar_ro","short_spectrum_ro","short_image_ro","Status"}
 	
	//- for our 'background task' example we need to create a string containing the device name
	String/G root:bckg_task:device = dev_name
 	
	//- now suppose that we only just enter the background task...
	//-----------------------------------------------------------------------------
 	//- we have to get a ref. to both the device name string and our attribute list 
 	//- remember, thay are not supposed to have been created here 
 	SVAR my_device = root:bckg_task:device
 	Wave/T my_attr_list = root:bckg_task:attr_list 
	//- now, read the attributes...
	if (tango_read_attrs_list(my_device, my_attr_list) == -1)
		tango_display_error()
		return -1
	endif
 
	//- make sure results are as expected: short_scalar_ro
	NVAR/Z short_scalar_ro = root:bckg_task:short_scalar_ro
	if (! NVAR_Exists(short_scalar_ro))
		tango_display_error_str("Variable 'short_scalar_ro' is missing!")
		return -1
	endif
	//- make sure results are as expected: short_spectrum_ro
	Wave/Z short_spectrum_ro = root:bckg_task:short_spectrum_ro
	if (! WaveExists(short_spectrum_ro))
		tango_display_error_str("Wave 'short_spectrum_ro' is missing!")
		return -1
	endif
	//- make sure results are as expected: short_image_ro
	Wave/Z short_image_ro = root:bckg_task:short_image_ro
	if (! WaveExists(short_image_ro))
		tango_display_error_str("Wave 'short_image_ro' is missing!")
		return -1
	endif
	//- make sure results are as expected: Status
	SVAR/Z status = root:bckg_task:Status
	if (! SVAR_Exists(status))
		tango_display_error_str("String 'Status' is missing!")
		return -1
	endif
	
	//- in this second example, for ecah attribute to read we specify the destination
	//- of its associated value (location and name). in this case we need a (n,2) 2D
	//- text wave. the first column will contain the attribute to read while the second
	//- will host the destination of the associated values. simple, no?
	Make/O/T/N=(4,2) attr_list
	//- read 'short_scalar_ro' and place the its in 'root:attr_a'
	attr_list[0][0] = "short_scalar_ro"
	attr_list[0][1] = "attr_a"
	//- read 'short_spectrum_ro' and place the its in 'root:attr_b'
	attr_list[1][0] = "short_spectrum_ro"
	attr_list[1][1] = "root:mydatafolder1:attr_b"
	//- read 'short_image_ro' and place the its in 'root:attr_c'
	attr_list[2][0] = "short_image_ro"
	attr_list[2][1] = "root:mydatafolder2:attr_c"
	//- read 'Status' and place the its in 'root:attr_d'
	attr_list[3][0] = "Status"
	attr_list[4][1] = "attr_d"
	
	//- now suppose that we only just enter the background task...
	//-----------------------------------------------------------------------------
 	//- we have to get a ref. to both the device name string and our attribute list 
 	//- remember, thay are not supposed to have been created here 
 	SVAR my_device = root:bckg_task:device
 	Wave/T my_attr_list = root:bckg_task:attr_list 
	//- now, read the attributes... 
	if (tango_read_attrs_list(my_device, my_attr_list) == -1)
		tango_display_error()
		return -1
	endif
 
	//- make sure results are as expected: short_scalar_ro
	NVAR/Z short_scalar_ro = :attr_a
	if (! NVAR_Exists(short_scalar_ro))
		tango_display_error_str("Variable 'root:attr_a' is missing!")
		return -1
	endif
	//- make sure results are as expected: short_spectrum_ro
	Wave/Z short_spectrum_ro = root:mydatafolder1:attr_b
	if (! WaveExists(short_spectrum_ro))
		tango_display_error_str("Wave 'root:mydatafolder1:attr_b' is missing!")
		return -1
	endif
	//- make sure results are as expected: short_image_ro
	Wave/Z short_image_ro = root:mydatafolder2:attr_c
	if (! WaveExists(short_image_ro))
		tango_display_error_str("Wave 'root:mydatafolder2:attr_c' is missing!")
		return -1
	endif
	//- make sure results are as expected: Status
	SVAR/Z status = :attr_d
	if (! SVAR_Exists(status))
		tango_display_error_str("String 'root:attr_d' is missing!")
		return -1
	endif
	
	//- verbose
	print "\r<Tango-API::tango_read_attrs> : TEST PASSED\r"
	
	//- for test purpose will delete any datafolder created in this function
	tools_df_delete("root:foo")
	tools_df_delete("root:bckg_task")
	tools_df_delete("root:mydatafolder1")
	tools_df_delete("root:mydatafolder2")
	tools_df_delete("root:another_dest")

	SetDataFolder(cur_df);
	  	
	return 0
end 

//==============================================================================
// TUTORIAL CHAPTER III : Writting one (or more) attribute(s) on a TANGO device
//==============================================================================
// The TANGO API defines and use the same structure for both reading and writing 
// an attribue: <AttributeValue>. This structue is defined in the <Tango.ipf> file. 
//
// <AttributeValue> has the following structure:
// ---------------------------------------------
//  Structure AttributeValue
//    String dev           //- device name
//    String attr          //- attribute name
//    int16 format         //- attribute format: kSCALAR, kSPECTRUM or kIMAGE
//    int16 type           //- attribute data type : kSTRING, kLONG, kDOUBLE, ... 
//    double ts            //- timestamp in seconds since "Igor's time reference"
//    String str_val       //- attribute value for string Scalar attributes
//    Variable var_val     //- attribute value for numric Scalar attributes
//    String val_path //- full path to <wave_val> (datafolder)
//  EndStructure
//
//  When writting an attribute you must specify the device, the attribute
//  name and the value to write. Others <AttributeValue> structure members are 
//  not required.
//
//  Note about <AttributeValue.format>: 
//  -----------------------------------
//  Not used here. See previous read examples.
//  
//  Note about <AttributeValue.type>: 
//  -----------------------------------
//  Not used here. See previous read examples.
//
//  Note about <AttributeValue.ts>: 
//  -----------------------------------
//  Not used here. See previous read examples.
//
//  Note about <AttributeValue.str_val>: 
//  ------------------------------------
//  Attribute value for string <Scalar> attributes (i.e. for single string).
//
//  Note about <AttributeValue.var_val>: 
//  ------------------------------------
//  Attribute value for numeric <Scalar> attributes (i.e. for single numeric value). 
//
//  Note about <AttributeValue.wave_val>: 
//  -------------------------------------
//  Not used (and CAN'T be) used here. See previous read examples.  
//
//  Note about <AttributeValue.val_path>: 
//  ------------------------------------------
//  Full path to <wave_val> - fully qualified path (from root:) to the datafolder into 
//  which the wave to be written on the attribute is stored. This the path to the "wave value" 
// for any <Spectrum> or <Image> attributes (i.e. any array, even arrays of stings).
//
// Writting several attributes in one call 
// ---------------------------------------
// The TANGO API for Igor Pro provides a way to writ several attributes on the SAME
// device in a single call. In such a cas, the function <tango_write_attrs> is used 
// (note the 's' in the function name). In order to achieve such a magical feature,
// we need an data structure capable of storing more than one attribute value. The
// <AttributeValues> structure has been introduced for this purpose (again, note 
// the 's' in the structure name). <AttributeValues> has the following members:
//
//  Structure AttributeValues
//    String dev                                //- the name of device
//    int16 nattrs                              //- actual the num of attributes to write
//    Strut AttributeValue vals[kMAX_NUM_ATTR]  //- an array of <AttributeValues>
//  EndStructure
//
//  Note about <AttributeValues.nattrs>: 
//  ------------------------------------
//  Actual the num of attributes to read - must be <= kMAX_NUM_ATTR. Should 
//  obviously equal the number of valid <AttributeValue>s you pass in the 
//  <vals> member. Its value must be <= kMAX_NUM_ATTR. This constant is defined
//  in the Tango.ipf file and set to 16. If you need to read more than 16 
//  attributes on the SAME device, edit the Tango.ipf file and change kMAX_NUM_ATTR
//  to the appropriate value. 
//
//  Note about <AttributeValues.vals>: 
//  ----------------------------------
//  An array of kMAX_NUM_ATTR <AttributeValue> is used to stored the attribute values.
//  <AttributeValues.nattrs> "values"  must be valid in the array when the <AttributeValues>
//  is passed to the <tango_write_attrs> function. 
//
// The following <test_tango_write_attr> function gives an example for some TANGO 
// attribute type. The usage of <AttributeValue> is detailed.
// 
// TangoTest has an attribute for each TANGO type. Each attribute is named with 
// the name of the associated type.
//==============================================================================  
//==============================================================================
// TUTORIAL CHAPTER III : WRITTING ONE ATTRIBUTE
//==============================================================================
function test_tango_write_attr (dev_name)
	//- function arg: the name of the device on which the attributes will be read
	String dev_name
 
  	//- save the current datafolder
  	String cur_df = GetDataFolder(1)
 	
	//- for test purpose we do everything in temp. datafolder
	tools_df_make("root:tmp", 1)
	
	//- verbose
	print "\rStarting <Tango-API::test_tango_write_attr> test...\r"
 
	//- declare an AttributeValue struct 
	Struct AttributeValue av
	
	//- for 'technical reasons', the AttributeValue must be initialized 
	//- you now the story now...
	tango_init_attr_val(av)
 
	//- specify the target device name
	av.dev = dev_name
 
	//- let's write the numeric scalar attribute <short_scalar>...
	av.attr = "short_scalar"
 
	//- since its a numeric scalar, we store the value to write in the <var_val> 
	//- member of the AttributeValue struct. the TangoTest device is written so 
	//- that the <short_scalar> will take its "read value" in the range [0, last_write_value].
	//- here is the actual range will be [0, 100].
	av.var_val = 100
 
	//- apply the specified value...
	if (tango_write_attr(av) == -1)
		tango_display_error()
		return -1
	endif  
 
	//- now, let's write the string scalar attribute <string_scalar>...
	av.attr = "string_scalar"
	//- <string_scalar> is a single string attribute. in such a case, we store 
	//- the value to write in the <str_val> member of the AttributeValue struct
	av.str_val = "testing new write attr impl"
	//- apply the specified value... 
	if (tango_write_attr(av) == -1)
		tango_display_error()
		return -1
	endif 
	//- read back <string_scalar> 
	if (tango_read_attr (av) == -1)
		tango_display_error()
		return -1
	endif
	//- dump read result
	tango_dump_attribute_value (av)

	//- test some writable spectrum and image attributes
	Variable err = 0
	err = test_tango_write_spec_or_img (dev_name, "boolean_spectrum_ro", "boolean_spectrum")
	if (err == -1)
		return -1
	endif
	//-err = test_tango_write_spec_or_img (dev_name, "uchar_spectrum_ro", "uchar_spectrum")
	//-if (err == -1)
	//-  return -1
	//-endif
	err = test_tango_write_spec_or_img (dev_name, "short_spectrum_ro", "short_spectrum")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "ushort_spectrum_ro", "ushort_spectrum")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "long_spectrum_ro", "long_spectrum")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "float_spectrum_ro", "float_spectrum")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "double_spectrum_ro", "double_spectrum")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "boolean_image_ro", "boolean_image")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "uchar_image_ro", "uchar_image")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "short_image_ro", "short_image")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "ushort_image_ro", "ushort_image")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "long_image_ro", "long_image")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "float_image_ro", "float_image")
	if (err == -1)
		return -1
	endif
	err = test_tango_write_spec_or_img (dev_name, "double_image_ro", "double_image")
	if (err == -1)
		return -1
	endif
 
	//- no error - great!
	print "\r<Tango-API::tango_write_attr> : TEST PASSED\r"
	
	//- for test purpose will delete any datafolder created in this function
	tools_df_delete("root:tmp")
	
	//- restore previous df
	SetDataFolder(cur_df);
	
	return 0 
end
//==============================================================================
// TUTORIAL CHAPTER III : WRITTING A SPECTRUM OR IMAGE ATTRIBUTE
//==============================================================================
function test_tango_write_spec_or_img (dev_name, ro_attr, rw_attr)

	//- function arg: the name of the device on which the attributes will be read
	String dev_name
	String ro_attr
	String rw_attr
 
	Struct AttributeValue rd_av
	tango_init_attr_val(rd_av)
	rd_av.dev = dev_name
	rd_av.attr = ro_attr
  
	if (tango_read_attr (rd_av) == -1)
		tango_display_error()
		return -1
	endif
	
	WAVE wt_wave = $rd_av.val_path
  
	Struct AttributeValue wt_av
	tango_init_attr_val(wt_av)
	wt_av.dev = dev_name
	wt_av.attr = rw_attr
	wt_av.val_path = rd_av.val_path
  
	if (tango_write_attr (wt_av) == -1)
		tango_display_error()
		return -1
	endif

	if (tango_read_attr (rd_av) == -1)
		tango_display_error()
		return -1
	endif
  
	WAVE rd_wave = $rd_av.val_path
  
	//- check result except for 32 bits float
	if (!EqualWaves(rd_wave, wt_wave, 1) && (WaveType(rd_wave) & 0x2 == 0))
		tango_display_error_str("ERROR:unexpected result - waves should equal")
		return -1
	endif
end
//==============================================================================
// TUTORIAL CHAPTER III : WRITTING SEVERAL ATTRIBUTES
//==============================================================================
function test_tango_write_attrs (dev_name)
	//- function arg: the name of the device on which the attributes will be written
	String dev_name
 
	//- verbose
	print "\rStarting <Tango-API::tango_write_attrs> test...\r"
 
	Struct AttributeValues avs
	//- for 'technical reasons', the AttributeValue must be initialized 
	//- you now the story now...
	tango_init_attr_vals(avs, nattrs=3)
	
	Make/N=(10,20)/O/D root:tango_matrix = enoise(100.0)
	
	avs.dev = dev_name
	avs.vals[0].attr = "short_scalar"
	avs.vals[0].var_val = 1024
	avs.vals[1].attr = "string_scalar"
	avs.vals[1].str_val = "testing write attrs"
	avs.vals[2].attr = "double_image"
	avs.vals[2].val_path = "root:tango_matrix"
	
	if (tango_write_attrs(avs) == -1)
		tango_display_error()
		return -1
	endif
	
	//- ************** IMPORTANT NOTE - PLEASE READ *******************************
	//- read back attributes : we don't care where waves (i.e. attribute value for 
	//- SPECTRUM and IMAGE) are created by the TANGO API reading function so we pass 
	//- an empty string into <df> and don't specify any particular destination. 
	//- ***************************************************************************
	avs.df = ""
	if (tango_read_attrs (avs) == -1)
		tango_display_error()
		return -1
	endif
 
	Variable n
	for (n = 0; n < avs.nattrs; n += 1)
		tango_dump_attribute_value(avs.vals[n])
	endfor
 
	KillWaves root:tango_matrix
 
	//- no error - great!
	print "\r<Tango-API::tango_write_attrs> : TEST PASSED\r"
	return 0 
end

//==============================================================================
// tango_test_all
//==============================================================================
function tango_test_all ([dev_name, n_it])
	String dev_name
	Variable n_it
	if (ParamIsDefault(dev_name))
		dev_name = "sys/tg_test/1"
	endif
	if (ParamIsDefault(n_it))
		n_it = 1
	endif
	if (n_it < 0) 
		n_it = 1 
	endif
	String cur_df
	tango_enter_device_df(dev_name,  prev_df=cur_df)
	tools_df_make(":tmp", 1)
	Variable i
	for (i = 0; i < n_it; i += 1)
		if (test_tango_cmd_io(dev_name) == -1)
			print "\r\t**** TANGO BINDING FOR IGOR PRO - TEST FAILED ****"
			tango_leave_df(cur_df)
			return -1
		endif
		DoXOPIdle
		DoUpdate
		if (test_tango_read_attr(dev_name) == -1)
			print "\r\t**** TANGO BINDING FOR IGOR PRO - TEST FAILED ****"
			tango_leave_df(cur_df)
			return -1
		endif
		DoXOPIdle
		DoUpdate
		if (test_tango_read_attrs(dev_name) == -1)
			print "\r\t**** TANGO BINDING FOR IGOR PRO - TEST FAILED ****"
			tango_leave_df(cur_df)
			return -1
		endif
		DoXOPIdle
		DoUpdate
		if (test_tango_write_attr(dev_name) == -1)
			print "\r\t**** TANGO BINDING FOR IGOR PRO - TEST FAILED ****"
			tango_leave_df(cur_df)
			return -1
		endif
		DoXOPIdle
		DoUpdate
		if (test_tango_write_attrs(dev_name) == -1)
			print "\r\t**** TANGO BINDING FOR IGOR PRO - TEST FAILED ****"
			tango_leave_df(cur_df)
			return -1
		endif
		DoXOPIdle
		DoUpdate
	endfor
	print "\r\t**** TANGO BINDING FOR IGOR PRO - TEST PASSED ****"
	tango_leave_df(cur_df)
end

//==============================================================================
// TUTORIAL CHAPTER I : Executing a TANGO command
//------------------------------------------------------------------------------
// utility function - a generic function for testing TangoTest "num scalar" cmds
//==============================================================================
//- this function is called from test_tango_cmd_io
function test_num_scalar_cmd (dev, cmd, num_scalar_val)
	//- function args
	String dev
	String cmd
	Variable num_scalar_val
	//- local variables
	Struct CmdArgIO argin
	tango_init_cmd_argio(argin)
	Struct CmdArgIO argout
	tango_init_cmd_argio(argout)
	argin.var_val = num_scalar_val
	//- verbose
	print "\rexecuting " + cmd + "...\r"
	//- perf measurement
	Variable ms_ref = StartMSTimer
	//- actual cmd execution
	//- if an error occurs during command execution, argout is undefined (null or empty members)
	//- ALWAYS CHECK THE CMD RESULT BEFORE TRYING TO ACCESS ARGOUT: 0 means NO_ERROR, -1 means ERROR
	if (tango_cmd_inout(dev, cmd, arg_in = argin, arg_out = argout) == -1)
		//- the cmd failed, display error...
		tango_display_error()
		//- ... then return error
		return -1
	endif
	Variable mst_dt = StopMSTimer(ms_ref)
	print "\t'-> took " + num2str(mst_dt / 1000) + " ms to complete"
	//- check that <argin = argout> in order to be sure that everything is ok
	if (argin.var_val - argout.var_val != 0)
		print "\t'-> unexpected cmd result or numeric rounding side effect [error expected for fp data types]"
		print "\t'-> " + cmd + " failed!"
		//- ... then return error
		return -1
	endif
	print "\t'-> cmd passed\r"
	//- no error - great!
	return 0
end    

//==============================================================================
// TUTORIAL CHAPTER I : Executing a TANGO command
//------------------------------------------------------------------------------
// utility function - a generic function for testing TangoTest "num array" cmds
//==============================================================================
//- this function is called from test_tango_cmd_io
function test_num_array_cmd (dev, cmd)
	//- function args
	String dev
	String cmd
	//- local variables
	Struct CmdArgIO argin
	tango_init_cmd_argio(argin)
	Struct CmdArgIO argout
	tango_init_cmd_argio(argout)
	//- verbose
	print "\rexecuting " + cmd + "...\r"
	//- get wave type
	Variable wave_type = tango_argin_type_to_wave_type(dev, cmd)
	//- we can now build the argin wave   
	Make /O /N=128 /Y=(wave_type) argin_wave = enoise(1024)
	//- set path to argin wave
	argin.num_wave_path = GetWavesDataFolder(argin_wave, 2)
	//- set path to argout wave
	argout.num_wave_path = GetDataFolder(1) + "cmd_arg_out"
	//- perf test
	Variable mst_ref = StartMSTimer
	//- actual cmd execution
	//- if an error occurs during command execution, argout is undefined (null or empty members)
	//- ALWAYS CHECK THE CMD RESULT BEFORE TRYING TO ACCESS ARGOUT: 0 means NO_ERROR, -1 means ERROR
	if (tango_cmd_inout(dev, cmd, arg_in = argin, arg_out = argout) == -1)
		//- the cmd failed, display error...
		tango_display_error()
		//- ... then return error
		return -1
	endif
	Variable mst_dt = StopMSTimer(mst_ref)
	print "\t'-> took " + num2str(mst_dt / 1000) + " ms to complete"
	//- check result
	WAVE argout_wave = $argout.num_wave_path
	if (!EqualWaves(argin_wave, argout_wave, 1))
		print "\t'-> unexpected cmd result or numeric rounding side effect [error expected for fp data types]"
		print "\t'-> " + cmd + " failed!"
		//- ... then return error
		return -1
	endif
	print "\t'-> cmd passed\r"
	//- cleanup - wave no longer needed
	KillWaves/Z argin_wave, argout_wave 
	//- no error - great!
	return 0
end
