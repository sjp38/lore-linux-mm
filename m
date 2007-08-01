Date: Wed, 1 Aug 2007 11:24:49 +0100
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various purposes
Message-ID: <20070801102449.GD31440@skynet.ie>
References: <20070727194316.18614.36380.sendpatchset@localhost> <20070727194322.18614.68855.sendpatchset@localhost> <20070731192241.380e93a0.akpm@linux-foundation.org> <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com> <20070731200522.c19b3b95.akpm@linux-foundation.org> <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com> <20070731203203.2691ca59.akpm@linux-foundation.org> <Pine.LNX.4.64.0707312151400.2894@schroedinger.engr.sgi.com> <20070731220727.1fd4b699.akpm@linux-foundation.org> <Pine.LNX.4.64.0707312214350.2997@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707312214350.2997@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On (31/07/07 22:22), Christoph Lameter didst pronounce:
> On Tue, 31 Jul 2007, Andrew Morton wrote:
> 
> > > Anyone have a 32 bit NUMA system for testing this out?
> > test.kernel.org has a NUMAQ
> 
> Ok someone do this please. SGI still has IA64 issues that need fixing 
> after the merge (nothing works on SN2 it seems) and that takes precedence.
> 

I've queued up what was in the numa.git tree for a number of machines
including elm3b132 and elm3b133 on test.kernel.org again 2.6.23-rc1-mm2. With
the release of -mm though there is a long queue so it'll be several hours
before I have any results; tomorrow if it does not go smoothly.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
