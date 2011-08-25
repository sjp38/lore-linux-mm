Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 822AE6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 19:50:09 -0400 (EDT)
Date: Thu, 25 Aug 2011 16:50:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Neaten warn_alloc_failed
Message-Id: <20110825165006.af771ef7.akpm@linux-foundation.org>
In-Reply-To: <5a0bef0143ed2b3176917fdc0ddd6a47f4c79391.1314303846.git.joe@perches.com>
References: <5a0bef0143ed2b3176917fdc0ddd6a47f4c79391.1314303846.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 25 Aug 2011 13:26:19 -0700
Joe Perches <joe@perches.com> wrote:

> Add __attribute__((format (printf...) to the function
> to validate format and arguments.  Use vsprintf extension
> %pV to avoid any possible message interleaving. Coalesce
> format string.  Convert printks/pr_warning to pr_warn.
> 
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1334,7 +1334,8 @@ extern void si_meminfo(struct sysinfo * val);
>  extern void si_meminfo_node(struct sysinfo *val, int nid);
>  extern int after_bootmem;
>  
> -extern void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
> +extern __attribute__((format (printf, 3, 4)))
> +void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
>  
>  extern void setup_per_cpu_pageset(void);
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c

looky:

--- a/include/linux/mm.h~mm-neaten-warn_alloc_failed-fix
+++ a/include/linux/mm.h
@@ -1335,7 +1335,7 @@ extern void si_meminfo(struct sysinfo * 
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern int after_bootmem;
 
-extern __attribute__((format (printf, 3, 4)))
+extern __printf(3, 4)
 void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
 
 extern void setup_per_cpu_pageset(void);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
