Received: from cesarb by cesarb2.cesarb.personal with local (Exim 3.12 #1 (Debian))
	id 13GAYO-0000OO-00
	for <linux-mm@kvack.org>; Sat, 22 Jul 2000 22:27:40 -0300
Date: Sat, 22 Jul 2000 22:27:40 -0300
Subject: Inter-zone swapping
Message-ID: <20000722222740.A1475@cesarb.personal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(I'm a complete newbie at vm, so if I'm saying something stupid here, don't be
 so hard on me)

I've been thinking about the following scenario: by some random chance, we have
the DMA zone full of recent pages, the normal zone full of old pages, and the
highmem zone empty (I don't have that much memory). So the right place to page
out from would be the normal zone (since if we swap out from the DMA zone we'll
be swapping out a page a program will need soon). But suppose the DMA zone is
almost full, so something needs to be taken from it or we might risk not having
free memory for atomic allocations for the sound card (or other random
DMA-using driver).

Then would it be useful to "swap" a page from the DMA zone into the normal zone
(and of course after that ending up swapping from the normal zone to the disk)?

-- 
Cesar Eduardo Barros
cesarb@nitnet.com.br
cesarb@dcc.ufrj.br
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
