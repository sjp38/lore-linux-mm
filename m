Message-ID: <39B33D14.C7239FB8@sgi.com>
Date: Sun, 03 Sep 2000 23:11:32 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Bad page count
 	 with 2.4.0-t8p1-vmpatch2b
References: <8oufh6$ns780$1@fido.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The previous boot problem was apparently due to a
bad run of lilo: at that time test8-pre2 was on
the system, so may be there is some problem in test8-pre2.
Anyway, I can now boot test8-pre1 + 2.4.0-t8p1-vmpatch2b.
But a simple copy of a large file (filesize > memsize)
brings out lots of messages on the console:

---------
Bad page count
Bad page count
Bad page count
Bad page count
---------------


--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
