Date: Thu, 21 Nov 2002 22:12:03 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH][RFC] split active lists for rmap 15
Message-ID: <Pine.LNX.4.44L.0211212208070.4103-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Arjan van de Ven <arjanv@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

it turns out that while Arjan's O(1) VM code works fine in
most scenarios, it's too swap happy in some cases. In order
to try to fix that I've split up the (per zone) active list
into an active_anon list (process working set) and an
active_cache list (file cache).

If the active_cache list is "large" we deactivate those pages
preferentially. Of course, if those pages really are referenced
they'll just be moved back to the active list and we'll end up
swapping out processes ... but in the common case of streaming
over lots and lots of file data we'll swap out the processes
very slowly, meaning that the machine should stay nicely usable
during eg. bitkeeper pulls, backups and apt-get updates.

This patch is still experimental, so any testing is welcome.

As usual, you can grab it from http://surriel.com/patches/

	http://surriel.com/patches/2.4/2.4.19-rmap15-splitactive

have fun,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
