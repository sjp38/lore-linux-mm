Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A77BA6B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 22:42:25 -0400 (EDT)
Date: Tue, 10 Mar 2009 10:41:35 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090310024135.GA6832@localhost>
References: <bug-12832-27@http.bugzilla.kernel.org/> <20090307122452.bf43fbe4.akpm@linux-foundation.org> <20090307220055.6f79beb8@mjolnir.ossman.eu> <20090309013742.GA11416@localhost> <20090309020701.GA381@localhost> <20090309084045.2c652fbf@mjolnir.ossman.eu> <20090309142241.GA4437@localhost> <20090309160216.2048e898@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090309160216.2048e898@mjolnir.ossman.eu>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 09, 2009 at 05:02:16PM +0200, Pierre Ossman wrote:
> On Mon, 9 Mar 2009 22:22:41 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
>
> >
> > Thanks for the data! Now it seems that some pages are totally missing
> > from bootmem or slabs or page cache or any application consumptions...
> >
>
> So it isn't just me that's blind. That's something I guess. :)
>
> > Will searching through /proc/kpageflags for reserved pages help
> > identify the problem?
> >
> > Oh kpageflags_read() does not include support for PG_reserved:
> >
>
> I can probably hack together something that outputs the served pages.
> Anything else that is of interest?

Sure, Matt Mackall provides some example scripts for interpreting the
kpageflags file:

        http://selenic.com/repo/pagemap/

> > > DirectMap2M:  18446744073709551613
> >
> > This field looks weird.
> >
>
> Sorry, red herring. I'm in the middle of a bisect and that particular
> old bug happened to surface. It was not present with the releases
> 2.6.27.

That's OK.

        pgfault 25624481
        pgmajfault 2490
        pgrefill_dma 8144
        pgrefill_dma32 103508
        pgsteal_dma 4503
        pgsteal_dma32 179395
        pgscan_kswapd_dma 4999
        pgscan_kswapd_dma32 180546
        pgscan_direct_dma32 384
        slabs_scanned 153856

The above vmstat numbers are a bit large, maybe it's not a fresh booted system?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
