Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A79296B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 19:30:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v109so13844560wrc.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 16:30:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a203si2368695wmd.173.2017.09.26.16.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 16:30:29 -0700 (PDT)
Date: Tue, 26 Sep 2017 16:30:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: update comments for struct page.mapping
Message-Id: <20170926163027.12836f5006745fcf6e59ad24@linux-foundation.org>
In-Reply-To: <1506410057-22316-1-git-send-email-changbin.du@intel.com>
References: <1506410057-22316-1-git-send-email-changbin.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: changbin.du@intel.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 26 Sep 2017 15:14:17 +0800 changbin.du@intel.com wrote:

> From: Changbin Du <changbin.du@intel.com>
> 
> The struct page.mapping can NULL or points to one object of type
> address_space, anon_vma or KSM private structure.
> 
> ...
>
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -47,8 +47,8 @@ struct page {
>  						 * inode address_space, or NULL.
>  						 * If page mapped as anonymous
>  						 * memory, low bit is set, and
> -						 * it points to anon_vma object:
> -						 * see PAGE_MAPPING_ANON below.
> +						 * it points to anon_vma object
> +						 * or KSM private structure.
>  						 */
>  		void *s_mem;			/* slab first object */
>  		atomic_t compound_mapcount;	/* first tail page */

Why did you remove the (useful) reference to PAGE_MAPPING_ANON?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
