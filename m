Date: Sat, 29 Apr 2000 06:54:26 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [PATCH] arghhhh
Message-ID: <Pine.LNX.4.21.0004290653340.23622-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

It appears that my last patch was missing a semicolon after the
while() loop ... arghhhh

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- mm/vmscan.c.org2	Sat Apr 29 06:53:00 2000
+++ mm/vmscan.c	Sat Apr 29 06:53:12 2000
@@ -388,7 +388,7 @@
 					continue;
 				/* small processes are swapped out less */
 				while ((mm->swap_cnt << 2 * (i + 1) < max_cnt)
-						&& i++ < 10)
+						&& i++ < 10);
 				mm->swap_cnt >>= i;
 				mm->swap_cnt += i; /* if swap_cnt reaches 0 */
 				/* we're big -> hog treatment */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
