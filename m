Received: from inablers.net [192.9.200.81]
	by inablers.net [192.9.200.103]
	with SMTP (MDaemon.PRO.v4.0.5.T)
	for <linux-mm@kvack.org>; Wed, 26 Dec 2001 13:10:33 +0530
Message-ID: <3C297B9E.65C4767@inablers.net>
Date: Wed, 26 Dec 2001 12:56:22 +0530
From: Vishwanath <vishwanath@inablers.net>
MIME-Version: 1.0
Subject: few doubts in mm
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all
I am new to this mailing list and also Memory management in linux.
I have a doubt that how exactly the convertion of virtual address to
physical addr
happens. As for i have read in Linux Kernel Internals, it says there is
some thing
called page directory, page middle dir and page table, The virtual addr
is divided into
4 parts(len not mentioned), The first part is index to page dir.

What exactly the page dir entry contains an address or a number index to
page middle dir, if index,
then where the base addr of page dir is stored, and base addr of page
middle dir, and page tabe are
stored.

How exactly this happens, The book also says that x86 supports only 2
level convertion.
How do i find out what my machine supports, i have linux kernel code of
v2.4.x

Please do help me out.

Thanx in advance
Vishy





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
