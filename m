Received: from modem-68.aerodactyl.dialup.pol.co.uk ([217.135.4.68] helo=newt.marston)
	by mail6.svr.pol.co.uk with esmtp (Exim 3.13 #0)
	id 15ITCJ-0001QC-00
	for linux-mm@kvack.org; Fri, 06 Jul 2001 11:50:55 +0100
Received: from newt.marston ([192.168.2.1] helo=humboldt.co.uk)
	by newt.marston with esmtp (Exim 3.12 #1 (Debian))
	id 15ITC2-0000Nb-00
	for <linux-mm@kvack.org>; Fri, 06 Jul 2001 11:50:38 +0100
Message-ID: <3B4597FE.7070901@humboldt.co.uk>
Date: Fri, 06 Jul 2001 11:50:38 +0100
From: Adrian Cox <adrian@humboldt.co.uk>
MIME-Version: 1.0
Subject: Use of mmap_sem in map_user_kiobuf
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Does map_user_kiobuf really need to get a write lock on the mmap_sem? 
 From examination of the code, all it can do is expand_stack(), fault in 
pages, and increment the count on a page.

Is there anything I've missed? Would it be safe to use down_read(), 
up_read() instead?

-- 
Adrian Cox   http://www.humboldt.co.uk/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
