Date: Fri, 27 Feb 2004 07:32:57 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: mapped page in prep_new_page()..
In-Reply-To: <1077878329.22925.321.camel@gaston>
Message-ID: <Pine.LNX.4.58.0402270709152.2563@ppc970.osdl.org>
References: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org>
 <20040226225809.669d275a.akpm@osdl.org>  <Pine.LNX.4.58.0402262305000.2563@ppc970.osdl.org>
 <1077878329.22925.321.camel@gaston>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@osdl.org>, hch@infradead.org, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>


On Fri, 27 Feb 2004, Benjamin Herrenschmidt wrote:
>
> > Heh. I've had this G5 thing for a couple of weeks, I'm not very good at 
> > reading the oops dump either ;)
> 
> DAR is the access address for a 300 trap

Yeah, that makes complete sense now. "DAR" and "300 trap". I should have 
seen it immediately.

I'm not entirely sure if it's just me being very very used to x86, but
let's see what Linux historically (ie on an x86) prints out on a kernel
page fault:

	Unable to handle kernel paging request at virtual address 41648370
	printing eip:
	c013f6bc 
	...

and here's what ppc64 prints out:

	Oops: Kernel access of bad area, sig: 11 [#1]
	NIP: C00000000008D7C4 XER: 0000000020000000 LR: C000000000086F70
	REGS: c00000007a43b7f0 TRAP: 0300    Not tainted
	...

And I'm sure it's clear as glass what that's all about.

Can you read your assembly language too? IBM people must just be smarter 
than the rest of us. 

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
