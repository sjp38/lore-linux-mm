Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 95DAE6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 00:56:49 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so16787738pab.28
        for <linux-mm@kvack.org>; Sun, 28 Dec 2014 21:56:49 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id yx3si31650450pac.16.2014.12.28.21.56.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sun, 28 Dec 2014 21:56:48 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHB0087GY1FAF60@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 29 Dec 2014 06:00:51 +0000 (GMT)
Message-id: <54A0ED19.1040003@partner.samsung.com>
Date: Mon, 29 Dec 2014 08:56:41 +0300
From: Safonov Dmitry <d.safonov@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 3/3] cma: add functions to get region pages counters
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com>
 <alpine.DEB.2.10.1412271616450.1819@hxeon>
In-reply-to: <alpine.DEB.2.10.1412271616450.1819@hxeon>
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>


On 12/27/2014 10:18 AM, SeongJae Park wrote:
> Hello,
>
> How about 'CMA Region' rather than 'CMARegion'?
Sure.

-- 
Best regards,
Safonov Dmitry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
