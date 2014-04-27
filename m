Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 30F206B0083
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 07:46:06 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so4003278eek.4
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 04:46:05 -0700 (PDT)
Received: from mail-ee0-x22a.google.com (mail-ee0-x22a.google.com [2a00:1450:4013:c00::22a])
        by mx.google.com with ESMTPS id x44si19381610eep.90.2014.04.27.04.46.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 27 Apr 2014 04:46:04 -0700 (PDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so4014779eek.29
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 04:46:03 -0700 (PDT)
Date: Sun, 27 Apr 2014 13:46:00 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: update the comment for high_memory
Message-ID: <20140427114600.GA21935@gmail.com>
References: <535C854C.1070105@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <535C854C.1070105@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, peterz@infradead.org, riel@redhat.com, mgorman@suse.de, hannes@cmpxchg.org, hughd@google.com, linux-mm@kvack.org


* Wang Sheng-Hui <shhuiw@gmail.com> wrote:

> 
> The system variable is not used for x86 only now. Remove the
> "x86" strings.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> ---
>  mm/memory.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 93e332d..1615a64 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -85,14 +85,13 @@ EXPORT_SYMBOL(mem_map);
>  #endif
> 
>  /*
> - * A number of key systems in x86 including ioremap() rely on the assumption
> - * that high_memory defines the upper bound on direct map memory, then end
> - * of ZONE_NORMAL.  Under CONFIG_DISCONTIG this means that max_low_pfn and
> + * A number of key systems including ioremap() rely on the assumption that
> + * high_memory defines the upper bound on direct map memory, then end of
> + * ZONE_NORMAL.  Under CONFIG_DISCONTIG this means that max_low_pfn and
>   * highstart_pfn must be the same; there must be no gap between ZONE_NORMAL
>   * and ZONE_HIGHMEM.

ioremap() is not a 'key system', so if we are touching it then the 
comment should be fixed in other ways as well.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
