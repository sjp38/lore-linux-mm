Date: Sun, 24 Sep 2000 12:56:24 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: refill_inactive()
In-Reply-To: <m13d8p5-000OWvC@amadeus.home.nl>
Message-ID: <Pine.LNX.4.21.0009241253560.2966-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <root@fenrus.demon.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2000, Arjan van de Ven wrote:

> > shouldnt this be __GFP_WAIT? It's true that __GFP_IO implies __GFP_WAIT
> > (because IO cannot be done without potentially scheduling), so the code is
> 
> Is this also true for starting IO ?

yes. ll_rw_block() might block if there are no more request slots left.
Dirty buffer balancing within buffer.c might block as well.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
