Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75671828E1
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 18:42:10 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so109893420pad.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 15:42:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x129si2308039pfb.98.2016.06.22.15.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 15:42:09 -0700 (PDT)
Date: Wed, 22 Jun 2016 15:42:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, compaction: abort free scanner if split fails
Message-Id: <20160622154207.a65d48bae9e90cc1e89f3895@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1606221502140.146497@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1606211820350.97086@chino.kir.corp.google.com>
	<20160622145617.79197acff1a7e617b9d9d393@linux-foundation.org>
	<alpine.DEB.2.10.1606221502140.146497@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, 22 Jun 2016 15:06:29 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> On Wed, 22 Jun 2016, Andrew Morton wrote:
> 
> > On Tue, 21 Jun 2016 18:22:49 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > 
> > > If the memory compaction free scanner cannot successfully split a free
> > > page (only possible due to per-zone low watermark), terminate the free 
> > > scanner rather than continuing to scan memory needlessly.  If the 
> > > watermark is insufficient for a free page of order <= cc->order, then 
> > > terminate the scanner since all future splits will also likely fail.
> > > 
> > > This prevents the compaction freeing scanner from scanning all memory on 
> > > very large zones (very noticeable for zones > 128GB, for instance) when 
> > > all splits will likely fail while holding zone->lock.
> > > 
> > 
> > This collides pretty heavily with Joonsoo's "mm/compaction: split
> > freepages without holding the zone lock".
> > 
> 
> Sorry if it wasn't clear, but I was proposing this patch for 4.7 
> inclusion and Vlastimil agreed we should ask for that.  Joonsoo said he 
> was prepared to rebase on top of that.  Is 
> mm-compaction-split-freepages-without-holding-the-zone-lock.patch and 
> friends going into 4.7 or are we deferring this fix until 4.8?

I have this patch lined up for 4.7 so I was rebasing Joonsoo's patches
on top.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
