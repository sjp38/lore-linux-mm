Date: Mon, 1 May 2000 17:23:13 -0700
Message-Id: <200005020023.RAA31259@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.21.0005012059270.7508-100000@duckman.conectiva>
	(message from Rik van Riel on Mon, 1 May 2000 21:07:35 -0300 (BRST))
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
References: <Pine.LNX.4.21.0005012059270.7508-100000@duckman.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: roger.larsson@norran.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

BTW, what loop are you trying to "continue;" out of here?

+			    do {
 				if (tsk->need_resched)
 					schedule();
 				if ((!zone->size) || (!zone->zone_wake_kswapd))
 					continue;
 				do_try_to_free_pages(GFP_KSWAPD, zone);
+			   } while (zone->free_pages < zone->pages_low &&
+					   --count);

:-)  Just add a "next_zone:" label at the end of that code and
change the continue; to a goto next_zone;

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
