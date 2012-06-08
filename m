Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 4F1756B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:02:14 -0400 (EDT)
Date: Fri, 8 Jun 2012 14:02:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/4] slub: change declare of get_slab() to inline at all
 times
In-Reply-To: <1339176197-13270-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1206081401090.28466@router.home>
References: <yes> <1339176197-13270-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 9 Jun 2012, Joonsoo Kim wrote:

> -static struct kmem_cache *get_slab(size_t size, gfp_t flags)
> +static __always_inline struct kmem_cache *get_slab(size_t size, gfp_t flags)

I thought that the compiler felt totally free to inline static functions
at will? This may be a matter of compiler optimization settings. I can
understand the use of always_inline in a header file but why in a .c file?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
