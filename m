Date: Fri, 14 Nov 2003 19:55:51 -0500 (EST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: 2.6.0-test9-mm3
In-Reply-To: <Pine.LNX.4.44.0311141344290.5877-100000@home.osdl.org>
Message-ID: <Pine.LNX.4.53.0311141954160.27998@montezuma.fsmlabs.com>
References: <Pine.LNX.4.44.0311141344290.5877-100000@home.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Nov 2003, Linus Torvalds wrote:

> Triple faults you can't debug, they raise a line outside the CPU, and 
> normal PC hardware will cause that to just trigger a reboot.
> 
> But double faults do get caught, and that debugging stuff actually is in
> the standard kernel. It won't give _nearly_ as good a debug report as a
> "normal" oops, since I didn't want the double-fault handler to touch
> anything even remotely unsafe, but it often gives a good hint about what
> might be wrong. Certainly better than triple-faulting did (which we still
> do for _catastrophic_ corruption, eg totally munged kernel page tables etc
> - it's just very hard to avoid once you get corrupted enough).

"Catastrophic" seems to be rather apt here. 2.6.0-test8-mm1 produced the 
following, i'm still doing a binary search.

Unable to handle kernel paging request at virtual address 00002000
 printing eip:
00007341
*pde = 00000000
Oops: 0004 [#1]
PREEMPT SMP DEBUG_PAGEALLOC
CPU:    0
EIP:    c000:[<00007341>]    Not tainted VLI
EFLAGS: 00033246
EIP is at 0x7341
eax: 32454256   ebx: 00000000   ecx: 00000000   edx: 00000000
esi: 00000000   edi: 00002000   ebp: 00000fd6   esp: 08763f24
ds: 0000   es: 0000   ss: 0068
Process X (pid: 939, threadinfo=08762000 task=0890b330)
Stack: 00000fcb 00000100 00000000 0000c000 00000000 00000000 00000000 00000000
       00000005 ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff
       ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff
Call Trace:

Code:  Bad EIP value.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
