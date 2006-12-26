Message-ID: <367118962.32541@ustc.edu.cn>
Date: Tue, 26 Dec 2006 15:42:57 +0800
From: Fengguang Wu <fengguang.wu@gmail.com>
Subject: Re: [PATCH] Sanely size hash tables when using large base pages.
Message-ID: <20061226074257.GA5853@mail.ustc.edu.cn>
References: <20061226061652.GA598@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061226061652.GA598@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Paul,

On Tue, Dec 26, 2006 at 03:16:52PM +0900, Paul Mundt wrote:
>  	pidhash_shift = max(4, fls(megabytes * 4));
>  	pidhash_shift = min(12, pidhash_shift);
>  	pidhash_size = 1 << pidhash_shift;
>  
> +	size = pidhash_size * sizeof(struct hlist_head);
> +	if (unlikely(size < PAGE_SIZE)) {
> +		size = PAGE_SIZE;
> +		pidhash_size = size / sizeof(struct hlist_head);
> +		pidhash_shift = 0;

But pidhash_shift is not the order of page ;-)

Regards,
Wu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
