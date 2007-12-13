Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDGiuko029986
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 11:44:56 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDGiuvo494126
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 11:44:56 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDGitmx025895
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 11:44:55 -0500
Date: Thu, 13 Dec 2007 08:44:53 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 1/2] hugetlb: introduce nr_overcommit_hugepages
	sysctl
Message-ID: <20071213164453.GC17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com> <1197562629.21438.20.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1197562629.21438.20.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: agl@us.ibm.com, wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.12.2007 [08:17:08 -0800], Dave Hansen wrote:
> On Wed, 2007-12-12 at 23:41 -0800, Nishanth Aravamudan wrote:
> > While examining the code to support /proc/sys/vm/hugetlb_dynamic_pool, I
> > became convinced that having a boolean sysctl was insufficient:
> > 
> > 1) To support per-node control of hugepages, I have previously submitted
> > patches to add a sysfs attribute related to nr_hugepages. However, with
> > a boolean global value and per-mount quota enforcement constraining the
> > dynamic pool, adding corresponding control of the dynamic pool on a
> > per-node basis seems inconsistent to me.
> 
> Documentation/sysctl, please :)

Err, yes, will need to updated that. I note that the old sysctl is not
there...nor is nr_hugepages, for that matter. So maybe I'll just add a
3rd patch to fix the Documentation? I really just wanted to get the
patches out there as soon as I got them tested...

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
