From: John Stoffel <stoffel@casc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15135.37789.234756.822456@gargle.gargle.HOWL>
Date: Thu, 7 Jun 2001 10:45:49 -0400
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
In-Reply-To: <l03130312b7444bea56f8@[192.168.239.105]>
References: <l03130308b7439bb9f187@[192.168.239.105]>
	<l03130312b7444bea56f8@[192.168.239.105]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jonathan> The one which deals with dead swapcache pages.  I want to
Jonathan> apply the one which actively eats them using kreclaimd, too.

Why do we need yet another daemon to reap pages/swap/cache from the
system?  

Or am I mis-understanding you here and you'd just be adding some stuff
to kswapd?

John
   John Stoffel - Senior Unix Systems Administrator - Lucent Technologies
	 stoffel@lucent.com - http://www.lucent.com - 978-952-7548
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
