Date: Thu, 14 Jun 2001 13:42:15 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [PATCH] "unlazy swapcache" patch from 2.4.6pre3 to 2.4.5ac13
Message-ID: <Pine.LNX.4.21.0106141335510.8439-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

I'm starting to "port" a few VM changes from 2.4.6pre series to 2.4.5ac. 

This is the first one: Unlazy the swapcache and remove the
clean_dead_swap_page() stuff added in the -ac series before.

http://bazar.conectiva.com.br/~marcelo/patches/v2.4/2.4.5ac13/free_page_and_swap.patch


Alan, you may want to merge this. 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
