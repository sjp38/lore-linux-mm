Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 797946B0055
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 00:39:57 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5F4aaJT010632
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 00:36:36 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5F4fBk0256196
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 00:41:11 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5F4cs5R015653
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 00:38:55 -0400
Date: Mon, 15 Jun 2009 10:11:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Low overhead patches for the memory cgroup controller (v5)
Message-ID: <20090615044109.GG23577@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090615043900.GF23577@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090615043900.GF23577@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2009-06-15 10:09:00]:

> 
> Feature: Remove the overhead associated with the root cgroup
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v5 -> v4
> 1. Moved back to v3 logic (Daisuke and Kamezawa like that better)
> 2. Incorporated changes from Daisuke (remove list_empty() checks)
> 3. Updated documentation to reflect that limits cannot be set on root
>    cgroup
> 
> Changelog v4 -> v3
> 1. Rebase to mmotm 9th june 2009
> 2. Remove PageCgroupRoot, we have account LRU flags to indicate that
>    we do only accounting and no reclaim.
> 3. pcg_default_flags has been used again, since PCGF_ROOT is gone,
>    we set PCGF_ACCT_LRU only in mem_cgroup_add_lru_list
> 4. More LRU functions are aware of PageCgroupAcctLRU
> 
> Changelog v3 -> v2
> 
> 1. Rebase to mmotm 2nd June 2009
> 2. Test with some of the test cases recommended by Daisuke-San
> 
> Changelog v2 -> v1
> 1. Rebase to latest mmotm
> 
> This patch changes the memory cgroup and removes the overhead associated
> with accounting all pages in the root cgroup. As a side-effect, we can
> no longer set a memory hard limit in the root cgroup.
> 
> A new flag to track whether the page has been accounted or not
> has been added as well. Flags are now set atomically for page_cgroup,
> pcg_default_flags is now obsolete and removed.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

CC'ing the correct Kamezawa-San

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
