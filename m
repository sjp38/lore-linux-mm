Message-ID: <20020227183223.99477.qmail@web21110.mail.yahoo.com>
Date: Wed, 27 Feb 2002 18:32:23 +0000 (GMT)
From: =?iso-8859-1?q?Pooja=20Gupta?= <pooja_pict@yahoo.com>
Subject: The Network RAM
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies <kernelnewbies@nl.linux.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello!!
    We are a group of four undergraduate students from
Pune university pune,India. We implemented "The
Network RAM" as our final year BE project.
    It includes basic calls like nram_malloc,
nram_free, nram_sync, nram_rmalloc(for reliable
allocation). It allows you to access remote comps
memory like ur local memory.
    In this implementation server side(server is one
who donates memory) is entirely modular. Client side
is a patch to page fault handler + some modules.
     We have also implemented shared memory API's like
nram_shmget, nram_shmat, nram_shmdel for network wide
shared memory on top of the network ram.
     Now we want to go further in the direction of
testing our implementation, and to test for the
scalability and building of the mathematical model of
our system. Are there any standard test suites
available for testing network memory? What type of
testing should we perform?
     So we would like you all to help us in this
direction. Please suggest the ways and guide us in
proper direction.

Pooja Gupta
Amber Palekar
Amey Inamdar
Aniruddha Patwardhan


 

________________________________________________________________________
Looking for a job?  Visit Yahoo! India Careers
      Visit http://in.careers.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
