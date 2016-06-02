Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 898B56B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 20:14:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s73so28985815pfs.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 17:14:27 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 67si6281075pfp.63.2016.06.01.17.14.26
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 17:14:26 -0700 (PDT)
Date: Thu, 2 Jun 2016 09:15:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 11/12] zsmalloc: page migration support
Message-ID: <20160602001510.GA1736@bbox>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <1464736881-24886-12-git-send-email-minchan@kernel.org>
 <20160601143936.a7ad8eec093514e3ee54cc62@linux-foundation.org>
MIME-Version: 1.0
In-Reply-To: <20160601143936.a7ad8eec093514e3ee54cc62@linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed, Jun 01, 2016 at 02:39:36PM -0700, Andrew Morton wrote:
> On Wed,  1 Jun 2016 08:21:20 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > This patch introduces run-time migration feature for zspage.
> > 
> > ...
> >
> > +static void kick_deferred_free(struct zs_pool *pool)
> > +{
> > +	schedule_work(&pool->free_work);
> > +}
> 
> When CONFIG_ZSMALLOC=m, what keeps all the data structures in place
> during a concurrent rmmod?
> 

The most of data structure in zram start to work by user calling
zs_create_pool and user of zsmalloc should call zs_destroy_pool
before trying doing rmmod where zs_unregister_migration does
flush_work(&pool->free_work).

If I miss something, please let me know it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
