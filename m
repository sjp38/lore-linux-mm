Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C26086B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 14:25:36 -0500 (EST)
Received: by pablf10 with SMTP id lf10so492180pab.6
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 11:25:36 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id t1si17107975pdr.156.2015.02.16.11.25.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Feb 2015 11:25:36 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJV00KZUQ59G5A0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Feb 2015 19:29:33 +0000 (GMT)
Message-id: <54E24428.5070804@partner.samsung.com>
Date: Mon, 16 Feb 2015 22:25:28 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 1/4] mm: cma: add currently allocated CMA buffers list to
 debugfs
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
 <c4f408198ec7ea7656ae29220c1f96081bd2ade5.1423777850.git.s.strogin@partner.samsung.com>
 <alpine.DEB.2.10.1502132313010.23105@hxeon>
In-reply-to: <alpine.DEB.2.10.1502132313010.23105@hxeon>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hello SeongJae,

On 13/02/15 17:18, SeongJae Park wrote:
> Hello, Stefan.
> 
> On Fri, 13 Feb 2015, Stefan Strogin wrote:
> 
>> #include <linux/io.h>
>> +#include <linux/list.h>
>> +#include <linux/proc_fs.h>
>> +#include <linux/time.h>
> 
> Looks like `proc_fs.h` and `time.h` are not necessary.
> 

Yes, of course. Thanks.


>> +        pr_warn("%s(page %p, count %d): failed to allocate buffer
>> list entry\n",
>> +            __func__, pfn_to_page(pfn), count);
> 
> pfn_to_page() would cause build failure on x86_64. Why don't you include
> appropriate header file?
> 

Indeed. Because I tested it only on arm and x86. Sorry :( Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
