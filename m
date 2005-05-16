Date: Mon, 16 May 2005 16:39:00 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.12-rc4-mm2
Message-Id: <20050516163900.6daedc40.akpm@osdl.org>
In-Reply-To: <030401c55a6e$34e67cb0$0f01a8c0@max>
References: <20050516130048.6f6947c1.akpm@osdl.org>
	<20050516210655.E634@flint.arm.linux.org.uk>
	<030401c55a6e$34e67cb0$0f01a8c0@max>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Purdie <rpurdie@rpsys.net>
Cc: rmk@arm.linux.org.uk, Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(cc's added)

"Richard Purdie" <rpurdie@rpsys.net> wrote:
>
> Russell King:
> > On Mon, May 16, 2005 at 01:00:48PM -0700, Andrew Morton wrote:
> >> Any idea why init is trying to exit?
> >
> > I was hoping you weren't going to ask me.
> >
> > Not really.  My initial thoughts would be maybe init getting a SEGV
> > or ILL, but normally when that happens the system is thrown into an
> > infinite loop because of the "init is specal and doesn't get any
> > signals it hasn't claimed" rule.  Or at least that's what happens
> > with conventional sysvinit.  However, I've no idea what or how the
> > embedded init program behaves in this respect - never had that
> > experience yet.
> >
> > I guess Richard needs to work through the patch sets between the
> > last version which worked and the next which didn't.
> 
> After some investigation, the guilty patch is:
> avoiding-mmap-fragmentation.patch
> (and hence) avoiding-mmap-fragmentation-tidy.patch
> 
> For reference, whilst debugging the error from init changed to: 
> "inconsistency detected by ld.so: ../sysdeps/generic/dl-cache.c: 235: 
> _dl_load_cache_lookup: Assertion `cache != ((void *)0)` failed!" which would 
> agree with some kind of memory corruption.
> 
> Its a bit late for me to try and debug this further and I'm not sure I know 
> the mm layer well enough to do so anyway. With these patches removed, -mm1 
> boots fine. I'm confident the same will apply to -mm2.

Great, thanks.

Wolfgang, we broke ARM.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
