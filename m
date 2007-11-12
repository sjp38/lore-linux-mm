Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAC590Bl024247
	for <linux-mm@kvack.org>; Mon, 12 Nov 2007 00:09:00 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lAC5903e122136
	for <linux-mm@kvack.org>; Sun, 11 Nov 2007 22:09:00 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAC590st015173
	for <linux-mm@kvack.org>; Sun, 11 Nov 2007 22:09:00 -0700
Message-ID: <4737DFE2.9050704@linux.vnet.ibm.com>
Date: Mon, 12 Nov 2007 10:38:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 4/6 mm] memcgroup: reinstate swapoff mod
References: <Pine.LNX.4.64.0711090700530.21638@blonde.wat.veritas.com> <Pine.LNX.4.64.0711090711190.21663@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0711090711190.21663@blonde.wat.veritas.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> This patch reinstates the "swapoff: scan ptes preemptibly" mod we started
> with: in due course it should be rendered down into the earlier patches,
> leaving us with a more straightforward mem_cgroup_charge mod to unuse_pte,
> allocating with GFP_KERNEL while holding no spinlock and no atomic kmap.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

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
