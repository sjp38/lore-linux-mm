Subject: Re: page_launder() bug
Date: Mon, 7 May 2001 11:52:26 +0100 (BST)
In-Reply-To: <Pine.LNX.4.33.0105070823060.24073-100000@svea.tellus> from "Tobias Ringstrom" at May 07, 2001 08:26:58 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14wicu-0003L5-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tobias Ringstrom <tori@tellus.mine.nu>
Cc: "David S. Miller" <davem@redhat.com>, Jonathan Morton <chromi@cyberspace.org>, BERECZ Szabolcs <szabi@inf.elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > It is the most straightforward way to make a '1' or '0'
> > integer from the NULL state of a pointer.
> 
> But is it really specified in the C "standards" to be exctly zero or one,
> and not zero and non-zero?

Yes. (Fortunately since when this argument occurred Linus said he would eat
his underpants if he was wrong)

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
