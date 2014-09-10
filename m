Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id BECF06B009B
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:32:34 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id hy4so4523794vcb.37
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:32:34 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id xe7si6813562vcb.14.2014.09.10.13.32.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 13:32:34 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hq11so1032821vcb.25
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:32:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1409101116160.1654@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
	<1410359487-31938-5-git-send-email-a.ryabinin@samsung.com>
	<alpine.DEB.2.11.1409101116160.1654@gentwo.org>
Date: Thu, 11 Sep 2014 00:32:34 +0400
Message-ID: <CAPAsAGxuoXEM2AXRV_at0=xiLOmaZe+QY-45KeA7ZvvHzhOqMg@mail.gmail.com>
Subject: Re: [RFC/PATCH v2 04/10] mm: slub: introduce virt_to_obj function.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

2014-09-10 20:16 GMT+04:00 Christoph Lameter <cl@linux.com>:
> On Wed, 10 Sep 2014, Andrey Ryabinin wrote:
>
>> virt_to_obj takes kmem_cache address, address of slab page,
>> address x pointing somewhere inside slab object,
>> and returns address of the begging of object.
>
> This function is SLUB specific. Does it really need to be in slab.h?
>

Oh, yes this should be in slub.c

-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
