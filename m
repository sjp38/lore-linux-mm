Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17VMOL-0007dj-00
	for <linux-mm@kvack.org>; Thu, 18 Jul 2002 18:17:09 -0700
Date: Thu, 18 Jul 2002 18:17:09 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: preliminary report on pagetable occupation rates
Message-ID: <20020719011709.GD1022@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I added a statistic PteChainActv counting the number of reverse
mappings performed, as opposed to the number of pte_chains allocated,
as Dave McCracken's optimization defeats space consumption of
pte_chains as a metric of pagetable occupancy.

This was collected during a run of tbench 4096 on a 16 cpu 16GB i386.

The steady state result is:

PageTables:      98564 kB
PteChainTot:      8508 kB
PteChainUsed:     8408 kB
PteChainActv:  1236684

Where this implies an occupancy rate of:

	(1236684*4)/98564 = 50.1881


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
