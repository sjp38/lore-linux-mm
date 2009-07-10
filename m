Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 767E86B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 01:11:52 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6A5XwSZ020322
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Jul 2009 14:33:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6886D45DE52
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:33:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CF4C45DE4D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:33:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 29FA3E1800D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:33:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CF7C11DB803C
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:33:57 +0900 (JST)
Date: Fri, 10 Jul 2009 14:32:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/5] Memory controller soft limit documentation
 (v8)
Message-Id: <20090710143216.7f5dc6b8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090709171449.8080.40970.sendpatchset@balbir-laptop>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
	<20090709171449.8080.40970.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 09 Jul 2009 22:44:49 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Feature: Add documentation for soft limits
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  Documentation/cgroups/memory.txt |   31 ++++++++++++++++++++++++++++++-
>  1 files changed, 30 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index ab0a021..b47815c 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -379,7 +379,36 @@ cgroups created below it.
>  
>  NOTE2: This feature can be enabled/disabled per subtree.
>  
> -7. TODO
> +7. Soft limits
> +
> +Soft limits allow for greater sharing of memory. The idea behind soft limits
> +is to allow control groups to use as much of the memory as needed, provided
> +
> +a. There is no memory contention
> +b. They do not exceed their hard limit
> +
> +When the system detects memory contention or low memory control groups
> +are pushed back to their soft limits. If the soft limit of each control
> +group is very high, they are pushed back as much as possible to make
> +sure that one control group does not starve the others of memory.
> +

It's better to write "this is best-effort service". We add hook only to kswapd.
And hou successfull this work depends on ZONE.

Thanks,
-Kame

> +7.1 Interface
> +
> +Soft limits can be setup by using the following commands (in this example we
> +assume a soft limit of 256 megabytes)
> +
> +# echo 256M > memory.soft_limit_in_bytes
> +
> +If we want to change this to 1G, we can at any time use
> +
> +# echo 1G > memory.soft_limit_in_bytes
> +
> +NOTE1: Soft limits take effect over a long period of time, since they involve
> +       reclaiming memory for balancing between memory cgroups
> +NOTE2: It is recommended to set the soft limit always below the hard limit,
> +       otherwise the hard limit will take precedence.
> +
> +8. TODO
>  
>  1. Add support for accounting huge pages (as a separate controller)
>  2. Make per-cgroup scanner reclaim not-shared pages first
> 
> -- 
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
