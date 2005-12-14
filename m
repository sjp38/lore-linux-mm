Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBE7oauM013391
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 02:50:36 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBE7qFkD103902
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 00:52:15 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBE7oZ8s003278
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 00:50:35 -0700
Message-ID: <439FCECA.3060909@us.ibm.com>
Date: Tue, 13 Dec 2005 23:50:34 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/6] Critical Page Pool
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Here is the latest version of the Critical Page Pool patches.  Besides
bugfixes, I've removed all the slab cleanup work from the series.  Also,
since one of the main questions about the patch series seems to revolve
around how to appropriately size the pool, I've added some basic statistics
about the critical page pool, viewable by reading
/proc/sys/vm/critical_pages.  The code now exports how many pages were
requested, how many pages are currently in use, and the maximum number of
pages that were ever in use.

The overall purpose of this patch series is to all a system administrator
to reserve a number of pages in a 'critical pool' that is set aside for
situations when the system is 'in emergency'.  It is up to the individual
administrator to determine when his/her system is 'in emergency'.  This is
not meant to (necessarily) anticipate OOM situations, though that is
certainly one possible use.  The purpose this was originally designed for
is to allow the networking code to keep functioning despite the sytem
losing its (potentially networked) swap device, and thus temporarily
putting the system under exreme memory pressure.

Any comments about the code or the overall design are very welcome.
Patches agaist 2.6.15-rc5.

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
