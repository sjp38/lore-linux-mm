Date: Wed, 10 Jul 2002 12:18:12 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Optimize out pte_chain take three
In-Reply-To: <20810000.1026311617@baldur.austin.ibm.com>
Message-ID: <Pine.LNX.4.44L.0207101213480.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Jul 2002, Dave McCracken wrote:

> I agree that it's icky, at least the #defines.  However, I don't like
> using void *, either.  After thinking about it overnight, I think I
> prefer exposing the union along the lines of pte.chain and pte.direct.

I like it.  This patch seems ready for merging, as soon as
we've gotten rmap in.

Speaking of getting rmap in ... we might need some arguments
to get this thing past Linus, anyone ? ;)

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
