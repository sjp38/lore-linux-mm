Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDMCK76004459
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 17:12:20 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDMCK2R450188
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 17:12:20 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDMCJLS016323
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 17:12:19 -0500
Subject: Re: [RFC][PATCH 1/2] hugetlb: introduce nr_overcommit_hugepages
	sysctl
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20071213074156.GA17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Dec 2007 16:14:41 -0600
Message-Id: <1197584081.16157.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-12-12 at 23:41 -0800, Nishanth Aravamudan wrote:
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

Acked-by: Adam Litke <agl@us.ibm.com>

> ---
> Andrew, since 2.6.24 would be the first release with the dynamic_pool
> sysctl, I think these might deserve consideration for inclusion, even so
> late in the cycle? It all depends on how close to an (important?)
> user-space visible change removing the sysctl might be in 2.6.25?
> Obviously pending comments, acks, nacks from Adam et al.

Also tested on powerpc.  I do think this is a more comprehensive
interface and would advocate a conversion to it in time for 2.6.24 if
possible. 

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
