Message-ID: <3C7AF011.8B6ECCF0@zip.com.au>
Date: Mon, 25 Feb 2002 18:16:49 -0800
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] struct page shrinkage
References: <Pine.LNX.4.33L.0202252245460.7820-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Marcelo W. Tosatti" <marcelo@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> +               clear_bit(PG_locked, &p->flags);

Please don't do this.  Please use the macros.  If they're not
there, please create them.

Bypassing the abstractions in this manner confounds people
who are implementing global locked-page accounting.

In fact, I think I'll go rename all the page flags...

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
