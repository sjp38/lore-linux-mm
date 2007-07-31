Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6VNIWbG013926
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 19:18:32 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6VNIW4H217666
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 17:18:32 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6VNIW6S001010
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 17:18:32 -0600
Date: Tue, 31 Jul 2007 16:18:31 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 00/14] NUMA: Memoryless node support V4
Message-ID: <20070731231831.GC31324@us.ibm.com>
References: <20070727194316.18614.36380.sendpatchset@localhost> <20070730211937.GD5668@us.ibm.com> <Pine.LNX.4.64.0707301503560.21604@schroedinger.engr.sgi.com> <200707310035.09046.ak@suse.de> <Pine.LNX.4.64.0707301535580.22570@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707301535580.22570@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On 30.07.2007 [15:36:19 -0700], Christoph Lameter wrote:
> On Tue, 31 Jul 2007, Andi Kleen wrote:
> 
> > 
> > > Hmmm... yes trouble with NUMAQ is that the nodes only have HIGHMEM
> > > but no NORMAL memory. The memory is not available to the slab
> > > allocator (needs ZONE_NORMAL memory) and we cannot fall back
> > > anymore. We may need something like N_SLAB that defines the
> > > allowed nodes for the slab allocators. Sigh.
> > 
> > Or just disable 32bit NUMA. The arch/i386 numa code is beyond ugly
> > anyways and I don't think it ever worked particularly well.
> 
> So we would no longer support NUMAQ? Is that possible?

Seems a bit excessive in the context of these patches. The kernel worked
before this stack and doesn't with it. Then again, I guess NUMAQ only
worked because it relied on a fallback that shouldn't have happened?

I'm not sure what the best solution is -- maybe Andy has some insight?

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
