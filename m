Date: Thu, 10 Jul 2008 15:11:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH 0/4] -mm-only hugetlb updates
Message-ID: <20080710131141.GB6832@wotan.suse.de>
References: <20080708180348.GB14908@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080708180348.GB14908@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: mel@csn.ul.ie, agl@us.ibm.com, akpm@linux-foudation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 08, 2008 at 11:03:48AM -0700, Nishanth Aravamudan wrote:
> As Nick requested, I've moved /sys/kernel/hugepages to
> /sys/kernel/mm/hugepages. I put the creation of the /sys/kernel/mm
> kobject in mm_init.c and that required removing the conditional
> compilation of that file. This also necessitated a bit of Documentation
> updates (and the addition of the /sys/kernel/mm ABI file). Finally, I
> realized that kobject usage doesn't require CONFIG_SYSFS, so I was able
> to remove one ifdef from hugetlb.c.
> 
> Andrew, I believe these patches, if acceptable, should be folded in
> place, if possible, in the hugetlb series (that is, the sysfs location
> should only ever have appeared to be /sys/kernel/mm/hugepages). The ease
> with which that can occur I guess depends on where Mel's
> DEBUG_MEMORY_INIT patches are in the series.
> 
> 1/4: mm: remove mm_init compilation dependency on CONFIG_DEBUG_MEMORY_INIT
> 2/4: mm: create /sys/kernel/mm
> 3/4: hugetlb: hang off of /sys/kernel/mm rather than /sys/kernel
> 4/4: hugetlb: remove CONFIG_SYSFS dependency

Hi Nish,

Thanks for this. Yes I believe this is a much better layout, thank you.
To answer an earlier question you asked: yes, I believe a lot of existing
kernel subsystems aren't really in appropriate location and there probably
hasn't been a lot of thought into placement of some of them.

Imagine if every subsystem just goes into /sys/kernel/ directory, then it
might look something like `ls /proc/sys/*` all in one directory :P

I'm not sure what we can do about existing things (maybe they can get links
and eventually put under one of those compat sysfs layout thingies). But
definitely for new entries we should try to keep the namespace nice and
modular.

Acked-by: Nick Piggin < npiggin@suse.de> for all patches.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
