Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4E76B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 14:29:34 -0500 (EST)
Received: by paceu11 with SMTP id eu11so507894pac.10
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 11:29:34 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id n9si10148716pdo.38.2015.02.16.11.29.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Feb 2015 11:29:33 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJV00KYWQBVOVA0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Feb 2015 19:33:31 +0000 (GMT)
Message-id: <54E24517.6040108@partner.samsung.com>
Date: Mon, 16 Feb 2015 22:29:27 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 0/4] mm: cma: add some debug information for CMA
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
 <20150213030308.GG6592@js1304-P5Q-DELUXE> <54DEFBF4.40206@lge.com>
In-reply-to: <54DEFBF4.40206@lge.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hello Gioh,

Thank you for your answer.

On 14/02/15 10:40, Gioh Kim wrote:
>>
>> If this tracer is justifiable, I think that making it conditional is
>> better than just enabling always on CONFIG_CMA_DEBUGFS. Some users
>> don't want to this feature although they enable CONFIG_CMA_DEBUGFS.
>>
>> Thanks.
>>
> 
> Hello,
> 
> Thanks for your work. It must be helpful to me.
> 
> What about add another option to activate stack-trace?
> In my platform I know all devices using cma area, so I usually don't
> need stack-trace.
> 

So Joonsoo suggests to add an option for buffer list, and you suggest to
add another in addition to the first one (and also add CONFIG_STACKTRACE
to dependences) right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
