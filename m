Date: Mon, 1 May 2000 11:46:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [PATCH] pre7-1 semicolon & nicely readable
Message-ID: <Pine.LNX.4.21.0005011143510.5695-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi Linus,

after getting a number of complaints that the semicolon
thing wasn't nicely readable (they're right) I changed my
code as per the patch below.

Could you please put the more readable version in the
next pre kernel?

thanks,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- mm/vmscan.c.org2	Sat Apr 29 06:53:00 2000
+++ mm/vmscan.c	Mon May  1 11:42:34 2000
@@ -384,11 +384,12 @@
 			for (; p != &init_task; p = p->next_task) {
 				int i = 0;
 				struct mm_struct *mm = p->mm;
-				if (!p->swappable || !mm || mm->rss <= 0)
+				if (!p->swappable || !mm || mm->swap_cnt <= 0)
 					continue;
 				/* small processes are swapped out less */
 				while ((mm->swap_cnt << 2 * (i + 1) < max_cnt)
-						&& i++ < 10)
+						&& i < 10)
+					i++;
 				mm->swap_cnt >>= i;
 				mm->swap_cnt += i; /* if swap_cnt reaches 0 */
 				/* we're big -> hog treatment */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
