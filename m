Received: from mail3.siemens.de (mail3.siemens.de [139.25.208.14])
	by david.siemens.de (8.11.7/8.11.7) with ESMTP id i09Ci6n01318
	for <Linux-mm@kvack.org>; Fri, 9 Jan 2004 13:44:07 +0100 (MET)
Received: from mchp9j9a.mch.sbs.de (mchp9j9a.mch.sbs.de [139.25.23.67])
	by mail3.siemens.de (8.11.7/8.11.7) with ESMTP id i09Ci6j09344
	for <Linux-mm@kvack.org>; Fri, 9 Jan 2004 13:44:06 +0100 (MET)
Message-ID: <ABEA1688CB6AD511814A0003470CEF60CC5EB2@MCHP9GQA>
From: Hansmair Ulrich <ulrich.hansmair@siemens.com>
Subject: hidden files in shmfs
Date: Fri, 9 Jan 2004 13:40:26 +0100 
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'Linux-mm@kvack.org'" <Linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hi,


linux:~ # df /dev/shm
Filesystem           1K-blocks      Used Available Use% Mounted on
shmfs                 10485760   1389068   9096692  14% /dev/shm
linux:~ # df -i /dev/shm
Filesystem            Inodes   IUsed   IFree IUse% Mounted on
shmfs                1011154       7 1011147    1% /dev/shm
linux:~ # ls /dev/shm
.  ..


I've 7 inodes but can't see any files in /dev/shm. who is using 1,4 Gig ?
ipcs says

linux:~ # ipcs -m
------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00004dbe 33488896   root      777        239060     0
0x0382bea5 33554434   sidadm    666        4096       0

looks like shmfs is slowly running full and no shared memory available
at the end of the day. is rebooting the only solution?

I'm running suse kernel 2.4.19-304.

cheers
uli

 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
