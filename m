Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 890696B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 14:15:11 -0500 (EST)
Received: by padhz1 with SMTP id hz1so439744pad.9
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 11:15:11 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id ol6si1841113pbb.116.2015.02.16.11.15.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Feb 2015 11:15:10 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJV00NYOPNT3WA0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Feb 2015 19:19:05 +0000 (GMT)
Message-id: <54E241B7.1070709@partner.samsung.com>
Date: Mon, 16 Feb 2015 22:15:03 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 1/4] mm: cma: add currently allocated CMA buffers list to
 debugfs
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
 <c4f408198ec7ea7656ae29220c1f96081bd2ade5.1423777850.git.s.strogin@partner.samsung.com>
 <20150213031012.GH6592@js1304-P5Q-DELUXE>
In-reply-to: <20150213031012.GH6592@js1304-P5Q-DELUXE>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hello,

On 13/02/15 06:10, Joonsoo Kim wrote:
> On Fri, Feb 13, 2015 at 01:15:41AM +0300, Stefan Strogin wrote:
> 
> This linear searching make cma_release() slow if we have many allocated
> cma buffers. It wouldn't cause any problem?
> 
> Thanks.
> 
> 

On my board the usual number of CMA buffers is about 20, and releasing a
buffer isn't a very frequent operation.
But if there could be systems with much more CMA buffers and/or frequent
allocating/releasing them, maybe it would be useful to convert buffers
list to rb_trees?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
