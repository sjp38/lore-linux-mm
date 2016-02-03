Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4A97382963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:30:15 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id o11so27632144qge.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:30:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z18si7467928qhb.117.2016.02.03.14.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 14:30:14 -0800 (PST)
Subject: Re: [PATCH] mm/debug-pagealloc: add missing debug_pagealloc_enabled
References: <1454537757-3760706-1-git-send-email-arnd@arndb.de>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56B27F71.2000700@redhat.com>
Date: Wed, 3 Feb 2016 14:30:09 -0800
MIME-Version: 1.0
In-Reply-To: <1454537757-3760706-1-git-send-email-arnd@arndb.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On 02/03/2016 02:15 PM, Arnd Bergmann wrote:
> The change to move the pagealloc logic broke the slab allocator
> check when it's disabled at compile time:
>
> mm/slab.c: In function 'is_debug_pagealloc_cache':
> mm/slab.c:1608:29: error: implicit declaration of function 'debug_pagealloc_enabled' [-Werror=implicit-function-declaration]
>
> This adds an inline helper to get it to work again.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 0a244aea1a61 ("mm/slab: clean up DEBUG_PAGEALLOC processing code")
> ---
>   include/linux/mm.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5d86eb2e8584..90d600ce56ad 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2242,6 +2242,7 @@ kernel_map_pages(struct page *page, int numpages, int enable)
>   extern bool kernel_page_present(struct page *page);
>   #endif /* CONFIG_HIBERNATION */
>   #else
> +static inline bool debug_pagealloc_enabled(void) { return 0; }
>   static inline void
>   kernel_map_pages(struct page *page, int numpages, int enable) {}
>   #ifdef CONFIG_HIBERNATION
>

I believe this should be fixed with http://article.gmane.org/gmane.linux.kernel.mm/145655

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
