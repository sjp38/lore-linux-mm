Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 92D416B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:13:10 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lf10so3708316pab.19
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 05:13:10 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id yg2si10319702pab.187.2014.10.27.05.13.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Oct 2014 05:13:09 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE300LMYREP9O30@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Oct 2014 12:16:01 +0000 (GMT)
Message-id: <544E36D1.3090609@samsung.com>
Date: Mon, 27 Oct 2014 13:13:05 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 0/4] Low/high memory CMA reservation fixes
References: 
 <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
In-reply-to: 
 <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Weijie Yang <weijie.yang.kh@gmail.com>

Hello,

On 2014-10-24 12:18, Laurent Pinchart wrote:
> Hello,
>
> This patch set fixes an issue introduced by commits 95b0e655f914 ("ARM: mm:
> don't limit default CMA region only to low memory") and f7426b983a6a ("mm:
> cma: adjust address limit to avoid hitting low/high memory boundary")
> resulting in reserved areas crossing the low/high memory boundary.
>
> Patches 1/4 and 2/4 fix sides issues, with the bulk of the work in patch 3/4.
> Patch 4/4 then fixes a printk issue that got me puzzled wondering why memory
> reported under the lowmem limit was actually highmem.
>
> This series fixes a v3.18-rc1 regression causing Renesas Koelsch boot
> breakages when CMA is enabled.

I've applied the whole series to my fixes-for-v3.18 branch.

> Changes since v1:
>
> - Use the cma count field to detect non-activated reservations
> - Remove the redundant limit adjustment
>
> Laurent Pinchart (4):
>    mm: cma: Don't crash on allocation if CMA area can't be activated
>    mm: cma: Always consider a 0 base address reservation as dynamic
>    mm: cma: Ensure that reservations never cross the low/high mem
>      boundary
>    mm: cma: Use %pa to print physical addresses
>
>   mm/cma.c | 68 +++++++++++++++++++++++++++++++++++++++++-----------------------
>   1 file changed, 44 insertions(+), 24 deletions(-)
>

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
