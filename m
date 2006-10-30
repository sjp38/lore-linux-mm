Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9UKtvv7001406
	for <linux-mm@kvack.org>; Mon, 30 Oct 2006 15:55:57 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9UKtui3353412
	for <linux-mm@kvack.org>; Mon, 30 Oct 2006 13:55:56 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9UKttwp000721
	for <linux-mm@kvack.org>; Mon, 30 Oct 2006 13:55:56 -0700
Subject: Re: [RFC] reduce hugetlb_instantiation_mutex usage
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20061027014740.GD11733@localhost.localdomain>
References: <000101c6f94c$8138c590$ff0da8c0@amr.corp.intel.com>
	 <20061026154451.bfe110c6.akpm@osdl.org>
	 <20061026233137.GA11733@localhost.localdomain>
	 <20061027014740.GD11733@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 30 Oct 2006 14:55:48 -0600
Message-Id: <1162241748.16427.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-10-27 at 11:47 +1000, 'David Gibson' wrote:
> libhugetlbfs: Testcase for MAP_PRIVATE OOM-liable race condition
> 
> The spurious OOM condition which can be caused by race conditions in
> the hugetlb fault handler can be triggered with both SHARED mappings
> (separate processes racing on the same address_space) and with PRIVATE
> mappings (different threads racing on the same vma).
> 
> At present the alloc-instantiate-race testcase only tests the SHARED
> mapping case.  Since at various times kernel fixes have been proposed
> which address only one or the other of the cases, extend the testcase
> to check the MAP_PRIVATE in addition to the MAP_SHARED case.
> 
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
Acked-by: Adam Litke <agl@us.ibm.com>  
Applied.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
