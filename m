Received: from ANDREW.CMU.EDU (WEBMAIL1.andrew.cmu.edu [128.2.10.91])
	by smtp6.andrew.cmu.edu (8.12.9/8.12.3.Beta2) with SMTP id h8DG7Gik003934
	for <linux-mm@kvack.org>; Sat, 13 Sep 2003 12:07:16 -0400
Message-ID: <4939.128.2.216.53.1063469235.squirrel@webmail.andrew.cmu.edu>
Date: Sat, 13 Sep 2003 12:07:15 -0400 (EDT)
Subject: scan_swap_map
From: "Anand Eswaran" <aeswaran@andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi :

  Based on the scan_swap_map() code in swapfile.c in Linux 2.4, it seems
to me that the swapmap cannot get fragmented ie there will *ALWAYS* be
contiguous allocation within the swap device.

(1) Within a cluster, there is always contiguous allocation of free swap
entries.

(2) As soon as a cluster is filled with 1's, a new cluster is chosen
HOWEVER, since lowest_bit is marked as the lowest free entry offset,
and assuming that the system started aligned to SWAPFILE_CLUSTER, the new
cluster will again be contigous to the previous cluster.

  If this is true, I dont understand the need for the "fine-grained" for
loop in which a brute force scan is made to find any free entry - it
seems to me like this code will never need to be executed.

  Am I missing something important here?

Thanks,
-----
Anand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
