Subject: 2.6.5-rc2-mm1: entry.S - Error: missing separator (Fedora AMD64
	Core Release 1)
From: Piet Delaney <piet@www.piet.net>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 23 Mar 2004 23:50:53 -0800
Message-Id: <1080114653.18957.1870.camel@www.piet.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: fedora-devel-list@redhat.com, George Anzinger <george@mvista.com>, 64bit_fedora@comcast.net, piet <piet@www.piet.net>
List-ID: <linux-mm.kvack.org>

I built 2.6.5-rc2 and it's running fine on a amd64 installed with
Fedora Core 1. Unfortunately the mm1 patch is giving me an assembler
error when macros with args are invoked in: 

---------------------------------------------------------
       linux-2.6.5-rc2-mm1/arch/x86_64/kernel/entry.S:
---------------------------------------------------------
279 hammer 20:37 /usr/src/linux-2.6.5-rc2-mm1> gmake
gmake[1]: `arch/x86_64/kernel/asm-offsets.s' is up to date.
  CHK     include/linux/compile.h
  AS      arch/x86_64/kernel/entry.o
arch/x86_64/kernel/entry.S: Assembler messages:
arch/x86_64/kernel/entry.S:184: Error: missing separator
arch/x86_64/kernel/entry.S:434: Error: missing separator
arch/x86_64/kernel/entry.S:540: Error: missing separator
arch/x86_64/kernel/entry.S:543: Error: missing separator
arch/x86_64/kernel/entry.S:546: Error: missing separator
arch/x86_64/kernel/entry.S:551: Error: missing separator
arch/x86_64/kernel/entry.S:554: Error: missing separator
arch/x86_64/kernel/entry.S:557: Error: missing separator
arch/x86_64/kernel/entry.S:719: Error: missing separator
arch/x86_64/kernel/entry.S:778: Error: missing separator
arch/x86_64/kernel/entry.S:806: Error: missing separator
arch/x86_64/kernel/entry.S:819: Error: missing separator
arch/x86_64/kernel/entry.S:872: Error: missing separator
arch/x86_64/kernel/entry.S:888: Error: missing separator
arch/x86_64/kernel/entry.S:912: Error: missing separator
gmake[1]: *** [arch/x86_64/kernel/entry.o] Error 1
gmake: *** [arch/x86_64/kernel] Error 2
------------------------------------------------------------

For example, the first error at line 184 is the invocation
of the SAVE_ARGS macro:

    178 ENTRY(system_call)
    179         CFI_STARTPROC
    180         swapgs
    181         movq    %rsp,%gs:pda_oldrsp
    182         movq    %gs:pda_kernelstack,%rsp
    183         sti
    184         SAVE_ARGS 8,1				<------- HERE
    185         movq  %rax,ORIG_RAX-ARGOFFSET(%rsp)
    186         movq  %rcx,RIP-ARGOFFSET(%rsp)
    187         GET_THREAD_INFO(%rcx)

The same code without the mm1 patch is identical.

-piet




-- 
piet@www.piet.net

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
