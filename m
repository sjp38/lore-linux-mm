Date: Thu, 12 Dec 2002 00:39:06 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: strange bug rmap15a
Message-ID: <Pine.LNX.4.50L.0212120037060.21756-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

OK, something between rmap15 and rmap15a is triggering the
following bug, where launder_page() really doesn't know
what to do with a page that:
1) has a page->count of 1
2) does not have mapping, buffers, or pte_chain set
3) is clean

mystery page c1028220, cnt 1 map 00000000, buf 00000000, ptec 00000000, dirty 0

I don't know how the pages end up in this situation, but it's
not a pretty sight and effectively kills the machine...

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
