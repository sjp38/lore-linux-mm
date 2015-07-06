Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id D016E2802AF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 10:01:59 -0400 (EDT)
Received: by igrv9 with SMTP id v9so154332746igr.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 07:01:59 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id zw9si29127573pbc.206.2015.07.06.07.01.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 07:01:59 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so96098427pac.2
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 07:01:59 -0700 (PDT)
Date: Mon, 6 Jul 2015 23:01:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 5/7] zsmalloc/zram: store compaction stats in zspool
Message-ID: <20150706140152.GD16529@blaptop>
References: <1436185070-1940-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436185070-1940-6-git-send-email-sergey.senozhatsky@gmail.com>
 <20150706132728.GB16529@blaptop>
 <20150706135646.GD663@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150706135646.GD663@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Mon, Jul 06, 2015 at 10:56:46PM +0900, Sergey Senozhatsky wrote:
> On (07/06/15 22:27), Minchan Kim wrote:
> > > `zs_compact_control' accounts the number of migrated objects but
> > > it has a limited lifespan -- we lose it as soon as zs_compaction()
> > > returns back to zram. It was fine, because (a) zram had it's own
> > > counter of migrated objects and (b) only zram could trigger
> > > compaction. However, this does not work for automatic pool
> > > compaction (not issued by zram). To account objects migrated
> > > during auto-compaction (issued by the shrinker) we need to store
> > > this number in zs_pool.
> > > 
> > > A new zsmalloc zs_get_num_migrated() symbol exports zs_pool's
> > > ->num_migrated counter, so we better start using it, rather than
> > > continue keeping zram's own `num_migrated' copy in zram_stats.
> > 
> > If we introduce like this API we should make new another API when
> > we want to introduce new stats. So I don't think it's a good idea.
> > How about this?
> > 
> >         void zsmalloc_stats(struct zsmalloc_stats *stats);
> > 
> > So, we could return any upcoming stats without new API introduce.
> > 
> 
> Hm, agree. Do you prefer me to fold this into this patch set or to do as
> a separate work later?

Let's fold it so your next patch can use it for getting num_compacted.

> 
> 
> P.S.
> 
> Sorry. Seems that my git send-email has some problems, so group-reply
> in mutt does not work as expected.
> 
> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
