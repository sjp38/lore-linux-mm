Received: from tuke.sk (sfinx.uvt.tuke.sk [147.232.1.98])
	by ccsun.tuke.sk (8.9.3/8.9.3/Debian/GNU) with ESMTP id MAA22435
	for <linux-mm@kvack.org>; Thu, 24 Aug 2000 12:13:30 +0200
Message-ID: <39A4F548.B8EB5308@tuke.sk>
Date: Thu, 24 Aug 2000 12:13:28 +0200
From: Jan Astalos <astalos@tuke.sk>
MIME-Version: 1.0
Subject: Question: memory management and QoS
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I have a question about possibility to provide Quality of Service
guaranties by Linux memory management. I'm asking this in the
context of possible use of Linux clusters in computational grids
(http://www.gridforum.org/). There is still more computing power
(mostly unused) in workstations...

One of the most important issues (IMO) is QoS. Especially, how
OS can guarantee availability of resources. Since Linux is 
top-ranking OS in high-performance clusters, obviously there will
be need to implement QoS in it.

So, why am I writing this to this list ? In last couple of days
I was experimenting with Linux MM subsystem to find out whether
Linux can (how it could) assure exclusive access to some amount 
of memory for user. Of course I was searching the archives. So 
far, I found only the beancounter patch, which is designed for 
limiting of memory usage. This is not quite exactly what I am 
looking for. Rather, users should have their memory reserved... 

If I missed something please send me the pointers.

I have some (rough) ideas how it could work and I would be 
happy if you'll send me your opinions.

Concept of personal swapfiles:

- each user would have its own swapfile (size would depend on 
  his memory needs and disk quota, he would be able to resize it)
- system swapfile would be shared between daemons and superuser
- each active user would have some amount of physical pages 
  allocated (according to selected policy)

The benefits (among others):
- there wouldn't be system OOM (only per user OOM)
- user would be able to check his available memory
- no limits for VM address space
- there could be more policies for sharing of physical memory
  by users (and system)

Drawbacks:
<please fill>

Thanks in advance for your comments,

Jan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
