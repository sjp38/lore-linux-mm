From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15094.10942.592911.70443@pizda.ninka.net>
Date: Sun, 6 May 2001 21:55:26 -0700 (PDT)
Subject: Re: page_launder() bug
In-Reply-To: <l03130303b71b795cab9b@[192.168.239.105]>
References: <Pine.A41.4.31.0105062307290.59664-100000@pandora.inf.elte.hu>
	<l03130303b71b795cab9b@[192.168.239.105]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: BERECZ Szabolcs <szabi@inf.elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jonathan Morton writes:
 > >-			 page_count(page) == (1 + !!page->buffers));
 > 
 > Two inversions in a row?

It is the most straightforward way to make a '1' or '0'
integer from the NULL state of a pointer.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
