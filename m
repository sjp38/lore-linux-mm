Date: Thu, 13 Jul 2000 16:30:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: writeback list
Message-ID: <Pine.LNX.4.21.0007131628120.23729-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Stephen,

we may have forgotten something in our new new vm design from
last weekend. While we have the list head available to put
pages in the writeback list, we don't have an entry in to put
the timestamp of the write in struct_page...

Maybe we want to have an active list after all and replace the
buffer_head pointer with a pointer to another structure that
tracks the writeback stuff that's now tracked by the buffer head?

(things like: prev, next, write_time and a few other things)

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
