Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8Q8a3NG030698
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 14:06:03 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8Q8a3i91753202
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 14:06:03 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8Q8a2bg026617
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 18:36:03 +1000
Message-ID: <48DC9EF2.10004@linux.vnet.ibm.com>
Date: Fri, 26 Sep 2008 14:06:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/12] memcg move charege() call to swapped-in page under
 lock_page()
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com> <20080925151457.0ad68293.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080925151457.0ad68293.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> While page-cache's charge/uncharge is done under page_lock(), swap-cache
> isn't. (anonymous page is charged when it's newly allocated.)
> 
> This patch moves do_swap_page()'s charge() call under lock. This helps
> us to avoid to charge already mapped one, unnecessary calls.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Seems reasonable to me

Just one quick comment though, as a result of this change, mark_page_accessed is
now called with PageLock held, I suspect you would want to move that call prior
to lock_page().



-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
