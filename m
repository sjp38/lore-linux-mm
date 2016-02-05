Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id A907A4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 11:13:16 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wb13so93739373obb.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:13:16 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id 80si8658597oic.99.2016.02.05.08.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 08:13:16 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id xk3so92465353obc.2
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:13:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1602041417330.29117@chino.kir.corp.google.com>
References: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1454565386-10489-2-git-send-email-iamjoonsoo.kim@lge.com>
	<alpine.DEB.2.10.1602041417330.29117@chino.kir.corp.google.com>
Date: Sat, 6 Feb 2016 01:13:15 +0900
Message-ID: <CAAmzW4P-09yqdCiZJpYbpueih7+gq0Qcg302nsaHLZASHUki9w@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm/vmalloc: query dynamic DEBUG_PAGEALLOC setting
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-05 7:18 GMT+09:00 David Rientjes <rientjes@google.com>:
> On Thu, 4 Feb 2016, Joonsoo Kim wrote:
>
>> We can disable debug_pagealloc processing even if the code is complied
>> with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
>> whether it is enabled or not in runtime.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> I think the comment immediately before this code referencing
> CONFIG_DEBUG_PAGEALLOC should be changed to refer to pagealloc debugging
> being enabled.

Andrew kindly did it. Thanks, Andrew.

> After that:
>
>         Acked-by: David Rientjes <rientjes@google.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
