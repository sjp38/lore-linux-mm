Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6E1C06B0093
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 00:44:14 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2P59Lbi026140
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Mar 2009 14:09:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 84B2E45DD77
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:09:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F1D045DD79
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:09:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D5591DB801B
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:09:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE9EDE1800A
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:09:18 +0900 (JST)
Date: Wed, 25 Mar 2009 14:07:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-Id: <20090325140752.01609cf5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090319165735.27274.96091.sendpatchset@localhost.localdomain>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165735.27274.96091.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009 22:27:35 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> @@ -938,16 +1031,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		int ret;
>  		bool noswap = false;
>  
In logical, plz add
  soft_fail_res = NULL, here.


> -		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
> +		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
> +						&soft_fail_res);

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
