Received: from firewall.altersys.com (smap@[206.123.5.4])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA22206
	for <Linux-MM@kvack.org>; Wed, 30 Sep 1998 15:23:01 -0400
Received: (from smap@localhost)
	by firewall.altersys.com (8.8.7/8.8.7) id LAA06306
	for <Linux-MM@kvack.org>; Wed, 30 Sep 1998 11:21:44 -0400
Message-ID: <01BDEC86.186F1DB0@gate.altersys.com>
From: Genevieve Aubut <gaubut@altersys.com>
Subject: Linux memory problem with TIS  firewall
Date: Wed, 30 Sep 1998 15:22:10 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "'Linux-MM@kvack.org'" <Linux-MM@kvack.org>
List-ID: <linux-mm.kvack.org>

We have installed a TIS firewall on a Red Hat Linux (Kernel version 2.0.34) computer.  

Since we installed it, the computer crashes once or twice a day with this error:  
	
	- Unable to handle kernel paging request at virtual address "xxx" for example e03b653c
	and displays a list of addresses  and stack contents  as well as :
	
	- Process http-gw  (pid: ....)

and at the end the message:

	- kfree of non-kmalloced memory ....

The computer is a Pentium MMX 166 with 32 Mb of memory.  
The hard disk contains a swap partition of 400 Mb in a 2.8 Gb.
The only application running is the TIS firewall.  We downloaded 
the most recent version from your ftp site last week.

System Administrator
Altersys Inc.
Montreal - Canada
(450) 674-7774 ext. 225

	
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
