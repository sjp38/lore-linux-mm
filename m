Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 840176B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 20:59:56 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id c10so86510058pfc.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 17:59:56 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id g15si36060124pfg.40.2016.02.21.17.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 17:59:55 -0800 (PST)
Received: by mail-pf0-x233.google.com with SMTP id e127so83933301pfe.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 17:59:55 -0800 (PST)
Date: Mon, 22 Feb 2016 11:01:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160222020113.GB488@swordfish>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222002515.GB21710@bbox>
 <20160222004758.GB4958@swordfish>
 <20160222013442.GB27829@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222013442.GB27829@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (02/22/16 10:34), Minchan Kim wrote:
[..]
> > > I tempted it several times with same reason you pointed out.
> > > But my worry was that if we increase ZS_MAX_ZSPAGE_ORDER, zram can
> > > consume more memory because we need several pages chain to populate
> > > just a object. Even, at that time, we didn't have compaction scheme
> > > so fragmentation of object in zspage is huge pain to waste memory.
> > 
> > well, the thing is -- we end up requesting less pages after all, so
> > zsmalloc has better chances to survive. for example, gcc5 compilation test
> 
> Indeed. I saw your test result.


[..]
> >  Total               129          489       1627756    1618193     850147
> > 
> > 
> > that's  891703 - 850147 = 41556 less pages. or 162MB less memory used.
> > 41556 less pages means that zsmalloc had 41556 less chances to fail.
> 
> 
> Let's think swap-case which is more important for zram now. As you know,
> most of usecase are swap in embedded world.
> Do we really need 16 pages allocator for just less PAGE_SIZE objet
> at the moment which is really heavy memory pressure?

I'll take a look at dynamic class page addition.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
