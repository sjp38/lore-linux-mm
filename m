Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAC54EWJ013045
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 00:04:14 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAC54EMd141610
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 00:04:14 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAC54DFM016083
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 00:04:14 -0500
Message-ID: <4737DEC2.2080803@linux.vnet.ibm.com>
Date: Mon, 12 Nov 2007 10:34:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/6 mm] swapoff: scan ptes preemptibly
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Provided that CONFIG_HIGHPTE is not set, unuse_pte_range can reduce latency
> in swapoff by scanning the page table preemptibly: so long as unuse_pte is
> careful to recheck that entry under pte lock.
> 
> (To tell the truth, this patch was not inspired by any cries for lower
> latency here: rather, this restructuring permits a future memory controller
> patch to allocate with GFP_KERNEL in unuse_pte, where before it could not.
> But it would be wrong to tuck this change away inside a memcgroup patch.)
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com> and earlier
Tested-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
