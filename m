Date: Sat, 8 Nov 2008 16:00:48 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/9] vmalloc fixes and improvements
Message-ID: <20081108150048.GA2969@cmpxchg.org>
References: <20081108021512.686515000@suse.de> <alpine.LFD.2.00.0811072109550.3468@nehalem.linux-foundation.org> <20081108054144.GB24308@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081108054144.GB24308@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>

On Sat, Nov 08, 2008 at 06:41:44AM +0100, Nick Piggin wrote:
> On Fri, Nov 07, 2008 at 09:13:38PM -0800, Linus Torvalds wrote:
> > 
> > 
> > On Sat, 8 Nov 2008, npiggin@suse.de wrote:
> > > 
> > > The following patches are a set of fixes and improvements for the vmap
> > > layer.
> > 
> > They seem seriously buggered.
> > 
> > Patches that seem to be authorted by others (judging by sign-off) have no 
> > such attribution. And because you apparently use some sh*t-for-emailer, 
> > the patches that _are_ yours are missing your name, because it just says
> > 
> > 	From: npiggin@suse.de
> > 
> > without any "Nick Piggin" there.
> > 
> > I'd suggest fixing your emailer scripts regardless, but a "From: " at the 
> > top of the body would fix both the attribution to others, and give you a 
> > name too.
> 
> I thought when there is no From in the body, then it defaults to the first
> Signed-off-by:. At least Andrew's scripts IIRC have got that right? (unless
> it is Andrew fixing it manually).

I thought just the last From: line in the raw email text, including
both headers and body.  So it defaults to the header which your mua
sets automatically or you override it with an extra From:-line in the
body to attribute authorship to somebody else.

But you apperently just need to set a --from switch in .quiltrc's
QUILT_MAIL_ARGS.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
