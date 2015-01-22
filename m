Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 027386B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 20:56:23 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so5128497pad.8
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 17:56:22 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id zy7si433444pbc.83.2015.01.21.17.56.20
        for <linux-mm@kvack.org>;
        Wed, 21 Jan 2015 17:56:21 -0800 (PST)
Date: Thu, 22 Jan 2015 10:57:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] CMA: treat free cma pages as non-free if not ALLOC_CMA
 on watermark checking
Message-ID: <20150122015718.GE21444@js1304-P5Q-DELUXE>
References: <1421569979-2596-1-git-send-email-teawater@gmail.com>
 <20150119065544.GA18473@blaptop>
 <54BE7547.6010701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54BE7547.6010701@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Hui Zhu <teawater@gmail.com>, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, isimatu.yasuaki@jp.fujitsu.com, wangnan0@huawei.com, davidlohr@hp.com, cl@linux.com, rientjes@google.com, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hui Zhu <zhuhui@xiaomi.com>, Weixing Liu <liuweixing@xiaomi.com>

On Tue, Jan 20, 2015 at 11:33:27PM +0800, Zhang Yanfei wrote:
> Hello Minchan,
> 
> How are you?
> 
> a?? 2015/1/19 14:55, Minchan Kim a??e??:
> > Hello,
> > 
> > On Sun, Jan 18, 2015 at 04:32:59PM +0800, Hui Zhu wrote:
> >> From: Hui Zhu <zhuhui@xiaomi.com>
> >>
> >> The original of this patch [1] is part of Joonsoo's CMA patch series.
> >> I made a patch [2] to fix the issue of this patch.  Joonsoo reminded me
> >> that this issue affect current kernel too.  So made a new one for upstream.
> > 
> > Recently, we found many problems of CMA and Joonsoo tried to add more
> > hooks into MM like agressive allocation but I suggested adding new zone
> 
> Just out of curiosity, "new zone"? Something like movable zone?

Yes, I named it as ZONE_CMA. Maybe I can send prototype of
implementation within 1 or 2 weeks.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
