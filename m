Message-ID: <3C7278B7.C0E4D126@mandrakesoft.com>
Date: Tue, 19 Feb 2002 11:09:27 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [PATCH *] new struct page shrinkage
References: <Pine.LNX.4.33L.0202191131050.1930-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> I've also pulled the thing up to
> your latest changes from linux.bkbits.net so you should be
> able to just pull it into your tree from:

Note that with BK, unlike CVS, it is not required that you update to the
latest Linus tree before he can pull.

It is only desired that you do so if there is an actual conflict you
need to resolve...

	Jeff



-- 
Jeff Garzik      | "Why is it that attractive girls like you
Building 1024    |  always seem to have a boyfriend?"
MandrakeSoft     | "Because I'm a nympho that owns a brewery?"
                 |             - BBC TV show "Coupling"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
