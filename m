Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48F466B411F
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 03:25:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id w15so8828377edl.21
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 00:25:33 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y24si3088edo.347.2018.11.26.00.25.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 00:25:32 -0800 (PST)
Subject: Re: [PATCH] mm: make "migrate_reason_names[]" const char *
References: <20181124090508.GB10877@avx2>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3f66d1a7-afee-ef3e-1c0a-e1aabb305abe@suse.cz>
Date: Mon, 26 Nov 2018 09:25:30 +0100
MIME-Version: 1.0
In-Reply-To: <20181124090508.GB10877@avx2>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

On 11/24/18 10:05 AM, Alexey Dobriyan wrote:
> Those strings are immutable as well.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Sounds a bit random, but why not.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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
