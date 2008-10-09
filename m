Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m997EdxY006751
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 18:14:39 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m997Fp1k232348
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 18:15:53 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m997FoUA008292
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 18:15:50 +1100
Message-ID: <48EDAFA0.1090808@linux.vnet.ibm.com>
Date: Thu, 09 Oct 2008 12:45:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: update patch set v7
References: <20081007190121.d96e58a6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081007190121.d96e58a6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi, Andrew. please allow me to test under -mm if ok.
> 
> This series is against the newest -mmotm(stamp-2008-10-02-16-17)
> and I think ready-to-go.
> 
> All comments are reflected.
> (and CONFIG_CGROUP_MEM_RES_CTLR=n case is fixed.)
> 
> Including following patches.
> 
> [1/6] ... account swap cache under lock
> [2/6] ... set page->mapping to be NULL before uncharge
> [3/6] ... avoid to account not-on-LRU pages.
> [4/6] ... optimize per cpu statistics on memcg.
> [5/6] ... make page_cgroup->flags atomic.
> [6/6] ... allocate page_cgroup at boot.
> 
> I did tests I can. But I think patch 6/6 needs wider testers.
> It has some dependency to configs/archs.
> 
> (*) the newest mmotm needs some patches to be driven.

Kamezawa-San,

Thanks for the patchset. I would like to see these tested in -mm as well. The
complaint that I am hearing from Fedora is that for them to enable the memory
controller, they would like to see the struct page overhead go (for 32 bit
systems that have 32 byte cachelines). This series helps us address that issue
and helps with performance.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
