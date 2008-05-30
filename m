Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4U7hibb009336
	for <linux-mm@kvack.org>; Fri, 30 May 2008 03:43:44 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4U7hie9137110
	for <linux-mm@kvack.org>; Fri, 30 May 2008 03:43:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4U7hhKg016502
	for <linux-mm@kvack.org>; Fri, 30 May 2008 03:43:44 -0400
Date: Fri, 30 May 2008 00:43:42 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/2] hugetlb: remove multi-valued proc files.
Message-ID: <20080530074342.GD5021@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.841211000@nick.local0.net> <20080529063915.GC11357@us.ibm.com> <20080529064242.GD11357@us.ibm.com> <20080530035123.GB25792@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080530035123.GB25792@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On 30.05.2008 [05:51:23 +0200], Nick Piggin wrote:
> On Wed, May 28, 2008 at 11:42:42PM -0700, Nishanth Aravamudan wrote:
> > Now that we present the same information in a cleaner way in sysfs, we
> > can remove the duplicate information and interfaces from procfs (and
> > consider them to be the legacy interface). The proc interface only
> > controls the default hugepage size, which is either
> > 
> > a) the first one specified via hugepagesz= on the kernel command-line, if any
> > b) the legacy huge page size, otherwise
> > 
> > All other hugepage size pool manipulations can occur through sysfs.
> > 
> > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > 
> > ---
> > Note, this does end up making the manipulation and validation of
> > multiple hstates impossible without sysfs enabled and mounted. As such,
> 
> I don't think that's such a problem. The overlap between users with
> no sysfs and those that use multiple hugepages won't be large. And
> if any exist, they can specify at boot or come up with their own
> customer solution.

Yeah, like I said, I imagine the only ones that might care are sh folks
and even there, I don't know their MMU well enough to know how big of a
deal it is.

> > I'm not sure if this is the right approach and perhaps we should be
> > leaving the multi-valued proc files in place (but not as the preferred
> > interface). Or we could present the values in procfs only if SYSFS is
> > not enabled in the kernel? I imagine (but am not 100% sure) that the
> > only current architecture where this might be important is SUPERH?
> 
> I wouldn't worry too much. I think /proc/sys/vm/nr_hugepages etc
> is better as one (the compat) value after we now have the sysfs
> stuff. However /proc/meminfo is a little more tricky. Of course
> the information does exist in sysfs too, but meminfo is also for
> user reporting, so maybe it will be better to leave it multi
> column?

Yeah, I suppose it could be either way. I definitely agree the writable
interfaces are cleaner single-valued.

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
