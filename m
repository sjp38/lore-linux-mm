Date: Tue, 29 Mar 2005 00:22:51 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/4] sparsemem intro patches
Message-ID: <20050328222251.GF1389@elf.ucw.cz>
References: <1110834883.19340.47.camel@localhost> <20050319193345.GE1504@openzaurus.ucw.cz> <1112045005.2087.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1112045005.2087.38.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi!

> > > Three of these are i386-only, but one of them reorganizes the macros
> > > used to manage the space in page->flags, and will affect all platforms.
> > > There are analogous patches to the i386 ones for ppc64, ia64, and
> > > x86_64, but those will be submitted by the normal arch maintainers.
> > > 
> > > The combination of the four patches has been test-booted on a variety of
> > > i386 hardware, and compiled for ppc64, i386, and x86-64 with about 17
> > > different .configs.  It's also been runtime-tested on ia64 configs (with
> > > more patches on top).
> > 
> > Could you try swsusp on i386, too?
> 
> Runtime, or just compiling?  
> 
> Have you noticed a real problem?

I'd prefer runtime, but.... No, I did not notice anything, but in past
we have some "interesting" problems with discontigmem... and this
looks similar.
								Pavel
-- 
People were complaining that M$ turns users into beta-testers...
...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
