Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PIErlA007066
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 14:14:54 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PIEqqF1072416
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 14:14:52 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PIEgsU007292
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 14:14:42 -0400
Date: Fri, 25 Apr 2008 11:14:30 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 08/18] hugetlb: multi hstate sysctls
Message-ID: <20080425181430.GG9680@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.487393000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015430.487393000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:10 +1000], npiggin@suse.de wrote:
> Expand the hugetlbfs sysctls to handle arrays for all hstates. This
> now allows the removal of global_hstate -- everything is now hstate
> aware.
> 
> - I didn't bother with hugetlb_shm_group and treat_as_movable,
> these are still single global.
> - Also improve error propagation for the sysctl handlers a bit

So, I may be mis-remembering, but the hugepages that are gigantic, that
is > MAX_ORDER, cannot be allocated or freed at run-time? If so, why do
we need to report them in the sysctl? It's a read-only value, right?
Similarly, for the sysfs interface thereto, can I just make them
read-only? I guess it would be an arbitrary difference from the other
files, but reflects reality?

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
