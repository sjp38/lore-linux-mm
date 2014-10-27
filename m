Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id E977590001A
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:00:08 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so4594654ier.26
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 10:00:08 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0236.hostedemail.com. [216.40.44.236])
        by mx.google.com with ESMTP id f6si5652276iod.11.2014.10.27.10.00.08
        for <linux-mm@kvack.org>;
        Mon, 27 Oct 2014 10:00:08 -0700 (PDT)
Message-ID: <1414429203.8884.12.camel@perches.com>
Subject: Re: [PATCH v5 07/12] mm: slub: share slab_err and object_err
 functions
From: Joe Perches <joe@perches.com>
Date: Mon, 27 Oct 2014 10:00:03 -0700
In-Reply-To: <1414428419-17860-8-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	 <1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
	 <1414428419-17860-8-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Mon, 2014-10-27 at 19:46 +0300, Andrey Ryabinin wrote:
> Remove static and add function declarations to mm/slab.h so they
> could be used by kernel address sanitizer.
[]
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
[]
> @@ -115,4 +115,8 @@ static inline void *virt_to_obj(struct kmem_cache *s, void *slab_page, void *x)
[]
> +void slab_err(struct kmem_cache *s, struct page *page, const char *fmt, ...);
> +void object_err(struct kmem_cache *s, struct page *page,
> +		u8 *object, char *reason);

Please add __printf(3, 4) to have the compiler catch
format and argument mismatches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
