From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v3 03/31] usercopy: Mark kmalloc caches as usercopy
 caches
Date: Thu, 21 Sep 2017 10:27:13 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709211024120.14427@nuc-kabylake>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org> <1505940337-79069-4-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <kernel-hardening-return-9904-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1505940337-79069-4-git-send-email-keescook@chromium.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com
List-Id: linux-mm.kvack.org

On Wed, 20 Sep 2017, Kees Cook wrote:

> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1291,7 +1291,8 @@ void __init kmem_cache_init(void)
>  	 */
>  	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache(
>  				kmalloc_info[INDEX_NODE].name,
> -				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
> +				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS,
> +				0, kmalloc_size(INDEX_NODE));
>  	slab_state = PARTIAL_NODE;
>  	setup_kmalloc_cache_index_table();

Ok this presumes that at some point we will be able to restrict the number
of bytes writeable and thus set the offset and size field to different
values. Is that realistic?

We already whitelist all kmalloc caches (see first patch).

So what is the point of this patch?
