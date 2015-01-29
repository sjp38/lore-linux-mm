Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3C06B006E
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:12:36 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so44413929pab.0
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:12:36 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dw2si11481745pbb.196.2015.01.29.15.12.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 15:12:35 -0800 (PST)
Date: Thu, 29 Jan 2015 15:12:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 04/17] mm: slub: introduce virt_to_obj function.
Message-Id: <20150129151234.a94bea44ae34bc90dcd148b0@linux-foundation.org>
In-Reply-To: <1422544321-24232-5-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-5-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Thu, 29 Jan 2015 18:11:48 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> virt_to_obj takes kmem_cache address, address of slab page,
> address x pointing somewhere inside slab object,
> and returns address of the begging of object.

"beginning"

The above text may as well be placed into slub_def.h as a comment.

> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> ---
>  include/linux/slub_def.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 9abf04e..eca3883 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -110,4 +110,9 @@ static inline void sysfs_slab_remove(struct kmem_cache *s)
>  }
>  #endif
>  
> +static inline void *virt_to_obj(struct kmem_cache *s, void *slab_page, void *x)
> +{
> +	return x - ((x - slab_page) % s->size);
> +}

"const void *x" would be better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
