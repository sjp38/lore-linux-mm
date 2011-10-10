Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 398146B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 12:27:34 -0400 (EDT)
Subject: Re: [PATCH 1/9] mm: add a "struct subpage" type containing a page,
 offset and length
From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 10 Oct 2011 17:27:07 +0100
In-Reply-To: <1318245101-16890-1-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
	 <1318245101-16890-1-git-send-email-ian.campbell@citrix.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1318264027.21903.470.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Christoph
 Hellwig <hch@infradead.org>

(reposting including LKML to catch other potential users)

Is this structure of any use to unify other instances of a similar
tuple, e.g. biovec, pagefrag etc?

Ian.

On Mon, 2011-10-10 at 12:11 +0100, Ian Campbell wrote:
> A few network drivers currently use skb_frag_struct for this purpose but I have
> patches which add additional fields and semantics there which these other uses
> do not want.
> 
> A structure for reference sub-page regions seems like a generally useful thing
> so do so instead of adding a network subsystem specific structure.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: linux-mm@kvack.org
> ---
>  include/linux/mm_types.h |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 774b895..dc1d103 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -135,6 +135,17 @@ struct page {
>  #endif
>  ;
>  
> +struct subpage {
> +	struct page *page;
> +#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
> +	__u32 page_offset;
> +	__u32 size;
> +#else
> +	__u16 page_offset;
> +	__u16 size;
> +#endif
> +};
> +
>  typedef unsigned long __nocast vm_flags_t;
>  
>  /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
