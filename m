Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2616B005A
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 03:11:09 -0400 (EDT)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id n5O7BMLE011384
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 08:11:22 +0100
Received: from wa-out-1112.google.com (wagm34.prod.google.com [10.114.214.34])
	by spaceape7.eur.corp.google.com with ESMTP id n5O7BJFw018808
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 00:11:20 -0700
Received: by wa-out-1112.google.com with SMTP id m34so113679wag.3
        for <linux-mm@kvack.org>; Wed, 24 Jun 2009 00:11:19 -0700 (PDT)
Date: Wed, 24 Jun 2009 00:11:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/5] Huge Pages Nodes Allowed
In-Reply-To: <alpine.DEB.2.00.0906181154340.10979@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.0906240006540.16528@chino.kir.corp.google.com>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook> <20090617130216.GF28529@csn.ul.ie> <1245258954.6235.58.camel@lts-notebook> <alpine.DEB.2.00.0906181154340.10979@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Ranjit Manomohan <ranjitm@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jun 2009, David Rientjes wrote:

> Manipulating hugepages via a nodemask seems less ideal than, as you 
> mentioned, per-node hugepage controls, probably via 
> /sys/kernel/system/node/node*/nr_hugepages.  This type of interface 
> provides all the functionality that this patchset does, including hugepage 
> allocation and freeing, but with more power to explicitly allocate and 
> free on targeted nodes.  /proc/sys/vm/nr_hugepages would remain to 
> round-robin the allocation (and freeing, with your patch 1/5 which I 
> ack'd).
> 
> Such an interface would also automatically deal with all memory 
> hotplug/remove issues without storing or keeping a nodemask updated.
> 

Expanding this proposal out a little bit, we'd want all the power of the 
/sys/kernel/mm/hugepages tunables for each node.  The best way of doing 
that is probably to keep the current /sys/kernel/mm/hugepages directory as 
is (already published Documentation/ABI/testing/sysfs-kernel-mm-hugepages) 
for the system-wide hugepage state and then add individual 
`hugepages-<size>kB' directories to each /sys/devices/system/node/node* to 
target allocations and freeing for the per-node hugepage state.  
Otherwise, we lack node targeted support for multiple hugepagesz= users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
