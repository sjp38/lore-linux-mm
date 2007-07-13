Subject: Re: [patch 00/12] NUMA: Memoryless node support V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707131022140.22340@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>
	 <20070713151431.GG10067@us.ibm.com>
	 <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
	 <1184347239.5579.3.camel@localhost>
	 <Pine.LNX.4.64.0707131022140.22340@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 13 Jul 2007 16:53:52 -0400
Message-Id: <1184360032.5579.17.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Had a chance to build/boot the latest series with the updated #7, ...

Quite a few offsets and one reject in #7, but easy to resolve.

Boots OK.  Quick test of hugetlb allocation on my platform shows the old
behavior with huge pages doubling up on the node that the "memoryless"
one falls back on.  Guess this is expected until we get Nish's patch
atop this one.

Next week I'll reconfig a platform fully interleaved which will result
in all of the real nodes appearing memoryless and do more testing.

Have a nice vacation.

Nish:

Shall I try to rebase your patches atop Christoph's in my tree?

The last ones I have are from 19jul:

	01-fix-hugetlb-pool-allocation-with-memoryless-nodes
	02-hugetlb-numafy-several-functions
	03-add-per-node-nr_hugepages-sysfs-attribute

Do you have more recent ones?

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
