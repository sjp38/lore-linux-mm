Date: 23 May 2004 16:33:31 +0200
Date: Sun, 23 May 2004 16:33:31 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: current -linus tree dies on x86_64
Message-ID: <20040523143331.GB33866@colin2.muc.de>
References: <20040522144857.3af1fc2c.akpm@osdl.org> <20040522235831.7bdb509d.akpm@osdl.org> <20040523012149.68fcde6d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040523012149.68fcde6d.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: ak@muc.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 23, 2004 at 01:21:49AM -0700, Andrew Morton wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > Andrew Morton <akpm@osdl.org> wrote:
> >  >
> >  > As soon as I put in enough memory pressure to start swapping it oopses in
> >  >  release_pages().
> > 
> >  I'm doing the bsearch on this.
> 
> The crash is caused by the below changeset.  I was using my own .config so
> the defconfig update is not the cause.  I guess either the pageattr.c
> changes or the instruction replacements.  The lesson here is to split dem
> patches up a bit!
> 
> Anyway.  Over to you, Andi.

Thanks for the report. Will look at it later tonight.

The only known problem right now is that the pageattr.c changes
seem to be miscompiled by the redhat compiler (but work with 
other compilers). But this sounds differently.

I am still quite puzzled that this patch causes so many problems,
if you look through it most changes are harmless cleanups or 
fixes only for very specific hardware configurations.

But to double check could you just revert the pageattr.c hunk
and see if that changes anything?

-Andi 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
