Received: from mvista.com (IDENT:sanders@dhcp41.mvista.com [10.0.10.41])
	by hermes.mvista.com (8.11.0/8.11.0) with ESMTP id f4MKOe027391
	for <linux-mm@kvack.org>; Tue, 22 May 2001 13:24:41 -0700
Message-ID: <3B0ACB08.C9032ADB@mvista.com>
Date: Tue, 22 May 2001 20:24:40 +0000
From: Scott Anderson <scott_anderson@mvista.com>
MIME-Version: 1.0
Subject: vm_enough_memory() and RAM disks
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've noticed that vm_enough_memory() does not account for the
fact that buffer cache could be used for RAM disks.  It appears that it
assumes that all of buffer cache is only being used for caching data
from disk drives and could be freed up as needed.  Logically, I think
what needs to happen is that the amount of space occupied by buffers
with BH_Protected needs to be subtracted off of buffermem_pages.

As you can well imagine, in small systems with relatively large RAM
disks, this does not lead to good behavior...

Now for the true confession: I'm not finding time to come up with a
patch for this right now.  However, I thought it would be better to at
least get this out instead of waiting around for me to find the time.

Thanks for listening,
    Scott Anderson
    scott_anderson@mvista.com   MontaVista Software Inc.
    (408)328-9214               1237 East Arques Ave.
    http://www.mvista.com       Sunnyvale, CA  94085
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
