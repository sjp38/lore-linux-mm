Date: Wed, 21 Aug 2002 22:39:26 +0500 (GMT+0500)
From: Atm account <linux1@cdotd.ernet.in>
Subject: RAMFS and Swapping
Message-ID: <Pine.OSF.4.10.10208212232070.7953-100000@moon.cdotd.ernet.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello All,
   I have  a  simple doubt regarding use Of RAMFS.In which cases should i
use ramfs/shmfs/tmpfs?

  If  i create  a RAMFS  on  "RAM" and  run binaries from RAMFS
created.Would the pages would be swapped to swap device or not.Whether
the physical pages allocated to the RAMFS would be part of page cache or
not.
     
Anil 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
