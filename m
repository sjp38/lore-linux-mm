Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D21956B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 15:58:24 -0400 (EDT)
Subject: Re: [PATCH 5/6] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0909101247020.5243@chino.kir.corp.google.com>
References: <20090909163127.12963.612.sendpatchset@localhost.localdomain>
	 <20090909163158.12963.49725.sendpatchset@localhost.localdomain>
	 <20090910123233.GB31153@csn.ul.ie>
	 <1252592774.6947.163.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.1.00.0909101247020.5243@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Thu, 10 Sep 2009 15:58:29 -0400
Message-Id: <1252612709.6947.191.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-10 at 12:50 -0700, David Rientjes wrote:
> On Thu, 10 Sep 2009, Lee Schermerhorn wrote:
> 
> > PATCH 5/7 - hugetlb:  promote NUMA_NO_NODE to generic constant
> > 
> > Against:  2.6.31-rc7-mmotm-090827-1651
> > 
> > Move definition of NUMA_NO_NODE from ia64 and x86_64 arch specific
> > headers to generic header 'linux/numa.h' for use in generic code.
> > NUMA_NO_NODE replaces bare '-1' where it's used in this series to
> > indicate "no node id specified".  Ultimately, it can be used
> > to replace the -1 elsewhere where it is used similarly.
> > 
> > Note that in arch/x86/include/asm/topology.h, NUMA_NO_NODE is
> > now only defined when CONFIG_NUMA is defined.  This seems to work
> > for current usage of NUMA_NO_NODE in x86_64 arch code, with or
> > without CONFIG_NUMA defined.
> > 
> > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Thought I recommended this in 
> http://marc.info/?l=linux-mm&m=125201173730752

Yeah, but that was before the long weekend... 

> 
> You could now convert NID_INVAL to NUMA_NO_NODE and remove the duplicate 
> constant as I earlier suggested to cleanup the acpi code.

Could now be done, as you say...

Meanwhile, I'm working on a bit more "clean up".




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
