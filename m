Date: Sun, 6 May 2001 22:19:38 -0700
From: Aaron Lehmann <aaronl@vitelus.com>
Subject: Re: page_launder() bug
Message-ID: <20010506221938.A29493@vitelus.com>
References: <Pine.A41.4.31.0105062307290.59664-100000@pandora.inf.elte.hu> <l03130303b71b795cab9b@[192.168.239.105]> <15094.10942.592911.70443@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15094.10942.592911.70443@pizda.ninka.net>; from davem@redhat.com on Sun, May 06, 2001 at 09:55:26PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Jonathan Morton <chromi@cyberspace.org>, BERECZ Szabolcs <szabi@inf.elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 06, 2001 at 09:55:26PM -0700, David S. Miller wrote:
> 
> Jonathan Morton writes:
>  > >-			 page_count(page) == (1 + !!page->buffers));
>  > Two inversions in a row?
> It is the most straightforward way to make a '1' or '0'
> integer from the NULL state of a pointer.

page_count(page) == (1 + (page->buffers != 0));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
