Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l71Fw4Vf019069
	for <linux-mm@kvack.org>; Wed, 1 Aug 2007 11:58:04 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l71Fw4ws168856
	for <linux-mm@kvack.org>; Wed, 1 Aug 2007 09:58:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l71Fw3N5021144
	for <linux-mm@kvack.org>; Wed, 1 Aug 2007 09:58:04 -0600
Date: Wed, 1 Aug 2007 08:58:03 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various purposes
Message-ID: <20070801155803.GG31324@us.ibm.com>
References: <20070727194316.18614.36380.sendpatchset@localhost> <20070727194322.18614.68855.sendpatchset@localhost> <20070731192241.380e93a0.akpm@linux-foundation.org> <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com> <20070731200522.c19b3b95.akpm@linux-foundation.org> <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 31.07.2007 [20:14:08 -0700], Christoph Lameter wrote:
> On Tue, 31 Jul 2007, Andrew Morton wrote:
> 
> > ooookay...   I don't think I want to be the first person who gets
> > to do that, so I shall duck them for -mm2.
> > 
> > I think there were updates pending anyway.   I saw several under-replied-to
> > patches from Lee but it wasn't clear it they were relevant to these changes
> > or what.
> 
> I have not seen those. We also have the issue with slab allocations 
> failing on NUMAQ with its HIGHMEM zones. 
> 
> Andi wants to drop support for NUMAQ again. Is that possible? NUMA only on 
> 64 bit?
> 
> I have checked the current patchset and the fix into a git archive. 
> Those interested in working on this can do a
> 
> git pull git://git.kernel.org/pub/scm/linux/kernel/git/christoph/numa.git memoryless_nodes
> 
> to get the current patchset (This is a bit rough. Sorry Lee the attribution is screwed
> up but we will fix this once I get the hang of it).

Are you sure this is uptodate? Acc'g to gitweb, the last commit was July
22... And I don't see a 'memoryless_nodes' ref in `git peek-remote`.

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
