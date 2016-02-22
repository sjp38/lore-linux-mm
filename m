Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 555386B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 23:41:32 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id x65so85891507pfb.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 20:41:32 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q201si32488305pfq.39.2016.02.21.20.41.30
        for <linux-mm@kvack.org>;
        Sun, 21 Feb 2016 20:41:31 -0800 (PST)
Date: Mon, 22 Feb 2016 13:41:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160222044145.GE27829@bbox>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222002515.GB21710@bbox>
 <20160222004758.GB4958@swordfish>
 <20160222013442.GB27829@bbox>
 <20160222020113.GB488@swordfish>
 <20160222023432.GC27829@bbox>
 <20160222035954.GC11961@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160222035954.GC11961@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 12:59:54PM +0900, Sergey Senozhatsky wrote:
> On (02/22/16 11:34), Minchan Kim wrote:
> [..]
> > > I'll take a look at dynamic class page addition.
> > 
> > Thanks, Sergey.
> > 
> > Just a note:
> > 
> > I am preparing zsmalloc migration now and almost done so I hope
> > I can send it within two weeks. In there, I changed a lot of
> > things in zsmalloc, page chaining, struct page fields usecases
> > and locking scheme and so on. The zsmalloc fragment/migration
> > is really painful now so we should solve it first so I hope
> > you help to review that and let's go further dynamic chaining
> > after that, please. :)
> 
> oh, sure.
> 
> so let's keep dynamic page allocation out of sight for now.
> I'll do more tests with the increase ORDER and if it's OK then
> hopefully we can just merge it, it's quite simple and shouldn't
> interfere with any of the changes you are about to introduce.

Thanks.

And as another idea, we could try fallback approach that
we couldn't meet nr_pages to minimize wastage so let's fallback
to order-0 page like as-is. It will enhance, at least than now
with small-amount of code compared to dynmaic page allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
