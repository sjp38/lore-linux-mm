Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id m8U8JETP080606
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 18:19:14 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8U85hYZ2515166
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 18:05:46 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8U85hao026890
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 18:05:43 +1000
Message-ID: <48E1DDD5.9040304@linux.vnet.ibm.com>
Date: Tue, 30 Sep 2008 13:35:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] memcg: account swap cache under lock
References: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com> <20080929192123.5ce60c24.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080929192123.5ce60c24.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> While page-cache's charge/uncharge is done under page_lock(), swap-cache
> isn't. (anonymous page is charged when it's newly allocated.)
> 
> This patch moves do_swap_page()'s charge() call under lock.
> I don't see any bad problem *now* but this fix will be good for future
> for avoiding unneccesary racy state.
> 
> 
> Changelog: (v5) -> (v6)
>  - mark_page_accessed() is moved before lock_page().
>  - fixed missing unlock_page()
> (no changes in previous version)

Looks good to me

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
