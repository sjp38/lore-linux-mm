Date: Mon, 14 Aug 2000 19:30:04 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [prePATCH] new VM for linux-2.4.0-test4
In-Reply-To: <Pine.LNX.4.21.0008141909040.1599-200000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0008141928370.1599-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0008141928372.1599@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 14 Aug 2000, Rik van Riel wrote:

> here is version #6 of the new VM patch, against 2.4.0-test4.
> 
> Thanks to watashi on #kernelnewbies, the memory leak has been
> removed from the code and this patch _actually works_...

AAARRRGGGHHHHH......

OK, I overlooked one of the bad bad bad mistakes watashi 
saw .. here is an -incremental- patch to fix the last
possible source of memory leakage...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.4.0-test4/mm/page_alloc.c.p6	Mon Aug 14 19:27:52 2000
+++ linux-2.4.0-test4/mm/page_alloc.c	Mon Aug 14 19:28:08 2000
@@ -373,7 +373,7 @@
 			if (direct_reclaim)
 				page = reclaim_page(z);
 			if (!page)
-				rmqueue(z, order);
+				page = rmqueue(z, order);
 			if (page)
 				return page;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
