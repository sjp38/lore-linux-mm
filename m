Received: from localhost (riel@localhost)
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id RAA14857
	for <linux-mm@kvack.org>; Fri, 26 May 2000 17:58:21 -0300
Date: Fri, 26 May 2000 17:58:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] deferred swapping + page aging
Message-ID: <Pine.LNX.4.21.0005261756270.26570-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Here is a WORKING version of the deferred swapping & page aging
patch for 2.4.0-test1.

The patch implements:
- deferred IO for pageout
- rudimentary page aging, a start of what we want
  for when we have an active list later

TODO:
- deferred swapping for other IO (file, shm)
- page aging for all pages
- inactive / laundry / cache queues
- ...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
