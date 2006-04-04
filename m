Date: Tue, 4 Apr 2006 02:47:15 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2/3] mm: speculative get_page
Message-Id: <20060404024715.6555d8e2.akpm@osdl.org>
In-Reply-To: <20060219020159.9923.94877.sendpatchset@linux.site>
References: <20060219020140.9923.43378.sendpatchset@linux.site>
	<20060219020159.9923.94877.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:
>
> +static inline struct page *page_cache_get_speculative(struct page **pagep)

Seems rather large to inline.

>  +{
>  +	struct page *page;
>  +
>  +	VM_BUG_ON(in_interrupt());
>  +
>  +#ifndef CONFIG_SMP
>  +	page = *pagep;
>  +	if (unlikely(!page))
>  +		return NULL;
>  +
>  +	VM_BUG_ON(!in_atomic());

This will go blam if !CONFIG_PREEMPT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
