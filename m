Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 17A2E6B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 11:28:27 -0500 (EST)
Received: by mail-vc0-f172.google.com with SMTP id hq11so4808431vcb.31
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 08:28:26 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id l108si20988159qgf.94.2014.12.01.08.28.25
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 08:28:25 -0800 (PST)
Date: Mon, 1 Dec 2014 16:28:10 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v8 10/12] kmemleak: disable kasan instrumentation for
 kmemleak
Message-ID: <20141201162810.GA13676@localhost>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1417104057-20335-1-git-send-email-a.ryabinin@samsung.com>
 <1417104057-20335-11-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417104057-20335-11-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Nov 27, 2014 at 04:00:54PM +0000, Andrey Ryabinin wrote:
> kmalloc internally round up allocation size, and kmemleak
> uses rounded up size as object's size. This makes kasan
> to complain while kmemleak scans memory or calculates of object's
> checksum. The simplest solution here is to disable kasan.

This would indeed be the simplest since by the time kmemleak callbacks
get called (from slub) we lose the original size information (especially
for kmem_cache_alloc).

> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  mm/kmemleak.c | 6 ++++++
>  1 file changed, 6 insertions(+)

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
