Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2F2726B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 03:53:39 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2R83O1h024292
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Mar 2009 17:03:25 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A824245DD7D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 17:03:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 86E8D45DD78
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 17:03:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 703ED1DB803B
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 17:03:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF4FBE08006
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 17:03:20 +0900 (JST)
Date: Fri, 27 Mar 2009 17:01:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/8] soft limit framework in memcg.
Message-Id: <20090327170154.99602776.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090327140346.8d27b69a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090327140346.8d27b69a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Mar 2009 14:03:46 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Add minimal modification for soft limit to res_counter_charge() and memcontol.c
> Based on Balbir Singh <balbir@linux.vnet.ibm.com> 's work but most of
> features are removed. (dropped or moved to later patch.)
> 
> This is for building a frame to implement soft limit handler in memcg.
>  - Checks soft limit status at every charge.
>  - Adds mem_cgroup_soft_limit_check() as a function to detect we need
>    check now or not.
>  - mem_cgroup_update_soft_limit() is a function for updates internal status
>    of soft limit controller of memcg.
>  - This has no hooks in uncharge path. (see later patch.)
Note:
Why I don't insert hook to uncharge() is because uncharge() is called under
spin locks (and my softlimit update() routine is heavy).
But need some hook anyway. I'll take care of this in other patch if I got new idea.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
