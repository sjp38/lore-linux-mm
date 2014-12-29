Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 25C5D6B006C
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:12:57 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id x13so1198548wgg.12
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 06:12:56 -0800 (PST)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id eu5si59246273wid.20.2014.12.29.06.12.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 06:12:56 -0800 (PST)
Received: by mail-wi0-f172.google.com with SMTP id n3so22125790wiv.17
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 06:12:56 -0800 (PST)
Message-ID: <54A1616B.4000005@gmail.com>
Date: Mon, 29 Dec 2014 15:12:59 +0100
From: Stefan Strogin <stefan.strogin@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] cma: add functions to get region pages counters
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <dfddb08aba9a05e6e7b43e9861ab09b7ac1c89cd.1419602920.git.s.strogin@partner.samsung.com> <alpine.DEB.2.10.1412271616450.1819@hxeon> <54A0ED19.1040003@partner.samsung.com>
In-Reply-To: <54A0ED19.1040003@partner.samsung.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Safonov Dmitry <d.safonov@partner.samsung.com>, SeongJae Park <sj38.park@gmail.com>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

29.12.2014 06:56, Safonov Dmitry D?D,N?DuN?:
>
> On 12/27/2014 10:18 AM, SeongJae Park wrote:
>> Hello,
>>
>> How about 'CMA Region' rather than 'CMARegion'?
> Sure.
>

I would like "CMA area..." :)
Or rather "CMA area #%u: base 0x%llx...",
		   cma - &cma_areas[0],
		   (unsigned long long)cma_get_base(cma),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
