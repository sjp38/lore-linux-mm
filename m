Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 352536B51FE
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 05:06:11 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so1193470qkb.23
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 02:06:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e7si1014107qvp.159.2018.11.29.02.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 02:06:10 -0800 (PST)
Subject: Re: [PATCH] mm: make "migrate_reason_names[]" const char *
References: <20181124090508.GB10877@avx2>
From: David Hildenbrand <david@redhat.com>
Message-ID: <91e0e37f-6217-e8a5-6e70-75c8572e608c@redhat.com>
Date: Thu, 29 Nov 2018 11:06:07 +0100
MIME-Version: 1.0
In-Reply-To: <20181124090508.GB10877@avx2>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, vbabka@suse.cz

On 24.11.18 10:05, Alexey Dobriyan wrote:
> Those strings are immutable as well.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  include/linux/migrate.h |    2 +-
>  mm/debug.c              |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -29,7 +29,7 @@ enum migrate_reason {
>  };
>  
>  /* In mm/debug.c; also keep sync with include/trace/events/migrate.h */
> -extern char *migrate_reason_names[MR_TYPES];
> +extern const char *migrate_reason_names[MR_TYPES];
>  
>  static inline struct page *new_page_nodemask(struct page *page,
>  				int preferred_nid, nodemask_t *nodemask)
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -17,7 +17,7 @@
>  
>  #include "internal.h"
>  
> -char *migrate_reason_names[MR_TYPES] = {
> +const char *migrate_reason_names[MR_TYPES] = {
>  	"compaction",
>  	"memory_failure",
>  	"memory_hotplug",
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
