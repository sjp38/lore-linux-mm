Date: Wed, 13 Nov 2002 12:12:03 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: PATCH -ac -> -rmap 5/4
Message-ID: <Pine.LNX.4.44L.0211131211040.3817-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

this surprise patch (by arjan) adds a wmb() to the kswapd
sleep path and is needed for some reason I've forgotten
already

please apply,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://distro.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>


--- linux-2.4.19/mm/vmscan.c	2002-11-13 09:27:15.000000000 -0200
+++ linux-2.4-rmap/mm/vmscan.c	2002-11-13 12:10:46.000000000 -0200
@@ -848,6 +848,7 @@
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	schedule_timeout(HZ / 4);
 	kswapd_overloaded = 0;
+	wmb();
 	return;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
