Date: Mon, 7 May 2001 08:26:58 +0200 (CEST)
From: Tobias Ringstrom <tori@tellus.mine.nu>
Subject: Re: page_launder() bug
In-Reply-To: <15094.10942.592911.70443@pizda.ninka.net>
Message-ID: <Pine.LNX.4.33.0105070823060.24073-100000@svea.tellus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Jonathan Morton <chromi@cyberspace.org>, BERECZ Szabolcs <szabi@inf.elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 May 2001, David S. Miller wrote:
> It is the most straightforward way to make a '1' or '0'
> integer from the NULL state of a pointer.

But is it really specified in the C "standards" to be exctly zero or one,
and not zero and non-zero?

IMHO, the ?: construct is way more readable and reliable.

/Tobias

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
