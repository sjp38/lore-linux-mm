Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8R6vEYZ021894
	for <linux-mm@kvack.org>; Sat, 27 Sep 2008 16:57:14 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8R6wOm7226586
	for <linux-mm@kvack.org>; Sat, 27 Sep 2008 16:58:26 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8R6wO5Z022549
	for <linux-mm@kvack.org>; Sat, 27 Sep 2008 16:58:24 +1000
Message-ID: <48DDD98D.3050303@linux.vnet.ibm.com>
Date: Sat, 27 Sep 2008 12:28:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 5/12] memcg make page_cgroup->flags atomic
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com> <20080925151734.5b24d494.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080925151734.5b24d494.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch makes page_cgroup->flags to be atomic_ops and define
> functions (and macros) to access it.
> 
> This patch itself makes memcg slow but this patch's final purpose is 
> to remove lock_page_cgroup() and allowing fast access to page_cgroup.
> (And total performance will increase after all patches applied.)
> 

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
provided we push in the lockless ones too :)

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
