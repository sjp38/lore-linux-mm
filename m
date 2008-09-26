Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8Q8K31Z024737
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 18:20:03 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8Q8JlTl053052
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 18:20:38 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8Q8J86D022085
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 18:19:08 +1000
Message-ID: <48DC9AF2.1050101@linux.vnet.ibm.com>
Date: Fri, 26 Sep 2008 13:48:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/12] memcg updates v5
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi, I updated the stack and reflected comments.
> Against the latest mmotm. (rc7-mm1)
> 
> Major changes from previous one is 
>   - page_cgroup allocation/lookup manner is changed.
>     all FLATMEM/DISCONTIGMEM/SPARSEMEM and MEMORY_HOTPLUG is supported.
>   - force_empty is totally rewritten. and a problem that "force_empty takes long time"
>     in previous version is fixed (I think...)
>   - reordered patches.
>      - first half are easy ones.
>      - second half are big ones.
> 
> I'm still testing with full debug option. No problem found yet.
> (I'm afraid of race condition which have not been caught yet.)
> 
> [1/12]  avoid accounting special mappings not on LRU. (fix)
> [2/12]  move charege() call to swapped-in page under lock_page() (clean up)
> [3/12]  make root cgroup to be unlimited. (change semantics.)
> [4/12]  make page->mapping NULL before calling uncharge (clean up)
> [5/12]  make page->flags to use atomic ops. (changes in infrastructure)
> [6/12]  optimize stat. (clean up)
> [7/12]  add support function for moving account. (new function)
> [8/12]  rewrite force_empty to use move_account. (change semantics.)
> [9/12]  allocate all page_cgroup at boot. (changes in infrastructure)
> [10/12] free page_cgroup from LRU in lazy way (optimize)
> [11/12] add page_cgroup to LRU in lazy way (optimize)
> [12/12] fix race at charging swap  (fix by new logic.)
> 
> *Any* comment is welcome.

Kame,

I'm beginning to review test the patches now. It would be really nice to split
the development patches from the maintenance ones. I think the full patchset has
too many things and is confusing to look at.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
