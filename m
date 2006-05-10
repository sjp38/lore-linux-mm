Received: by wr-out-0506.google.com with SMTP id 36so119200wra
        for <linux-mm@kvack.org>; Wed, 10 May 2006 04:42:20 -0700 (PDT)
Message-ID: <84144f020605100442g617e9ddfk45ce444483ea86b8@mail.gmail.com>
Date: Wed, 10 May 2006 14:42:20 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] mm: cleanup swap unused warning
In-Reply-To: <200605102132.41217.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <200605102132.41217.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On 5/10/06, Con Kolivas <kernel@kolivas.org> wrote:
> +/*
> + * A swap entry has to fit into a "unsigned long", as
> + * the entry is hidden in the "index" field of the
> + * swapper address space.
> + */
> +#ifdef CONFIG_SWAP
>  typedef struct {
>         unsigned long val;
>  } swp_entry_t;
> +#else
> +typedef struct {
> +       unsigned long val;
> +} swp_entry_t __attribute__((__unused__));
> +#endif

Or we could make swap_free() an empty static inline function for the
non-CONFIG_SWAP case.

                                                     Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
