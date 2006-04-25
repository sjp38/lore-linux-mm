Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3P8VogY142006
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 08:31:50 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3P8WtKp122112
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 10:32:55 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3P8VokK020983
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 10:31:50 +0200
Subject: Re: Page host virtual assist patches.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <444DCD87.2030307@yahoo.com.au>
References: <20060424123412.GA15817@skybase>
	 <20060424180138.52e54e5c.akpm@osdl.org>  <444DCD87.2030307@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 25 Apr 2006 10:31:54 +0200
Message-Id: <1145953914.5282.21.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-25 at 17:19 +1000, Nick Piggin wrote:
> Andrew Morton wrote:
> > Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> > 
> >> The basic idea of host virtual assist (hva) is to give a host system
> >> which virtualizes the memory of its guest systems on a per page basis
> >> usage information for the guest pages. The host can then use this
> >> information to optimize the management of guest pages, in particular
> >> the paging. This optimizations can be used for unused (free) guest
> >> pages, for clean page cache pages, and for clean swap cache pages.
> > 
> > 
> > This is pretty significant stuff.  It sounds like something which needs to
> > be worked through with other possible users - UML, Xen, vware, etc.
> > 
> > How come the reclaim has to be done in the host?  I'd have thought that a
> > much simpler approach would be to perform a host->guest upcall saying
> > either "try to free up this many pages" or "free this page" or "free this
> > vector of pages"?
> 
> Definitely. The current patches seem like just an extra layer to do
> everything we can already -- reclaim unused pages and populate them
> again when they get touched.
> 
> And complex they are. Having the core VM have to know about all this
> weird stuff seems... not good.

The point here is WHO does the reclaim. Sure we can do the reclaim in
the guest but it is the host that has the memory pressure. To call into
the guest is not a good idea, if you have an idle guest you generally
increase the memory pressure because some of the guests pages might have
been swapped which are needed if the guest has to do the reclaim. 

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
