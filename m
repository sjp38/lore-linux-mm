Date: Mon, 25 Sep 2000 18:18:17 +0200
From: "Andi Kleen" <ak@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925181817.A25553@gruyere.muc.suse.de>
References: <20000925180448.A25083@gruyere.muc.suse.de> <Pine.LNX.4.21.0009251817420.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0009251817420.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 06:19:07PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <ak@suse.de>, Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 06:19:07PM +0200, Ingo Molnar wrote:
> > Another thing I would worry about are ports with multiple user page
> > sizes in 2.5. Another ugly case is the x86-64 port which has 4K pages
> > but may likely need a 16K kernel stack due to the 64bit stack bloat.
> 
> yep, but these cases are not affected, i think in the order != 0 case we
> should return NULL if a certain number of iterations did not yield any
> free page.

Ok, that would just break fork()

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
