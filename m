Received: from samar (localhost [127.0.0.1])
	by samar.sasken.com (8.11.6/8.11.6) with SMTP id g1BEqbK08530
	for <linux-mm@kvack.org>; Mon, 11 Feb 2002 20:22:37 +0530 (IST)
Received: from localhost (srikanta@localhost)
	by sunrnd2.sasken.com (8.11.6/8.11.6) with ESMTP id g1BEqYk14387
	for <linux-mm@kvack.org>; Mon, 11 Feb 2002 20:22:34 +0530 (IST)
Date: Mon, 11 Feb 2002 20:22:34 +0530 (IST)
From: Srikanta R <srikanta@sasken.com>
Subject: Memory Usage
Message-ID: <Pine.GSO.4.30.0202112019040.14124-100000@sunrnd2.sasken.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Which variable in /proc/meminfo (using 2.4.8 kernel)gives me the
correct memory usage at any point of time.
The problem is when I run my application, the "MemFree:" variable under
/proc/meminfo drops from around 25MB to 16MB. I kill the application
and "MemFree:" shows 17MB. How do I get the actual Memory being used ? ie
after I kill the application I should get "MemFree: = 25MB".

If I do the calculation which is being done in procedure -
nr_free_buffer_pages() (linux/mm/page_alloc.c) i.e adding the
zone->free_pages ,zone->inactive_clean_pages,
zone->inactive_dirty_pages, for all the zones, do I get the exact free RAM
available at any point of time(taking into consideration caching and all)
?

Thanks for any help or pointers.

Rgds,
Srikanta.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
