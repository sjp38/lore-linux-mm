Received: from ANDREW.CMU.EDU (WEBMAIL3.andrew.cmu.edu [128.2.10.93])
	by smtp5.andrew.cmu.edu (8.12.9/8.12.3.Beta2) with SMTP id h76MWBuN024272
	for <Linux-MM@kvack.org>; Wed, 6 Aug 2003 18:32:11 -0400
Message-ID: <2110.128.2.222.155.1060209130.squirrel@webmail.andrew.cmu.edu>
Date: Wed, 6 Aug 2003 18:32:10 -0400 (EDT)
Subject: Free list initialization
From: "Anand Eswaran" <aeswaran@andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all:

  Could anybody point me out to the part of the mm code where the  zone
free-lists are initialized to the remaining system memory  just
subsequent to setting up of the zone structures . ( so that  say when
the very first time _alloc_pages executes, the system can use (
__alloc_pages ()  ->   rmqueue()  free-list to allocate the required
memory block.

  I dont seem to be able to find any such code in free_area_init_core().

  Im using a 2.4.18 kernel.

Thanks in advance,
-----
Anand
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
