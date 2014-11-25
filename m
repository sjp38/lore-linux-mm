Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3880F6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 08:11:24 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so558650pab.21
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 05:11:23 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id c5si1906821pdn.70.2014.11.25.05.11.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 25 Nov 2014 05:11:22 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFL00ET7JFM2N60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 25 Nov 2014 13:14:10 +0000 (GMT)
Message-id: <54747FF2.4050207@samsung.com>
Date: Tue, 25 Nov 2014 16:11:14 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v7 07/12] mm: slub: introduce
 metadata_access_enable()/metadata_access_disable()
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-8-git-send-email-a.ryabinin@samsung.com>
 <CAA6XgkFPvHQE7LpZ=Q19e8sGAwOtWiVBXzjZA+7HXmNWL_genA@mail.gmail.com>
In-reply-to: 
 <CAA6XgkFPvHQE7LpZ=Q19e8sGAwOtWiVBXzjZA+7HXmNWL_genA@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Chernenkov <dmitryc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 11/25/2014 03:22 PM, Dmitry Chernenkov wrote:
> LGTM
> 
> Does this mean we're going to sanitize the slub code itself?)
> 

Nope, to sanitize slub itself we need much more than just this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
