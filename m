From: Jan De Luyck <lkml@kcore.org>
Subject: Re: 2.5.74-mm3
Date: Wed, 9 Jul 2003 13:23:54 +0200
References: <20030708223548.791247f5.akpm@osdl.org> <20030709021849.31eb3aec.akpm@osdl.org> <200307091138.07580.m.c.p@wolk-project.de>
In-Reply-To: <200307091138.07580.m.c.p@wolk-project.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307091323.54686.lkml@kcore.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc-Christian Petersen <m.c.p@wolk-project.de>, Andrew Morton <akpm@osdl.org>, Thomas Schlichter <schlicht@uni-mannheim.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 09 July 2003 11:38, Marc-Christian Petersen wrote:
>
> better use the attached one ;)
>
> ciao, Marc

Still bombs out:

  CC [M]  arch/i386/kernel/apm.o
arch/i386/kernel/apm.c: In function `apm_bios_call':
arch/i386/kernel/apm.c:601: error: syntax error before '{' token
arch/i386/kernel/apm.c:595: warning: unused variable `saved_fs'
arch/i386/kernel/apm.c:595: warning: unused variable `saved_gs'
arch/i386/kernel/apm.c:596: warning: unused variable `flags'
arch/i386/kernel/apm.c:598: warning: unused variable `cpu'
arch/i386/kernel/apm.c:599: warning: unused variable `save_desc_40'
arch/i386/kernel/apm.c: At top level:
arch/i386/kernel/apm.c:603: warning: type defaults to `int' in declaration of 
`cpu'
arch/i386/kernel/apm.c:603: error: braced-group within expression allowed only 
inside a function
arch/i386/kernel/apm.c:603: error: syntax error before ')' token
arch/i386/kernel/apm.c:604: warning: type defaults to `int' in declaration of 
`save_desc_40'
arch/i386/kernel/apm.c:604: error: incompatible types in initialization
arch/i386/kernel/apm.c:604: error: initializer element is not constant
arch/i386/kernel/apm.c:604: warning: data definition has no type or storage 
class
arch/i386/kernel/apm.c:605: warning: type defaults to `int' in declaration of 
`cpu_gdt_table'
arch/i386/kernel/apm.c:605: error: variable-size type declared outside of any 
function
arch/i386/kernel/apm.c:605: error: variable-sized object may not be 
initialized
arch/i386/kernel/apm.c:605: error: conflicting types for `cpu_gdt_table'
include/asm/desc.h:14: error: previous declaration of `cpu_gdt_table'
arch/i386/kernel/apm.c:605: warning: data definition has no type or storage 
class
arch/i386/kernel/apm.c:607: error: syntax error before "do"
arch/i386/kernel/apm.c:607: error: `flags' undeclared here (not in a function)
arch/i386/kernel/apm.c:607: warning: type defaults to `int' in declaration of 
`__dummy2'
arch/i386/kernel/apm.c:607: error: syntax error before "void"
arch/i386/kernel/apm.c:609: error: syntax error before "volatile"
arch/i386/kernel/apm.c:610: warning: type defaults to `int' in declaration of 
`apm_bios_call_asm'
arch/i386/kernel/apm.c:610: warning: parameter names (without types) in 
function declaration
arch/i386/kernel/apm.c:610: error: conflicting types for `apm_bios_call_asm'
include/asm-i386/mach-default/apm.h:31: error: previous declaration of 
`apm_bios_call_asm'
arch/i386/kernel/apm.c:610: warning: data definition has no type or storage 
class
arch/i386/kernel/apm.c:611: error: syntax error before "volatile"
arch/i386/kernel/apm.c:612: error: `flags' undeclared here (not in a function)
arch/i386/kernel/apm.c:612: warning: type defaults to `int' in declaration of 
`__dummy2'
arch/i386/kernel/apm.c:612: error: syntax error before "void"
arch/i386/kernel/apm.c:613: warning: type defaults to `int' in declaration of 
`cpu_gdt_table'
arch/i386/kernel/apm.c:613: error: variable-size type declared outside of any 
function
arch/i386/kernel/apm.c:613: error: variable-sized object may not be 
initialized
arch/i386/kernel/apm.c:613: warning: data definition has no type or storage 
class
arch/i386/kernel/apm.c:614: error: syntax error before "do"
arch/i386/kernel/apm.c: In function `apm_bios_call_simple':
arch/i386/kernel/apm.c:644: error: syntax error before '{' token
arch/i386/kernel/apm.c:636: warning: unused variable `error'
arch/i386/kernel/apm.c:637: warning: unused variable `saved_fs'
arch/i386/kernel/apm.c:637: warning: unused variable `saved_gs'
arch/i386/kernel/apm.c:638: warning: unused variable `flags'
arch/i386/kernel/apm.c:640: warning: unused variable `cpu'
arch/i386/kernel/apm.c:641: warning: unused variable `save_desc_40'
arch/i386/kernel/apm.c: At top level:
arch/i386/kernel/apm.c:646: warning: type defaults to `int' in declaration of 
`cpu'
arch/i386/kernel/apm.c:646: error: redefinition of `cpu'
arch/i386/kernel/apm.c:603: error: `cpu' previously defined here
arch/i386/kernel/apm.c:646: error: braced-group within expression allowed only 
inside a function
arch/i386/kernel/apm.c:646: error: syntax error before ')' token
arch/i386/kernel/apm.c:647: warning: type defaults to `int' in declaration of 
`save_desc_40'
arch/i386/kernel/apm.c:647: error: redefinition of `save_desc_40'
arch/i386/kernel/apm.c:604: error: `save_desc_40' previously defined here
arch/i386/kernel/apm.c:647: error: initializer element is not constant
arch/i386/kernel/apm.c:647: warning: data definition has no type or storage 
class
arch/i386/kernel/apm.c:648: warning: type defaults to `int' in declaration of 
`cpu_gdt_table'
arch/i386/kernel/apm.c:648: error: variable-size type declared outside of any 
function
arch/i386/kernel/apm.c:648: error: variable-sized object may not be 
initialized
arch/i386/kernel/apm.c:648: warning: data definition has no type or storage 
class
arch/i386/kernel/apm.c:650: error: syntax error before "do"
arch/i386/kernel/apm.c:650: error: `flags' undeclared here (not in a function)
arch/i386/kernel/apm.c:650: warning: type defaults to `int' in declaration of 
`__dummy2'
arch/i386/kernel/apm.c:650: error: syntax error before "void"
arch/i386/kernel/apm.c:652: error: syntax error before "volatile"
arch/i386/kernel/apm.c:653: warning: type defaults to `int' in declaration of 
`error'
arch/i386/kernel/apm.c:653: error: `func' undeclared here (not in a function)
arch/i386/kernel/apm.c:653: error: `ebx_in' undeclared here (not in a 
function)
arch/i386/kernel/apm.c:653: error: `ecx_in' undeclared here (not in a 
function)
arch/i386/kernel/apm.c:653: error: `eax' undeclared here (not in a function)
arch/i386/kernel/apm.c:653: error: initializer element is not constant
arch/i386/kernel/apm.c:653: warning: data definition has no type or storage 
class
arch/i386/kernel/apm.c:654: error: syntax error before "volatile"
arch/i386/kernel/apm.c:655: error: `flags' undeclared here (not in a function)
arch/i386/kernel/apm.c:655: warning: type defaults to `int' in declaration of 
`__dummy2'
arch/i386/kernel/apm.c:655: error: syntax error before "void"
arch/i386/kernel/apm.c:656: warning: type defaults to `int' in declaration of 
`cpu_gdt_table'
arch/i386/kernel/apm.c:656: error: conflicting types for `cpu_gdt_table'
arch/i386/kernel/apm.c:648: error: previous declaration of `cpu_gdt_table'
arch/i386/kernel/apm.c:656: warning: data definition has no type or storage 
class
arch/i386/kernel/apm.c:657: error: syntax error before "do"
arch/i386/kernel/apm.c: In function `apm_power_off':
arch/i386/kernel/apm.c:922: warning: braces around scalar initializer
arch/i386/kernel/apm.c:922: warning: (near initialization for `(anonymous)')
arch/i386/kernel/apm.c:922: error: array index in non-array initializer
arch/i386/kernel/apm.c:922: error: (near initialization for `(anonymous)')
arch/i386/kernel/apm.c:922: error: invalid initializer
arch/i386/kernel/apm.c:922: error: (near initialization for `(anonymous)')
{standard input}: Assembler messages:
{standard input}:502: Error: symbol `cpu' is already defined
{standard input}:508: Error: symbol `save_desc_40' is already defined
make[2]: *** [arch/i386/kernel/apm.o] Error 1
make[1]: *** [arch/i386/kernel] Error 2
make[1]: Leaving directory `/usr/src/linux'
make: *** [stamp-build] Error 2
laptop:/usr/src/linux# '

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
