Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PHnLoS032391
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 13:49:21 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PHnLbQ215292
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 13:49:21 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PHnAWW030988
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 13:49:11 -0400
Date: Fri, 25 Apr 2008 10:48:58 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 05/18] hugetlb: multiple hstates
Message-ID: <20080425174858.GD9680@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.162027000@nick.local0.net> <20080425173827.GC9680@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080425173827.GC9680@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 25.04.2008 [10:38:27 -0700], Nishanth Aravamudan wrote:
> On 23.04.2008 [11:53:07 +1000], npiggin@suse.de wrote:

<snip>

> > @@ -648,6 +709,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
> >  {
> >  	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> >  	max_huge_pages = set_max_huge_pages(max_huge_pages);
> > +	global_hstate.max_huge_pages = max_huge_pages;
> 
> So this implies the sysctl still only controls the singe state? Perhaps
> it would be better if this patch made set_max_huge_pages() take an
> hstate? Also, this seems to be the only place where max_huge_pages is
> still used, so can't you just do:
> 
> global_hstate.max_huge_pages = set_max_huge_pages(max_huge_pages); ?

Oops, sorry about the noise, max_huge_pages is the variable actually
modified by the sysctl.

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
