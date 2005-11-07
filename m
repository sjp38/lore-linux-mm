Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA7LmfT2026183
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:48:41 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA7LmfMf123048
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:48:41 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA7Lmeo3001606
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:48:41 -0500
Subject: Re: [RFC 2/2] Hugetlb COW
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1131399533.25133.104.camel@localhost.localdomain>
References: <1131397841.25133.90.camel@localhost.localdomain>
	 <1131399533.25133.104.camel@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 07 Nov 2005 15:47:55 -0600
Message-Id: <1131400076.25133.110.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, hugh@veritas.com, rohit.seth@intel.com, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Mon, 2005-11-07 at 15:38 -0600, Adam Litke wrote:
> [RFC] COW for hugepages
> (Patch originally from David Gibson <dwg@au1.ibm.com>)
> 
> This patch implements copy-on-write for hugepages, hence allowing
> MAP_PRIVATE mappings of hugetlbfs.
> 
> This is chiefly useful for cases where we want to use hugepages
> "automatically" - that is to map hugepages without the knowledge of
> the code in the final application (either via kernel hooks, or with
> LD_PRELOAD).  We can use various heuristics to determine when
> hugepages might be a good idea, but changing the semantics of
> anonymous memory from MAP_PRIVATE to MAP_SHARED without the app's
> knowledge is clearly wrong.

I forgot to mention in the original post that this patch is currently
broken on ppc64 due to a problem with update_mmu_cache().  The proper
fix is understood but backed up behind the powerpc merge activity.  

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
