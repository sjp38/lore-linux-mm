Received: from localhost (amitjain@localhost)
	by mailhost.tifr.res.in (8.9.3+3.2W/8.9.3/Debian 8.9.3-21) with ESMTP id PAA31012
	for <linux-mm@kvack.org>; Sat, 30 Mar 2002 15:27:30 +0530
Date: Sat, 30 Mar 2002 15:27:30 +0530 (IST)
From: "Amit S. Jain" <amitjain@tifr.res.in>
Subject: Memory allocation in Linux
Message-ID: <Pine.LNX.4.21.0203301519070.30461-100000@mailhost.tifr.res.in>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello everyone,
               I am confused about the concept of memory allocation in
Linux and hope u all can please clear this.
Obtaining large amount of continuous memory from the kernel is not a
good practice and is also not possible.However,as far as non-contiguous
memory is concerned ...cant those be obtained in huge amounts (I am talkin
in terms of MB).Using get_free_pages or vmalloc cant large amounts of
memory be obtained.I tried doing this but I got continuous message ssayin
PCI bus error 2290...wass this bout???ne idea. 

Also,I will be highly obliged if you could refer a good document which can
gimme a good explaination bout mmap function.I basically want to obtain
zero copy from the user area straigt to the network interface without any
copies in the kernel area. kiobuff can provide one such interface,however
I also want to try using mmap....so please could u refer me some good
document.   

Thanking you
Regards
Amit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
