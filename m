Message-ID: <39E25034.6B1203CE@sgi.com>
Date: Mon, 09 Oct 2000 16:09:40 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Write-back/VM question
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

One of the behaviors of the new VM seems
to be that it starts I/O on a written page
fairly early. This "aggressive" write is
great for streaming I/O, but seems to have
a penalty when the application has write-locality.
Dbench is a one case, which is write intensive
and a lot of the writes are to a previously written page.

I'm not exactly certain why starting write-out
early would cause problems, but I've a couple of
quick questions:

1. Is the page locked during write-out?

2. Is there a tuneable that I can use to
   control write-back behaviour?

thanks!


-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
