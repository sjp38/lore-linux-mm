Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8610F6B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 21:34:22 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id 5so72695350igt.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 18:34:22 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 69si37651726ioc.181.2016.02.21.18.34.21
        for <linux-mm@kvack.org>;
        Sun, 21 Feb 2016 18:34:22 -0800 (PST)
Date: Mon, 22 Feb 2016 11:34:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160222023432.GC27829@bbox>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222002515.GB21710@bbox>
 <20160222004758.GB4958@swordfish>
 <20160222013442.GB27829@bbox>
 <20160222020113.GB488@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160222020113.GB488@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 11:01:13AM +0900, Sergey Senozhatsky wrote:
> On (02/22/16 10:34), Minchan Kim wrote:
> [..]
> > > > I tempted it several times with same reason you pointed out.
> > > > But my worry was that if we increase ZS_MAX_ZSPAGE_ORDER, zram can
> > > > consume more memory because we need several pages chain to populate
> > > > just a object. Even, at that time, we didn't have compaction scheme
> > > > so fragmentation of object in zspage is huge pain to waste memory.
> > > 
> > > well, the thing is -- we end up requesting less pages after all, so
> > > zsmalloc has better chances to survive. for example, gcc5 compilation test
> > 
> > Indeed. I saw your test result.
> 
> 
> [..]
> > >  Total               129          489       1627756    1618193     850147
> > > 
> > > 
> > > that's  891703 - 850147 = 41556 less pages. or 162MB less memory used.
> > > 41556 less pages means that zsmalloc had 41556 less chances to fail.
> > 
> > 
> > Let's think swap-case which is more important for zram now. As you know,
> > most of usecase are swap in embedded world.
> > Do we really need 16 pages allocator for just less PAGE_SIZE objet
> > at the moment which is really heavy memory pressure?
> 
> I'll take a look at dynamic class page addition.

Thanks, Sergey.

Just a note:

I am preparing zsmalloc migration now and almost done so I hope
I can send it within two weeks. In there, I changed a lot of
things in zsmalloc, page chaining, struct page fields usecases
and locking scheme and so on. The zsmalloc fragment/migration
is really painful now so we should solve it first so I hope
you help to review that and let's go further dynamic chaining
after that, please. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
