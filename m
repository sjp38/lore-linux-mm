Date: Fri, 15 Sep 2000 22:09:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH *] new VM patch for 2.4.0-test8
Message-ID: <Pine.LNX.4.21.0009152158480.1065-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

today I released a new VM patch with 4 small improvements:

- fixed proc_misc.c compile warnings (Albert Cranford)
- try_to_free_buffers() now actually /frees/ the buffers
  after doing synchronous IO on them ...
- move pages with page->count==2 to the inactive_dirty list
  in deactivate_page() ... this way we'll move a page to the
  inactive_dirty list even while we're holding an extra
  reference count on the page   (system runs smoother now)
- remove the ugly goto from refill_inactive_scan(), use a
  variable instead

This patch seems to make the system run a little bit smoother
under load. Please try it and tell me if/how it works for you.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
