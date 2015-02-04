Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id B11F96B00A3
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 15:39:00 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w55so4035280wes.1
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 12:39:00 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id gf7si3043818wjd.23.2015.02.04.12.38.58
        for <linux-mm@kvack.org>;
        Wed, 04 Feb 2015 12:38:59 -0800 (PST)
From: Daniel Sanders <Daniel.Sanders@imgtec.com>
Subject: RE: [PATCH 1/5] LLVMLinux: Correct size_index table before
 replacing the bootstrap kmem_cache_node.
Date: Wed, 4 Feb 2015 20:38:56 +0000
Message-ID: <E484D272A3A61B4880CDF2E712E9279F4591C3EC@hhmail02.hh.imgtec.org>
References: <1422970639-7922-1-git-send-email-daniel.sanders@imgtec.com>
 <1422970639-7922-2-git-send-email-daniel.sanders@imgtec.com>
 <54D27403.90000@iki.fi>
In-Reply-To: <54D27403.90000@iki.fi>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> -----Original Message-----
> From: Pekka Enberg [mailto:penberg@iki.fi]
> Sent: 04 February 2015 19:33
> To: Daniel Sanders
> Cc: Christoph Lameter; Pekka Enberg; David Rientjes; Joonsoo Kim; Andrew
> Morton; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 1/5] LLVMLinux: Correct size_index table before
> replacing the bootstrap kmem_cache_node.
>=20
> On 2/3/15 3:37 PM, Daniel Sanders wrote:
> > This patch moves the initialization of the size_index table slightly
> > earlier so that the first few kmem_cache_node's can be safely allocated
> > when KMALLOC_MIN_SIZE is large.
>=20
> The patch looks OK to me but how is this related to LLVM?
>
> - Pekka

I don't believe the bug to be LLVM specific but GCC doesn't normally encoun=
ter the problem. I haven't been able to identify exactly what GCC is doing =
better (probably inlining) but it seems that GCC is managing to optimize  t=
o the point that it eliminates the problematic allocations. This theory is =
supported by the fact that GCC can be made to fail in the same way by chang=
ing inline, __inline, __inline__, and __always_inline in include/linux/comp=
iler-gcc.h such that they don't actually inline things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
