Received: from velma.ittc.ukans.edu (velma.ittc.ku.edu [129.237.127.164])
	by stephens.ittc.ku.edu (8.11.2/8.11.2/ITTC-NOSPAM-NOVIRUS-2.2) with ESMTP id g0F6lEt23844
	for <linux-mm@kvack.org>; Tue, 15 Jan 2002 00:47:14 -0600
Date: Tue, 15 Jan 2002 00:47:13 -0600 (CST)
From: Subhash Induri <subhashiv@ittc.ku.edu>
Subject: How to increase a processes memory
Message-ID: <Pine.LNX.4.21.0201150040020.22980-100000@velma.ittc.ukans.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
  I need a small help regarding increasing the amount of memory allocated
to a process.
  My system has 4Gb of RAM.. my process needs about 3GB of memory..Is
there in any way i can increase the memory allocated by the system..So
that my process's data may not be frequently swapped in and out.. As of
now the process runs very slow... I figure this to be cos of the amount of
swapping that would take place..If anyone could help me out, it would be
really great..
  An additional information about my process is that it uses memory-mapped
files, .. files which are mapped to the processes memory.. and thats the
only reason my process consumes that much of memory..
Thanks a lot
subhash

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
