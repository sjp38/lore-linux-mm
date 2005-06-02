Date: Thu, 2 Jun 2005 22:02:13 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.6.12-rc4-mm2
Message-ID: <20050602220213.D3468@flint.arm.linux.org.uk>
References: <20050516130048.6f6947c1.akpm@osdl.org> <20050516210655.E634@flint.arm.linux.org.uk> <030401c55a6e$34e67cb0$0f01a8c0@max> <20050516163900.6daedc40.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050516163900.6daedc40.akpm@osdl.org>; from akpm@osdl.org on Mon, May 16, 2005 at 04:39:00PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Richard Purdie <rpurdie@rpsys.net>, Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 16, 2005 at 04:39:00PM -0700, Andrew Morton wrote:
> (cc's added)
> 
> "Richard Purdie" <rpurdie@rpsys.net> wrote:
> >
> > Russell King:
> > > On Mon, May 16, 2005 at 01:00:48PM -0700, Andrew Morton wrote:
> > >> Any idea why init is trying to exit?
> > >
> > > I was hoping you weren't going to ask me.
> > >
> > > Not really.  My initial thoughts would be maybe init getting a SEGV
> > > or ILL, but normally when that happens the system is thrown into an
> > > infinite loop because of the "init is specal and doesn't get any
> > > signals it hasn't claimed" rule.  Or at least that's what happens
> > > with conventional sysvinit.  However, I've no idea what or how the
> > > embedded init program behaves in this respect - never had that
> > > experience yet.
> > >
> > > I guess Richard needs to work through the patch sets between the
> > > last version which worked and the next which didn't.
> > 
> > After some investigation, the guilty patch is:
> > avoiding-mmap-fragmentation.patch
> > (and hence) avoiding-mmap-fragmentation-tidy.patch
> > 
> > For reference, whilst debugging the error from init changed to: 
> > "inconsistency detected by ld.so: ../sysdeps/generic/dl-cache.c: 235: 
> > _dl_load_cache_lookup: Assertion `cache != ((void *)0)` failed!" which would 
> > agree with some kind of memory corruption.
> > 
> > Its a bit late for me to try and debug this further and I'm not sure I know 
> > the mm layer well enough to do so anyway. With these patches removed, -mm1 
> > boots fine. I'm confident the same will apply to -mm2.
> 
> Great, thanks.
> 
> Wolfgang, we broke ARM.

I'm not sure what happened with this, but there's someone reporting that
-rc5-mm1 doesn't work.  Unfortunately, there's not a lot to go on:

http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2005-May/029188.html

Could be unrelated for all I know.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
