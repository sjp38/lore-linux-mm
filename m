Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6AGoNxf027339
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 12:50:23 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6AGoNjL094208
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 12:50:23 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6AGoNQ6031619
	for <linux-mm@kvack.org>; Thu, 10 Jul 2008 12:50:23 -0400
Date: Thu, 10 Jul 2008 09:50:19 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC PATCH 0/4] -mm-only hugetlb updates
Message-ID: <20080710165019.GB7151@us.ibm.com>
References: <20080708180348.GB14908@us.ibm.com> <20080710131141.GB6832@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080710131141.GB6832@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: mel@csn.ul.ie, agl@us.ibm.com, akpm@linux-foudation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.07.2008 [15:11:41 +0200], Nick Piggin wrote:
> On Tue, Jul 08, 2008 at 11:03:48AM -0700, Nishanth Aravamudan wrote:
> > As Nick requested, I've moved /sys/kernel/hugepages to
> > /sys/kernel/mm/hugepages. I put the creation of the /sys/kernel/mm
> > kobject in mm_init.c and that required removing the conditional
> > compilation of that file. This also necessitated a bit of Documentation
> > updates (and the addition of the /sys/kernel/mm ABI file). Finally, I
> > realized that kobject usage doesn't require CONFIG_SYSFS, so I was able
> > to remove one ifdef from hugetlb.c.
> > 
> > Andrew, I believe these patches, if acceptable, should be folded in
> > place, if possible, in the hugetlb series (that is, the sysfs location
> > should only ever have appeared to be /sys/kernel/mm/hugepages). The ease
> > with which that can occur I guess depends on where Mel's
> > DEBUG_MEMORY_INIT patches are in the series.
> > 
> > 1/4: mm: remove mm_init compilation dependency on CONFIG_DEBUG_MEMORY_INIT
> > 2/4: mm: create /sys/kernel/mm
> > 3/4: hugetlb: hang off of /sys/kernel/mm rather than /sys/kernel
> > 4/4: hugetlb: remove CONFIG_SYSFS dependency
> 
> Hi Nish,
> 
> Thanks for this. Yes I believe this is a much better layout, thank
> you.  To answer an earlier question you asked: yes, I believe a lot of
> existing kernel subsystems aren't really in appropriate location and
> there probably hasn't been a lot of thought into placement of some of
> them.
> 
> Imagine if every subsystem just goes into /sys/kernel/ directory, then
> it might look something like `ls /proc/sys/*` all in one directory :P

Fair enough :) I agree that it's worth considering these issues,
especially if we really intend to treat sysfs as ABI.

> I'm not sure what we can do about existing things (maybe they can get
> links and eventually put under one of those compat sysfs layout
> thingies). But definitely for new entries we should try to keep the
> namespace nice and modular.

That's probably the best we can do, you're right.

> Acked-by: Nick Piggin < npiggin@suse.de> for all patches.

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
