Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m68Hwn8q018817
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 13:58:49 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m68I40Fp075730
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 12:04:00 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m68I3uB7013481
	for <linux-mm@kvack.org>; Tue, 8 Jul 2008 12:03:59 -0600
Date: Tue, 8 Jul 2008 11:03:48 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC PATCH 0/4] -mm-only hugetlb updates
Message-ID: <20080708180348.GB14908@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: mel@csn.ul.ie, agl@us.ibm.com, akpm@linux-foudation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As Nick requested, I've moved /sys/kernel/hugepages to
/sys/kernel/mm/hugepages. I put the creation of the /sys/kernel/mm
kobject in mm_init.c and that required removing the conditional
compilation of that file. This also necessitated a bit of Documentation
updates (and the addition of the /sys/kernel/mm ABI file). Finally, I
realized that kobject usage doesn't require CONFIG_SYSFS, so I was able
to remove one ifdef from hugetlb.c.

Andrew, I believe these patches, if acceptable, should be folded in
place, if possible, in the hugetlb series (that is, the sysfs location
should only ever have appeared to be /sys/kernel/mm/hugepages). The ease
with which that can occur I guess depends on where Mel's
DEBUG_MEMORY_INIT patches are in the series.

1/4: mm: remove mm_init compilation dependency on CONFIG_DEBUG_MEMORY_INIT
2/4: mm: create /sys/kernel/mm
3/4: hugetlb: hang off of /sys/kernel/mm rather than /sys/kernel
4/4: hugetlb: remove CONFIG_SYSFS dependency

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
