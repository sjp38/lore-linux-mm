Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id E2FAB6B0087
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 08:12:43 -0500 (EST)
Received: by pdev10 with SMTP id v10so1049104pde.7
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 05:12:43 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id oj5si12950892pab.241.2015.02.18.05.12.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 18 Feb 2015 05:12:42 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=euc-kr
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJY0012KY7PJ0B0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 18 Feb 2015 13:16:37 +0000 (GMT)
Content-transfer-encoding: 8BIT
Message-id: <54E48FC3.5040902@partner.samsung.com>
Date: Wed, 18 Feb 2015 16:12:35 +0300
From: Safonov Dmitry <d.safonov@partner.samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: add functions to get region pages counters
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
 <c6a3312c9eb667f0f5330c313f328bc49f7addd9.1423777850.git.s.strogin@partner.samsung.com>
 <54DEFA03.6010308@lge.com>
In-reply-to: <54DEFA03.6010308@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hello,
On 02/14/2015 10:32 AM, Gioh Kim wrote:
> 2015-02-13 ?AAu 7:15?! Stefan Strogin AI(?!)  3/4 ' +-U:
>> From: Dmitry Safonov <d.safonov@partner.samsung.com>
>>
>> Here are two functions that provide interface to compute/get used size
>> and size of biggest free chunk in cma region.
> I usually just try to allocate memory, not check free size before try,
> becuase free size can be changed after I check it.
>
> Could you tell me why biggest free chunk size is necessary?
>
It may have changed after checking - at beginning of allocation
this information is completely useless as you mentioned, but
it may be very helpful after failed allocation to detect fragmentation
problem: i.e, you failed to alloc 20 Mb from 100 Mb CMA region
with 60 Mb free space, so you will know the reason.

-- 
Best regards,
Safonov Dmitry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
