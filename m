Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id B169F6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 17:38:46 -0400 (EDT)
Received: by iejt8 with SMTP id t8so93032858iej.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:38:46 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id r2si438560igp.24.2015.04.24.14.38.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 14:38:46 -0700 (PDT)
Received: by igblo3 with SMTP id lo3so25305196igb.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:38:46 -0700 (PDT)
Date: Fri, 24 Apr 2015 14:38:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm/page_alloc.c: add config option to sanitize freed
 pages
In-Reply-To: <1429909549-11726-3-git-send-email-anisse@astier.eu>
Message-ID: <alpine.DEB.2.10.1504241437070.2456@chino.kir.corp.google.com>
References: <1429909549-11726-1-git-send-email-anisse@astier.eu> <1429909549-11726-3-git-send-email-anisse@astier.eu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 24 Apr 2015, Anisse Astier wrote:

> diff --git a/mm/Kconfig b/mm/Kconfig
> index 390214d..cb2df5f 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -635,3 +635,15 @@ config MAX_STACK_SIZE_MB
>  	  changed to a smaller value in which case that is used.
>  
>  	  A sane initial value is 80 MB.
> +
> +config SANITIZE_FREED_PAGES
> +	bool "Sanitize memory pages after free"
> +	default n
> +	help
> +	  This option is used to make sure all pages freed are zeroed. This is
> +	  quite low-level and doesn't handle your slab buffers.
> +	  It has various applications, from preventing some info leaks to
> +	  helping kernel same-page merging in virtualised environments.
> +	  Depending on your workload, it will reduce performance of about 3%.
> +
> +	  If unsure, say N.

Objection to allowing this without first enabling some other DEBUG config 
option, it should never be a standalone option, but also to pretending to 
have any insight into what the performance degredation of it will be.  On 
my systems, this would be _massive_.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
