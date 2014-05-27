Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 758986B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 18:48:14 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id wn1so10031395obc.2
        for <linux-mm@kvack.org>; Tue, 27 May 2014 15:48:14 -0700 (PDT)
Received: from mail-oa0-x236.google.com (mail-oa0-x236.google.com [2607:f8b0:4003:c02::236])
        by mx.google.com with ESMTPS id q2si27561259obi.5.2014.05.27.15.48.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 15:48:13 -0700 (PDT)
Received: by mail-oa0-f54.google.com with SMTP id j17so10458938oag.27
        for <linux-mm@kvack.org>; Tue, 27 May 2014 15:48:13 -0700 (PDT)
Date: Tue, 27 May 2014 17:48:09 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCHv3 3/6] mm/zpool: implement common zpool api to
 zbud/zsmalloc
Message-ID: <20140527224809.GD25781@cerebellum.variantweb.net>
References: <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
 <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
 <1400958369-3588-4-git-send-email-ddstreet@ieee.org>
 <20140527220639.GA25781@cerebellum.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140527220639.GA25781@cerebellum.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, May 27, 2014 at 05:06:39PM -0500, Seth Jennings wrote:
> On Sat, May 24, 2014 at 03:06:06PM -0400, Dan Streetman wrote:
<snip>
> > +
> > +int zpool_evict(void *pool, unsigned long handle)
> > +{
> > +	struct zpool *zpool;
> > +
> > +	spin_lock(&pools_lock);
> > +	list_for_each_entry(zpool, &pools_head, list) {
> 
> You can do a container_of() here:
> 
> zpool = container_of(pool, struct zpool, pool);

If you do this, all of the pools_head/pools_lock is unneeded as well.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
