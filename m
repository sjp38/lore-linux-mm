Date: Thu, 7 Jun 2001 21:19:02 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] VM tuning patch, take 2
In-Reply-To: <l03130325b745dbca4a2f@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0106072117480.1156-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


+               if ((gfp_mask & (__GFP_WAIT | __GFP_IO)) == (__GFP_WAIT | __GFP_IO)) {
+                       int progress = try_to_free_pages(gfp_mask);
+                       if(!progress) {
+                               wakeup_kswapd(1);
+                               goto try_again;
+                       }

You're going to allow GFP_BUFFER allocations to eat from the reserved
queues. Eek. 





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
