Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5059F6B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:17:57 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id fa1so5731528pad.16
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 00:17:56 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id i14si3986271pdl.61.2014.09.15.00.17.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 15 Sep 2014 00:17:56 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBX000OULQMZ020@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 15 Sep 2014 08:20:46 +0100 (BST)
Message-id: <5416910F.9020106@samsung.com>
Date: Mon, 15 Sep 2014 11:11:11 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH v2 04/10] mm: slub: introduce virt_to_obj function.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-5-git-send-email-a.ryabinin@samsung.com>
 <alpine.DEB.2.11.1409101116160.1654@gentwo.org>
 <CAPAsAGxuoXEM2AXRV_at0=xiLOmaZe+QY-45KeA7ZvvHzhOqMg@mail.gmail.com>
In-reply-to: 
 <CAPAsAGxuoXEM2AXRV_at0=xiLOmaZe+QY-45KeA7ZvvHzhOqMg@mail.gmail.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Christoph Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 09/11/2014 12:32 AM, Andrey Ryabinin wrote:
> 2014-09-10 20:16 GMT+04:00 Christoph Lameter <cl@linux.com>:
>> On Wed, 10 Sep 2014, Andrey Ryabinin wrote:
>>
>>> virt_to_obj takes kmem_cache address, address of slab page,
>>> address x pointing somewhere inside slab object,
>>> and returns address of the begging of object.
>>
>> This function is SLUB specific. Does it really need to be in slab.h?
>>
> 
> Oh, yes this should be in slub.c
> 

I forgot that include/linux/slub_def.h exists. Perhaps it would be better to move
virt_to_obj into slub_def.h to avoid ugly #ifdef CONFIG_KASAN in slub.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
