From: "Min San Co" <mc343@hotmail.com>
Subject: questions about LRU
Date: Fri, 17 Nov 2000 23:02:00 GMT
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Message-ID: <LAW-F137bdkSmLAztxc000006da@hotmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

I am trying to implement the LRU page replacement scheme (Least-Recently 
Used).  My idea is to what create a queue that contains pointers to every 
page held by every process in the system.  This queue should be sorted to 
reflect the most recently used pages, which should be at the front.  I am 
thinking of manipulating this list on every timer interrupt (ie 10 msec).  
After every interrupt, the ordering of pages on the queue will be updated 
based on what pages have been accessed since the last timer interrupt.  I am 
thinking of using the reference bit to determine which page has been 
accessed since the last timer interrupt.  The pages that have been recently 
used will be moved to the front of the queue.

Any ideas on where to put the queue?

Cheers!

Max C.

_________________________________________________________________________
Get Your Private, Free E-mail from MSN Hotmail at http://www.hotmail.com.

Share information about yourself, create your own public profile at 
http://profiles.msn.com.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
