Received: from razdva.cz ([212.65.201.116]) by fepZ.post.tele.dk
          (InterMail vM.4.01.03.00 201-229-121) with ESMTP
          id <20010324100234.SLKB14508.fepZ.post.tele.dk@razdva.cz>
          for <linux-mm@kvack.org>; Sat, 24 Mar 2001 11:02:34 +0100
Message-ID: <3ABC7008.B9EB4047@razdva.cz>
Date: Sat, 24 Mar 2001 10:59:36 +0100
From: Petr Dusil <pdusil@razdva.cz>
MIME-Version: 1.0
Subject: Reduce Linux memory requirements for an Embedded PC
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello All,

I am developing a Linux distribution for a Jumptec Embedded PC. It is
targeted to an I486, 16MB DRAM, 16MB DiskOnChip. I have decided to use
Redhat 6.2  (2.2.14 kernel) and to reduce its size to fit the EPC. I
have simplified the kernel (removed support of all unwanted hardware),
init scripts and amount of apps I will really need. I do not have
problems with its size on disk (8MB), but I do see a problem in its
memory requirements. It takes now about 11MB. It is too much. I tried to
replace init by sulogin to get bash shell and look into the system
memory as soon as possible, but again without starting any daemon only
with bash running I got 7MB. I am asking you, is there any option to
tell Linux kernel "save the memory" or what are the general
recommendations to minimize amount of memory the kernel consumes?

Thank you very much for an answer,

Petr


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
