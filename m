Date: Sat, 28 Feb 2004 02:38:47 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: mapped page in prep_new_page()..
Message-ID: <20040227153846.GO5801@krispykreme>
References: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org> <20040226225809.669d275a.akpm@osdl.org> <Pine.LNX.4.58.0402262305000.2563@ppc970.osdl.org> <1077878329.22925.321.camel@gaston> <Pine.LNX.4.58.0402270709152.2563@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0402270709152.2563@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, hch@infradead.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> Yeah, that makes complete sense now. "DAR" and "300 trap". I should have 
> seen it immediately.

Glad you see it our way. Want a job at IBM?

...
 
> and here's what ppc64 prints out:
> 
> 	Oops: Kernel access of bad area, sig: 11 [#1]
> 	NIP: C00000000008D7C4 XER: 0000000020000000 LR: C000000000086F70
> 	REGS: c00000007a43b7f0 TRAP: 0300    Not tainted
> 	...
> 
> And I'm sure it's clear as glass what that's all about.

Yeah it needs to be made clearer. We are also missing a dump of a few
instructions around the fail, especially useful when you dont have the
vmlinux or the fail is in modules somewhere.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
