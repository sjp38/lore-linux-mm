Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with SMTP id 709B2ACCB5
	for <linux-mm@kvack.org>; Fri,  2 Jun 2000 21:24:13 -0400 (EDT)
From: Ed Tomlinson <tomlins@cam.org>
Reply-To: tomlins@cam.org
Subject: June 2 mm patch (#2) and swap
Date: Fri, 2 Jun 2000 21:18:45 -0400
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <00060221241300.02707@oscar>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This patch seems to be alergic to swap.  When I decided to try to force
the issue (open lots apps) X was killed...  Think there is something not 
quite right with ac7+patch #2,  Note vmstat showed zero swapped space and
I would expect at the very least a few 1000...

Reverting to version #1 here, look forward to version #3 as things do seem
to be moving in the right dirrection.

Please reply via direct email I am not subscribed to linux-mm

TIA

Ed Tomlinson <tomlins@cam.org>
http://www.cam.org/~tomlins/njpipes.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
