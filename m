Date: Fri, 27 Feb 2004 18:31:27 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: mapped page in prep_new_page()..
Message-ID: <20040227073127.GC5801@krispykreme>
References: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org> <20040226225809.669d275a.akpm@osdl.org> <Pine.LNX.4.58.0402262305000.2563@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0402262305000.2563@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, hch@infradead.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

 
> Yeah, I wouldn't be surprised if it is an architecture bug (possibly 
> one that has been common but has long been fixed on x86).

Its possible, I think Ive seen this before on a pseries box before.
 
> The ppc64 page fault oops thing seems to be braindead, and not even print 
> out the address. Stupid. Somebody is too used to debuggers, and as a 
> result users aren't helped to make good reports, hint hint..

DAR is the address. I should probably make it more obvious, Ive been
somewhat IBMized with my TLAs.

> Who would write the value quadword 0x0000005F00000000 to the physical
> address 1<<24? And is that a valid "struct page *" in the first place? 
> Probably. 
> 
> Bad pointer crapola? Or some subtle CPU bug with address arithmetic that
> crosses the 16MB border?  Anton, BenH, any ideas?

Interesting, but nothing springs to mind yet.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
