Received: from recw.ernet.in (recw.ernet.in [202.141.49.8])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA08521
	for <Linux-MM@kvack.org>; Wed, 31 Mar 1999 09:57:25 -0500
Message-ID: <370237BF.D730EE6B@angelfire.com>
Date: Wed, 31 Mar 1999 20:27:03 +0530
From: student <sirupa@angelfire.com>
Reply-To: sirupa@angelfire.com
MIME-Version: 1.0
Subject: Linux Source Code
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

                       I want to change the kernel Source code of
Redhat linux 5.2  as a project.
                   I  want to open /create a file  through a system
call, in the source
                    code.
                    I made it through sys_open.
                    This I kept in arp_rcv function of
/usr/src/linux-2.0.36/net/ipv4/arp.c file.
                    While running it, I am getting a error of "gfp
nonautomatically called
                    by interrupt 0000003".
                    This error is in the file
/usr/src/linux-2.0.36/mm/page_alloc.c

                    Please tell me how I can open a file in source code
through system
                    calls.
                    I am unable to open a semaphore ans shared memory
also.
                    i am getting an error of "kmalloc called
nonautomically by interrupt
                    0000030",
                    which is in the file
/usr/src/linux-2.0.36/mm/kmalloc.c


                    Please reply me to sreedhar@angelfire.com
                                Thanking U,
                                                     G.Sreedhar





--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
