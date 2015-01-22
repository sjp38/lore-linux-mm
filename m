Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8108B6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 11:12:47 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so1962696qcx.4
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:12:47 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id n3si5016001qga.55.2015.01.22.08.12.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 08:12:46 -0800 (PST)
Date: Thu, 22 Jan 2015 10:12:43 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] CMA: treat free cma pages as non-free if not ALLOC_CMA
 on watermark checking
In-Reply-To: <20150122015718.GE21444@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1501221012000.3937@gentwo.org>
References: <1421569979-2596-1-git-send-email-teawater@gmail.com> <20150119065544.GA18473@blaptop> <54BE7547.6010701@gmail.com> <20150122015718.GE21444@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Minchan Kim <minchan@kernel.org>, Hui Zhu <teawater@gmail.com>, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, isimatu.yasuaki@jp.fujitsu.com, wangnan0@huawei.com, davidlohr@hp.com, rientjes@google.com, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hui Zhu <zhuhui@xiaomi.com>, Weixing Liu <liuweixing@xiaomi.com>

On Thu, 22 Jan 2015, Joonsoo Kim wrote:

> > Just out of curiosity, "new zone"? Something like movable zone?
>
> Yes, I named it as ZONE_CMA. Maybe I can send prototype of
> implementation within 1 or 2 weeks.

Ugghh. I'd rather reduce the zone types. Do we need slab allocator etc
allocations in that zone? This will multiply the management structures in
various subsystems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
