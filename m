Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 25FC56B00E7
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 15:08:15 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id l89so7156681qgf.38
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 12:08:14 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id cf7si16954337qcb.20.2014.11.24.12.08.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 12:08:13 -0800 (PST)
Date: Mon, 24 Nov 2014 14:08:11 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v7 05/12] mm: slub: introduce virt_to_obj function.
In-Reply-To: <1416852146-9781-6-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1411241407580.9878@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com> <1416852146-9781-6-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Mon, 24 Nov 2014, Andrey Ryabinin wrote:

> virt_to_obj takes kmem_cache address, address of slab page,
> address x pointing somewhere inside slab object,
> and returns address of the begging of object.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
