Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2405E6B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 15:14:10 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n8EJEBJ5011264
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 12:14:12 -0700
Received: from pxi27 (pxi27.prod.google.com [10.243.27.27])
	by spaceape8.eur.corp.google.com with ESMTP id n8EJE897011218
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 12:14:09 -0700
Received: by pxi27 with SMTP id 27so2555896pxi.15
        for <linux-mm@kvack.org>; Mon, 14 Sep 2009 12:14:08 -0700 (PDT)
Date: Mon, 14 Sep 2009 12:14:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for mempolicy
 based management.
In-Reply-To: <20090914133329.GC11778@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0909141213150.14000@chino.kir.corp.google.com>
References: <20090908104409.GB28127@csn.ul.ie> <alpine.DEB.1.00.0909081241530.10542@chino.kir.corp.google.com> <20090908200451.GA6481@csn.ul.ie> <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com> <20090908214109.GB6481@csn.ul.ie>
 <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com> <20090909081631.GB24614@csn.ul.ie> <alpine.DEB.1.00.0909091335050.7764@chino.kir.corp.google.com> <20090910122641.GA31153@csn.ul.ie> <alpine.DEB.1.00.0909111507540.22083@chino.kir.corp.google.com>
 <20090914133329.GC11778@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Sep 2009, Mel Gorman wrote:

> > Hmm, I rewrote most of fake NUMA a couple years ago.  What problems are 
> > you having with it?
> > 
> 
> On PPC64, the parameters behave differently. I couldn't convince it to
> create more than one NUMA node. On x86-64, the NUMA nodes appeared to
> exist and would be visible on /proc/buddyinfo for example but the sysfs
> directories for the fake nodes were not created so nr_hugepages couldn't
> be examined on a per-node basis for example.
> 

I don't know anything about the ppc64 fake NUMA, but the sysfs node 
directories should certainly be created on x86_64.  I'll look into it 
because that's certainly a bug.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
