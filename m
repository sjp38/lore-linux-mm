From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15094.25285.410379.109719@pizda.ninka.net>
Date: Mon, 7 May 2001 01:54:29 -0700 (PDT)
Subject: Re: page_launder() bug
In-Reply-To: <Pine.LNX.4.33.0105070823060.24073-100000@svea.tellus>
References: <15094.10942.592911.70443@pizda.ninka.net>
	<Pine.LNX.4.33.0105070823060.24073-100000@svea.tellus>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tobias Ringstrom <tori@tellus.mine.nu>
Cc: Jonathan Morton <chromi@cyberspace.org>, BERECZ Szabolcs <szabi@inf.elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Tobias Ringstrom writes:
 > But is it really specified in the C "standards" to be exctly zero or one,
 > and not zero and non-zero?

I'm pretty sure it does.

 > IMHO, the ?: construct is way more readable and reliable.

Well identical code has been there for several months just a few lines
away.

I've seen this idiom used in many places (even the GCC sources :-),
so I'm rather surprised people are seeing it for the first time.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
