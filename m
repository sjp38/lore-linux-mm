Date: Fri, 27 Apr 2001 03:17:33 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] bgaging + balance  v2
In-Reply-To: <Pine.LNX.4.21.0104262206310.19012-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.21.0104270317090.2587-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 26 Apr 2001, Rik van Riel wrote:

> Hi,
> 
> in my patch yesterday evening there was a big mistake;
> the old line calculating maxscan wasn't removed, so all
> the fancy recalculation wouldn't do anything ;)

How about this patch on top of yours? ;)

--- linux.orig/mm/vmscan.c      Fri Apr 27 04:32:52 2001
+++ linux/mm/vmscan.c   Fri Apr 27 04:32:34 2001
@@ -644,6 +644,7 @@
        struct page * page;
        int maxscan = nr_active_pages >> priority;
        int page_active = 0;
+       int start_count = count;
 
        /*
         * If no count was specified, we do background page aging.
@@ -725,7 +726,7 @@
        }
        spin_unlock(&pagemap_lru_lock);
 
-       return count;
+       return (start_count - count);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
