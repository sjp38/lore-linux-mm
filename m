Date: Tue, 18 Nov 2003 07:47:04 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH][2.6-mm] Fix 4G/4G X11/vm86 oops
In-Reply-To: <Pine.LNX.4.53.0311180215040.11537@montezuma.fsmlabs.com>
Message-ID: <Pine.LNX.4.44.0311180743330.14133-100000@home.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Nov 2003, Zwane Mwaikambo wrote:
> 
> Another note from our avian friends; i seem to have sent a slightly 
> different dump from the patch, although they do both achieve the same 
> effect. I shall append it for completeness.

Hmm. I don't see anything. However, it's a lot easier to read the
gcc-generated assembly ("make arch/i386/kernel/vm86.s") than it is to read
the objdump disassembly.

It's also a lot easier to see what the assembly language is when giving 
the

	-fno-reorder-blocks

switch to gcc. Without it, modern gcc's tend to have _way_ too many jumps 
around. But maybe that actually changes the behaviour too.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
