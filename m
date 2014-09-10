Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 019FC6B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:17:00 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id rd18so3152469iec.8
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:17:00 -0700 (PDT)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id ga7si2281106igd.45.2014.09.10.09.17.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 09:17:00 -0700 (PDT)
Date: Wed, 10 Sep 2014 11:16:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC/PATCH v2 04/10] mm: slub: introduce virt_to_obj function.
In-Reply-To: <1410359487-31938-5-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1409101116160.1654@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-5-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Wed, 10 Sep 2014, Andrey Ryabinin wrote:

> virt_to_obj takes kmem_cache address, address of slab page,
> address x pointing somewhere inside slab object,
> and returns address of the begging of object.

This function is SLUB specific. Does it really need to be in slab.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
