Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6EKiVaU015417
	for <linux-mm@kvack.org>; Sat, 14 Jul 2007 16:44:31 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6EKiUUq208634
	for <linux-mm@kvack.org>; Sat, 14 Jul 2007 14:44:30 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6EKiUul026199
	for <linux-mm@kvack.org>; Sat, 14 Jul 2007 14:44:30 -0600
Date: Sat, 14 Jul 2007 13:44:29 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 3/3] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20070714204429.GE17929@us.ibm.com>
References: <20070714203733.GA17929@us.ibm.com> <20070714204114.GB17929@us.ibm.com> <20070714204317.GD17929@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070714204317.GD17929@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.07.2007 [13:43:17 -0700], Nishanth Aravamudan wrote:
> hugetlb: add per-node nr_hugepages sysfs attribute
> 
> Allow specifying the number of hugepages to allocate on a particular
> node. Our current global sysctl will try its best to put hugepages
> equally on each node, but htat may not always be desired. This allows
> the admin to control the layout of hugepage allocation at a finer level
> (while not breaking the existing interface).  Add callbacks in the sysfs
> node registration and unregistration functions into hugetlb to add the
> nr_hugepages attribute, which is a no-op if !NUMA or !HUGETLB.

Eep, forgot to append the following:

Compile tested on x86, x86_64 and ppc64. Run tested on 4-node x86-64 (no
memoryless nodes), non-NUMA x86 and 4-node ppc64 (2 memoryless nodes).

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
