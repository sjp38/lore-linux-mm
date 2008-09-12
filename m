Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8CGM5SK026670
	for <linux-mm@kvack.org>; Fri, 12 Sep 2008 12:22:05 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8CGJHOU227654
	for <linux-mm@kvack.org>; Fri, 12 Sep 2008 12:19:17 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8CGJGHu022595
	for <linux-mm@kvack.org>; Fri, 12 Sep 2008 12:19:16 -0400
Subject: Re: [RFC] [PATCH 8/9] memcg: remove page_cgroup pointer from memmap
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48CA9500.5060309@linux.vnet.ibm.com>
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>
	 <48CA9500.5060309@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Fri, 12 Sep 2008 09:19:14 -0700
Message-Id: <1221236354.17910.18.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-09-12 at 09:12 -0700, Balbir Singh wrote:
> 3. Integrate with sparsemem (last resort for performance), Dave Hansen suggested
> adding a mem_section member and using that.

I also suggested using the sparsemem *structure* without necessarily
using it for pfn_to_page() lookups.  That'll take some rework to
separate out SPARSEMEM_FOR_MEMMAP vs. CONFIG_SPARSE_STRUCTURE_FUN, but
it should be able to be prototyped pretty fast.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
