Date: Fri, 14 Nov 2003 16:37:24 -0500 (EST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: 2.6.0-test9-mm3
In-Reply-To: <103290000.1068847073@flay>
Message-ID: <Pine.LNX.4.53.0311141635290.27998@montezuma.fsmlabs.com>
References: <20031112233002.436f5d0c.akpm@osdl.org> <3210000.1068786449@[10.10.2.4]>
 <Pine.LNX.4.53.0311141555130.27998@montezuma.fsmlabs.com> <103290000.1068847073@flay>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Nov 2003, Martin J. Bligh wrote:

> >> > - Several ext2 and ext3 allocator fixes.  These need serious testing on big
> >> >   SMP.
> >> 
> >> Survives kernbench and SDET on ext2 at least on 16-way. I'll try ext3
> >> later.
> > 
> > It's actually triple faulting my laptop (K6 family=5 model=8 step=12) when 
> > i have CONFIG_X86_4G enabled and try and run X11. The same kernel is fine 
> > on all my other test boxes. Any hints?
> 
> Linus had some debug thing for triple faults, a few months ago, IIRC ...
> probably in the archives somewhere ...

It should all be in the kernel right now; arch/i386/kernel/doublefault.c 
but i think i may be a bit low on luck =)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
