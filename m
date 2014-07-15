Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6126B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 03:02:38 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so4372725pdi.11
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 00:02:38 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id f5si11040223pat.101.2014.07.15.00.02.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 15 Jul 2014 00:02:37 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8Q002PKRK66Y50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 15 Jul 2014 08:02:30 +0100 (BST)
Message-id: <53C4D0BB.2020107@samsung.com>
Date: Tue, 15 Jul 2014 10:56:59 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 10/21] mm: slab: share virt_to_cache()
 between slab and slub
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-11-git-send-email-a.ryabinin@samsung.com>
 <20140715055342.GH11317@js1304-P5Q-DELUXE>
In-reply-to: <20140715055342.GH11317@js1304-P5Q-DELUXE>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/15/14 09:53, Joonsoo Kim wrote:
> On Wed, Jul 09, 2014 at 03:30:04PM +0400, Andrey Ryabinin wrote:
>> This patch shares virt_to_cache() between slab and slub and
>> it used in cache_from_obj() now.
>> Later virt_to_cache() will be kernel address sanitizer also.
> 
> I think that this patch won't be needed.
> See comment in 15/21.
> 

Ok, I'll drop it.

> Thanks.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
