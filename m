Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC856B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 06:21:17 -0400 (EDT)
Date: Wed, 16 Sep 2009 11:21:24 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for
	mempolicy based management.
Message-ID: <20090916102124.GC1993@csn.ul.ie>
References: <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com> <20090908214109.GB6481@csn.ul.ie> <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com> <20090909081631.GB24614@csn.ul.ie> <alpine.DEB.1.00.0909091335050.7764@chino.kir.corp.google.com> <20090910122641.GA31153@csn.ul.ie> <alpine.DEB.1.00.0909111507540.22083@chino.kir.corp.google.com> <20090914133329.GC11778@csn.ul.ie> <alpine.DEB.1.00.0909141213150.14000@chino.kir.corp.google.com> <alpine.DEB.1.00.0909141421540.22563@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0909141421540.22563@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 14, 2009 at 02:28:27PM -0700, David Rientjes wrote:
> On Mon, 14 Sep 2009, David Rientjes wrote:
> 
> > > On PPC64, the parameters behave differently. I couldn't convince it to
> > > create more than one NUMA node. On x86-64, the NUMA nodes appeared to
> > > exist and would be visible on /proc/buddyinfo for example but the sysfs
> > > directories for the fake nodes were not created so nr_hugepages couldn't
> > > be examined on a per-node basis for example.
> > > 
> > 
> > I don't know anything about the ppc64 fake NUMA, but the sysfs node 
> > directories should certainly be created on x86_64.  I'll look into it 
> > because that's certainly a bug.  Thanks.
> > 
> 
> This works on my machine just fine.
> 
> For example, with numa=fake=8:
> 
> 	$ ls /sys/devices/system/node
> 	has_cpu  has_normal_memory  node0  node1  node2  node3  node4  
> node5  node6  node7  online  possible
> 
> 	$ ls /sys/devices/system/node/node3
> 	cpu4  cpu5  cpu6  cpu7  cpulist  cpumap  distance  meminfo  
> numastat  scan_unevictable_pages
> 
> I don't see how this could differ if bootmem is setting up the nodes 
> correctly, which dmesg | grep "^Bootmem setup node" would reveal.
> 
> The defconfig disables CONFIG_NUMA_EMU now, though, so perhaps it got 
> turned off by accident in your kernel?
> 

I don't think so because my recollection is that the nodes existed
according to meminfo and buddyinfo but not the sysfs files.
Unfortunately I can't remember the reproduction scenario. I thought it
was on mmotm-2009-08-27-16-51 on a particularly machine but when I went
to reproduce, it didn't even boot so somewhere along the line I busted
things.

> Let me know if there's any abnormalities with your particular setup.
> 

Will try reproducing on more recent mmotm and see if anything odd falls
out.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
