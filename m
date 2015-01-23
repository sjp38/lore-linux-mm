Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 374106B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 20:22:48 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id g10so2547746pdj.0
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 17:22:48 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id g1si9603690pdb.213.2015.01.22.17.22.43
        for <linux-mm@kvack.org>;
        Thu, 22 Jan 2015 17:22:47 -0800 (PST)
Date: Fri, 23 Jan 2015 10:23:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] CMA: treat free cma pages as non-free if not ALLOC_CMA
 on watermark checking
Message-ID: <20150123012334.GA32632@js1304-P5Q-DELUXE>
References: <1421569979-2596-1-git-send-email-teawater@gmail.com>
 <20150119065544.GA18473@blaptop>
 <54BE7547.6010701@gmail.com>
 <20150122015718.GE21444@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1501221012000.3937@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501221012000.3937@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Minchan Kim <minchan@kernel.org>, Hui Zhu <teawater@gmail.com>, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, isimatu.yasuaki@jp.fujitsu.com, wangnan0@huawei.com, davidlohr@hp.com, rientjes@google.com, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hui Zhu <zhuhui@xiaomi.com>, Weixing Liu <liuweixing@xiaomi.com>

On Thu, Jan 22, 2015 at 10:12:43AM -0600, Christoph Lameter wrote:
> On Thu, 22 Jan 2015, Joonsoo Kim wrote:
> 
> > > Just out of curiosity, "new zone"? Something like movable zone?
> >
> > Yes, I named it as ZONE_CMA. Maybe I can send prototype of
> > implementation within 1 or 2 weeks.
> 
> Ugghh. I'd rather reduce the zone types. Do we need slab allocator etc
> allocations in that zone? This will multiply the management structures in
> various subsystems.

Hello,

Pages in CMA area should be movable so slab allocator which uses
unmovable/reclaimable allocation wouldn't need to consider that zone.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
