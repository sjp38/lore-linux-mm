Date: Thu, 27 Jun 2002 17:44:32 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] find_vma_prev rewrite
In-Reply-To: <20020627160757.A13056@parcelfarce.linux.theplanet.co.uk>
Message-ID: <Pine.LNX.4.44L.0206271732430.1704-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <willy@debian.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jun 2002, Matthew Wilcox wrote:

> I've been sending patches like this for over 18 months now with
> no comments.  I'm sending it to Linus early next week.  It benefits
> ia64's fault handler path and is required for PA-RISC's fault handler.
> It works, it's tested.

It still looks good to me ;)

I hope Linus will merge it this time.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
