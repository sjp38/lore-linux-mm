Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0165D6B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 23:20:59 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so812560pab.29
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 20:20:59 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id px5si815798pac.56.2014.07.22.20.20.58
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 20:20:59 -0700 (PDT)
Message-ID: <53CF29F4.7040700@linux.intel.com>
Date: Wed, 23 Jul 2014 11:20:20 +0800
From: Jiang Liu <jiang.liu@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch V1 15/30] mm, igb: Use cpu_to_mem()/numa_mem_id()
 to support memoryless node
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-16-git-send-email-jiang.liu@linux.intel.com> <20140721174218.GD4156@linux.vnet.ibm.com> <CAKgT0UdZdbduP-=R7uRCxJVxt1yCDoHpnercnDoyrCbWNtx=6Q@mail.gmail.com> <20140721210900.GI4156@linux.vnet.ibm.com>
In-Reply-To: <20140721210900.GI4156@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Bruce Allan <bruce.w.allan@intel.com>, Carolyn Wyborny <carolyn.wyborny@intel.com>, Don Skidmore <donald.c.skidmore@intel.com>, Greg Rose <gregory.v.rose@intel.com>, Alex Duyck <alexander.h.duyck@intel.com>, John Ronciak <john.ronciak@intel.com>, Mitch Williams <mitch.a.williams@intel.com>, Linux NICS <linux.nics@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>

Hi Nishanth and Alexander,
	Thanks for review, will update the comments
in next version.
Regards!
Gerry

On 2014/7/22 5:09, Nishanth Aravamudan wrote:
> On 21.07.2014 [12:53:33 -0700], Alexander Duyck wrote:
>> I do agree the description should probably be changed.  There shouldn't be
>> any panics involved, only a performance impact as it will be reallocating
>> always if it is on a node with no memory.
> 
> Yep, thanks for the review.
> 
>> My intention on this was to make certain that the memory used is from the
>> closest node possible.  As such I believe this change likely honours that.
> 
> Absolutely, just wanted to make it explicit that it's not a functional
> fix, just a performance fix (presuming this shows up at all on systems
> that have memoryless NUMA nodes).
> 
> I'd suggest an update to the comments, as well.
> 
> Thanks,
> Nish
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
