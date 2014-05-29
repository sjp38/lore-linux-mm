Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3F04B6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 08:56:08 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so9203pad.25
        for <linux-mm@kvack.org>; Thu, 29 May 2014 05:56:07 -0700 (PDT)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id ns7si786616pbb.248.2014.05.29.05.56.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 05:56:07 -0700 (PDT)
Received: by mail-pb0-f47.google.com with SMTP id rp16so335915pbb.6
        for <linux-mm@kvack.org>; Thu, 29 May 2014 05:56:07 -0700 (PDT)
Message-ID: <1401368165.3645.21.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH] vmalloc: use rcu list iterator to reduce vmap_area_lock
 contention
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 May 2014 05:56:05 -0700
In-Reply-To: <1401344554-3596-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1401344554-3596-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Yao <ryao@gentoo.org>

On Thu, 2014-05-29 at 15:22 +0900, Joonsoo Kim wrote:
> Richard Yao reported a month ago that his system have a trouble
> with vmap_area_lock contention during performance analysis
> by /proc/meminfo. Andrew asked why his analysis checks /proc/meminfo
> stressfully, but he didn't answer it.
> 
> https://lkml.org/lkml/2014/4/10/416
> 
> Although I'm not sure that this is right usage or not, there is a solution
> reducing vmap_area_lock contention with no side-effect. That is just
> to use rcu list iterator in get_vmalloc_info(). This function only needs
> values on vmap_area structure, so we don't need to grab a spinlock.
> 
> Reported-by: Richard Yao <ryao@gentoo.org>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Nice, I was considering the same

Acked-by: Eric Dumazet <edumazet@google.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
