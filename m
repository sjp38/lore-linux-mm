Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDMCJpC010070
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 17:12:19 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDMCJb8140872
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 17:12:19 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDMCIGx004064
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 17:12:18 -0500
Subject: Re: [RFC][PATCH 2/2] Revert "hugetlb: Add hugetlb_dynamic_pool
	sysctl"
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20071213074259.GB17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com>
	 <20071213074259.GB17526@us.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Dec 2007 16:14:38 -0600
Message-Id: <1197584078.16157.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-12-12 at 23:42 -0800, Nishanth Aravamudan wrote:
> Revert "hugetlb: Add hugetlb_dynamic_pool sysctl"
> 
> This reverts commit 54f9f80d6543fb7b157d3b11e2e7911dc1379790.
> 
> Given the new sysctl nr_overcommit_hugepages, the boolean dynamic pool
> sysctl is not needed, as its semantics can be expressed by 0 in the
> overcommit sysctl (no dynamic pool) and non-0 in the overcommit sysctl
> (pool enabled).
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
