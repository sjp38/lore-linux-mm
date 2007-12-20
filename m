Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by relay2.corp.sgi.com (Postfix) with ESMTP id D56973040A1
	for <linux-mm@kvack.org>; Thu, 20 Dec 2007 09:05:19 -0800 (PST)
Message-ID: <476AA0CF.4080201@sgi.com>
Date: Thu, 20 Dec 2007 09:05:19 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: [Fwd: [linux-engr] build errors in 2.6.24-rc5-mm1?]
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Does anyone have any idea why I'm getting build errors with the current
2.6.24-rc5-mm1?  Could it be a gcc version problem?  I've looked
through the notes but didn't see anything pertaining to this problem.

linux-2.6.24-rc5-mm1/arch/x86/vdso/vdso32/sigreturn.S: Assembler messages:
linux-2.6.24-rc5-mm1/arch/x86/vdso/vdso32/sigreturn.S:23: Error: suffix or operands invalid for `pop'
linux-2.6.24-rc5-mm1/arch/x86/vdso/vdso32/syscall.S:18: Error: suffix or operands invalid for `push'
linux-2.6.24-rc5-mm1/arch/x86/vdso/vdso32/syscall.S:25: Error: suffix or operands invalid for `pop'

arch/x86/vdso/vdso32/sigreturn.S:
 22 .LSTART_sigreturn:
 23         popl %eax               /* XXX does this mean it needs unwind info? */
 24         movl $__NR_sigreturn, %eax

arch/x86/vdso/vdso32/syscall.S:
 17 .LSTART_vsyscall:
 18         push    %ebp
 19 .Lpush_ebp:

 24         movl    %ebp, %ecx
 25         popl    %ebp
 26 .Lpop_ebp:

Thanks!
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
