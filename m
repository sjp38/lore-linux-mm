Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AAE516B019C
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 02:42:56 -0400 (EDT)
Message-ID: <4E97D9E4.4090202@kernel.dk>
Date: Fri, 14 Oct 2011 08:42:44 +0200
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
References: <1318500176-10728-1-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1318500176-10728-1-git-send-email-ian.campbell@citrix.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <ian.campbell@citrix.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2011-10-13 12:02, Ian Campbell wrote:
> A few network drivers currently use skb_frag_struct for this purpose but I have
> patches which add additional fields and semantics there which these other uses
> do not want.
> 
> A structure for reference sub-page regions seems like a generally useful thing
> so do so instead of adding a network subsystem specific structure.

Looks good to me, I can switch struct bio_vec over to this once it's in.

Acked-by: Jens Axboe <axboe@kernel.dk>

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
