Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m913oZst017751
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 09:20:35 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m913oYUs1347710
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 09:20:35 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m913oYCo002980
	for <linux-mm@kvack.org>; Wed, 1 Oct 2008 13:50:34 +1000
Message-ID: <48E2F389.40101@linux.vnet.ibm.com>
Date: Wed, 01 Oct 2008 09:20:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] memcg: set page->mapping NULL before uncharge
References: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com> <20080929192240.ddd59d7f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080929192240.ddd59d7f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch tries to make page->mapping to be NULL before
> mem_cgroup_uncharge_cache_page() is called.
> 
> "page->mapping == NULL" is a good check for "whether the page is still
> radix-tree or not".
> This patch also adds BUG_ON() to mem_cgroup_uncharge_cache_page();
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
