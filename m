Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B49866B02EE
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:28:52 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o60so10864731wrc.14
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:28:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v11sor9397470edb.25.2017.11.22.13.28.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 13:28:51 -0800 (PST)
Date: Wed, 22 Nov 2017 22:28:48 +0100
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH 05/62] radix tree: Add a missing cast to gfp_t
Message-ID: <20171122212847.axib6ito23sldlbe@ltop.local>
References: <20171122210739.29916-1-willy@infradead.org>
 <20171122210739.29916-6-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122210739.29916-6-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, Nov 22, 2017 at 01:06:42PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> sparse complains about an invalid type assignment.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  lib/radix-tree.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index c8d55565fafa..f00303e0b216 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -178,7 +178,7 @@ static inline void root_tag_clear(struct radix_tree_root *root, unsigned tag)
>  
>  static inline void root_tag_clear_all(struct radix_tree_root *root)
>  {
> -	root->gfp_mask &= (1 << ROOT_TAG_SHIFT) - 1;
> +	root->gfp_mask &= (__force gfp_t)((1 << ROOT_TAG_SHIFT) - 1);
>  }
>  
>  static inline int root_tag_get(const struct radix_tree_root *root, unsigned tag)
> -- 

IMO, it would be better to define something for that in radix-tree.h,
like it has been done for ROOT_IS_IDR.

Regards,
-- Luc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
