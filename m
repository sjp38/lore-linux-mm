Date: Thu, 2 Dec 2004 18:35:06 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Neaten page virtual choice
Message-ID: <20041202183506.GA32283@infradead.org>
References: <20041202162621.GM5752@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041202162621.GM5752@parcelfarce.linux.theplanet.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>
List-ID: <linux-mm.kvack.org>

>  #if defined(WANT_PAGE_VIRTUAL)
> -#define page_address(page) ((page)->virtual)
> -#define set_page_address(page, address)			\
> +  #define page_address(page) ((page)->virtual)
> +  #define set_page_address(page, address)			\

urgg, this is a horrible non-standard indentation.

If you look at other kernel source you see either:

 - no indentation inside #ifdef at all (seems like most of the source)
 - indentation after the leading #
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
