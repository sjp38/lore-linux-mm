Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD4036B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 01:07:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s72so5092247pfi.19
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 22:07:33 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id w6si4915053pfi.411.2017.04.27.22.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 22:07:32 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id g23so15703819pfj.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 22:07:32 -0700 (PDT)
Message-ID: <1493356043.28002.5.camel@gmail.com>
Subject: Re: [RFC 1/4] mm: create N_COHERENT_MEMORY
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 28 Apr 2017 15:07:23 +1000
In-Reply-To: <20170427184213.tco7hu5w2zlm4lpg@arbab-laptop.localdomain>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <20170419075242.29929-2-bsingharora@gmail.com>
	 <20170427184213.tco7hu5w2zlm4lpg@arbab-laptop.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, vbabka@suse.cz, cl@linux.com

On Thu, 2017-04-27 at 13:42 -0500, Reza Arbab wrote:
> On Wed, Apr 19, 2017 at 05:52:39PM +1000, Balbir Singh wrote:
> > In this patch we create N_COHERENT_MEMORY, which is different
> > from N_MEMORY. A node hotplugged as coherent memory will have
> > this state set. The expectation then is that this memory gets
> > onlined like regular nodes. Memory allocation from such nodes
> > occurs only when the the node is contained explicitly in the
> > mask.
> 
> Finally got around to test drive this. From what I can see, as expected,
> both kernel and userspace seem to ignore these nodes, unless you 
> allocate specifically from them. Very convenient.

Thanks for testing them!

> 
> Is "online_coherent"/MMOP_ONLINE_COHERENT the right way to trigger this?  

Now that we mark the node state at boot/hotplug time, I think we can ignore
these changes.

> That mechanism is used to specify zone, and only for a single block of 
> memory. This concept applies to the node as a whole. I think it should 
> be independent of memory onlining.
> 
> I mean, let's say online_kernel N blocks, some of them get allocated, 
> and then you online_coherent block N+1, flipping the entire node into 
> N_COHERENT_MEMORY. That doesn't seem right.
> 

Agreed, I'll remove these bits in the next posting.

Thanks for the review!
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
