Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4NKOkCR007884
	for <linux-mm@kvack.org>; Fri, 23 May 2008 16:24:46 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4NKSMsD099058
	for <linux-mm@kvack.org>; Fri, 23 May 2008 14:28:22 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4NKSA2i013233
	for <linux-mm@kvack.org>; Fri, 23 May 2008 14:28:21 -0600
Date: Fri, 23 May 2008 13:27:48 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 08/18] hugetlb: multi hstate sysctls
Message-ID: <20080523202748.GA23924@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.487393000@nick.local0.net> <20080425181430.GG9680@us.ibm.com> <20080523052546.GH13071@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523052546.GH13071@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.05.2008 [07:25:46 +0200], Nick Piggin wrote:
> On Fri, Apr 25, 2008 at 11:14:30AM -0700, Nishanth Aravamudan wrote:
> > On 23.04.2008 [11:53:10 +1000], npiggin@suse.de wrote:
> > > Expand the hugetlbfs sysctls to handle arrays for all hstates. This
> > > now allows the removal of global_hstate -- everything is now hstate
> > > aware.
> > > 
> > > - I didn't bother with hugetlb_shm_group and treat_as_movable,
> > > these are still single global.
> > > - Also improve error propagation for the sysctl handlers a bit
> > 
> > So, I may be mis-remembering, but the hugepages that are gigantic, that
> > is > MAX_ORDER, cannot be allocated or freed at run-time? If so, why do
> 
> Right.
> 
> > we need to report them in the sysctl? It's a read-only value, right?
> 
> I guess for reporting and compatibility.

That's fair. I was more referring to the fact that the relevant
information would be in /proc/meminfo.

> > Similarly, for the sysfs interface thereto, can I just make them
> > read-only? I guess it would be an arbitrary difference from the other
> > files, but reflects reality?
> 
> For the sysfs interface, I think that would be a fine idea to make
> them readonly if they cannot be changed.

Yeah -- will need to think of a good way for the sysfs hstate API to be
told the given hstate is unchangeable. So for now, they may be writable,
but without any effect.

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
