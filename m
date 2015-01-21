Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 063276B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 09:18:38 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so1362863pad.7
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 06:18:37 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id go1si4257525pbb.49.2015.01.21.06.18.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 21 Jan 2015 06:18:36 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIJ00JCV6LND670@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jan 2015 14:22:35 +0000 (GMT)
Message-id: <54BFB535.6080200@partner.samsung.com>
Date: Wed, 21 Jan 2015 17:18:29 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 2/3] mm: cma: introduce /proc/cmainfo
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <264ce8ad192124f2afec9a71a2fc28779d453ba7.1419602920.git.s.strogin@partner.samsung.com>
 <54A1C37D.5000106@codeaurora.org>
In-reply-to: <54A1C37D.5000106@codeaurora.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, s.strogin@partner.samsung.com, stefan.strogin@gmail.com

Hello Laura,

On 30/12/14 00:11, Laura Abbott wrote:
>
> This seems better suited to debugfs over procfs, especially since the
> option can be turned off. It would be helpful to break it
> down by cma region as well to make it easier on systems with a lot
> of regions.
>
> Thanks,
> Laura
>

I thought that cmainfo is very similar to vmallocinfo, therefore put it
to procfs. However it seems I have no other choice than debugfs as Pavel
Machek wrote :-)
> We should not add new non-process related files in /proc.
(https://lkml.org/lkml/2015/1/2/6)

And thanks, I agree that breaking it down by CMA region would be useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
