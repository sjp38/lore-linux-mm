Date: Wed, 10 May 2006 04:38:34 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm: cleanup swap unused warning
Message-Id: <20060510043834.70f40ddc.akpm@osdl.org>
In-Reply-To: <200605102132.41217.kernel@kolivas.org>
References: <200605102132.41217.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas <kernel@kolivas.org> wrote:
>
> Are there any users of swp_entry_t when CONFIG_SWAP is not defined?

Well there shouldn't be.  Making accesses to swp_entry_t.val fail to
compile if !CONFIG_SWAP might be useful.

> +/*
> + * A swap entry has to fit into a "unsigned long", as
> + * the entry is hidden in the "index" field of the
> + * swapper address space.
> + */
> +#ifdef CONFIG_SWAP
>  typedef struct {
>  	unsigned long val;
>  } swp_entry_t;
> +#else
> +typedef struct {
> +	unsigned long val;
> +} swp_entry_t __attribute__((__unused__));
> +#endif

We have __attribute_used__, which hides a gcc oddity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
