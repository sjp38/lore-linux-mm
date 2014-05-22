Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id C695B6B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 22:49:13 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rr13so2021527pbb.35
        for <linux-mm@kvack.org>; Wed, 21 May 2014 19:49:13 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id qu8si8644356pbb.27.2014.05.21.19.49.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 19:49:13 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so1976117pde.14
        for <linux-mm@kvack.org>; Wed, 21 May 2014 19:49:12 -0700 (PDT)
Date: Wed, 21 May 2014 19:49:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, thp: avoid excessive compaction latency during
 fault fix
In-Reply-To: <5371ED3F.6070505@suse.cz>
Message-ID: <alpine.DEB.2.02.1405211945140.13243@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061922010.18635@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405072229390.19108@chino.kir.corp.google.com> <5371ED3F.6070505@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 May 2014, Vlastimil Babka wrote:

> I wonder what about a process doing e.g. mmap() with MAP_POPULATE. It seems to
> me that it would get only MIGRATE_ASYNC here, right? Since gfp_mask would
> include __GFP_NO_KSWAPD and it won't have PF_KTHREAD.
> I think that goes against the idea that with MAP_POPULATE you say you are
> willing to wait to have everything in place before you actually use the
> memory. So I guess you are also willing to wait for hugepages in that
> situation?
> 

I don't understand the distinction you're making between MAP_POPULATE and 
simply a prefault of the anon memory.  What is the difference in semantics 
between using MAP_POPULATE and touching a byte every page size along the 
range?  In the latter, you'd be faulting thp with MIGRATE_ASYNC, so I 
don't understand how MAP_POPULATE is any different or implies any 
preference for hugepages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
