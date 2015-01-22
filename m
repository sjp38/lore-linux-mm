Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C73E36B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:44:13 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id fp1so2340275pdb.2
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:44:13 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id e9si13120140pas.9.2015.01.22.07.44.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 22 Jan 2015 07:44:12 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIL007FZ58F1A60@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jan 2015 15:48:15 +0000 (GMT)
Message-id: <54C11AC6.7090706@partner.samsung.com>
Date: Thu, 22 Jan 2015 18:44:06 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 0/3] mm: cma: /proc/cmainfo
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <20141229023639.GC27095@bbox> <20150102051111.GC4873@amd>
In-reply-to: <20150102051111.GC4873@amd>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, s.strogin@partner.samsung.com

Hello Pavel,

On 02/01/15 08:11, Pavel Machek wrote:
> On Mon 2014-12-29 11:36:39, Minchan Kim wrote:
>> Hello,
>>
>> On Fri, Dec 26, 2014 at 05:39:01PM +0300, Stefan I. Strogin wrote:
>>> Hello all,
>>>
>>> Here is a patch set that adds /proc/cmainfo.
>>>
>>> When compiled with CONFIG_CMA_DEBUG /proc/cmainfo will contain information
>>> about about total, used, maximum free contiguous chunk and all currently
>>> allocated contiguous buffers in CMA regions. The information about allocated
>>> CMA buffers includes pid, comm, allocation latency and stacktrace at the
>>> moment of allocation.
> We should not add new non-process related files in
> /proc. So... NAK. Should this go to debugfs instead?

As you say, I'll move it to debugfs and also split it by CMA region.
Something like: /sys/kernel/debug/cma/*/allocated
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
