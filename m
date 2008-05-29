Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4T5WI6o001597
	for <linux-mm@kvack.org>; Thu, 29 May 2008 01:32:18 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4T5a4ck064418
	for <linux-mm@kvack.org>; Wed, 28 May 2008 23:36:04 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4T5a4Xs024058
	for <linux-mm@kvack.org>; Wed, 28 May 2008 23:36:04 -0600
Date: Wed, 28 May 2008 22:36:02 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 07/23] hugetlb: multi hstate sysctls
Message-ID: <20080529053602.GA1423@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.841211000@nick.local0.net> <20080529045919.GA8963@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080529045919.GA8963@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 28.05.2008 [21:59:19 -0700], Nishanth Aravamudan wrote:
> On 26.05.2008 [00:23:24 +1000], npiggin@suse.de wrote:
> > Expand the hugetlbfs sysctls to handle arrays for all hstates. This
> > now allows the removal of global_hstate -- everything is now hstate
> > aware.
> > 
> > - I didn't bother with hugetlb_shm_group and treat_as_movable,
> > these are still single global.
> > - Also improve error propagation for the sysctl handlers a bit
> > 
> > Signed-off-by: Andi Kleen <ak@suse.de>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> <snip>
> 
> >  int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
> >  			struct file *file, void __user *buffer,
> >  			size_t *length, loff_t *ppos)
> >  {
> > + 	table->maxlen = max_hstate * sizeof(int);
> 
> Are you sure this is correct? I was just testing my sysfs patch (and the
> removal of the multi-valued proc files) and noticed that
> /proc/sys/vm/hugepages_treat_as_movable was multi-valued (3 values,
> corresponding to the three page sizes on this machine), and the last
> value was garbage. And, in any case, this change seems to conflict with
> the changelog?

Confirmed that with just your patches, I see

# cat /proc/sys/vm/hugepages_treat_as_movable 
0	0	-1073741824

which is hopefully bogus :) So I'd say this is a bad part of this particular
change?

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
