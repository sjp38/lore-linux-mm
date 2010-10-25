Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F3C798D0002
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 19:58:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9PNwn3F015640
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 26 Oct 2010 08:58:49 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D180445DE79
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 08:58:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AB81B45DE4D
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 08:58:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F7DFEF8001
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 08:58:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A3161DB803A
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 08:58:45 +0900 (JST)
Date: Tue, 26 Oct 2010 08:53:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Fix typos in Documentation/sysctl/vm.txt
Message-Id: <20101026085320.73bb3f70.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101025161858.fb2e8353.rdunlap@xenotime.net>
References: <20101025161858.fb2e8353.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: linux-mm@kvack.org, akpm <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010 16:18:58 -0700
Randy Dunlap <rdunlap@xenotime.net> wrote:

> Hi Andrew,
> 
> Please merge this (unless someone sees problems with it).
> Looks good to me.
> 
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



> ---
> 
> Date: Mon, 18 Oct 2010 11:06:54 +0530
> From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
> To: linux-doc@vger.kernel.org
> Cc: rdunlap@xenotime.net, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
> Subject: [PATCH] Fix typos in Documentation/sysctl/vm.txt
> 
> 
>  Fix couple of typos in Documentation/sysctl/vm.txt under
> numa_zonelist_order.
> 
> Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
> --
>  Documentation/sysctl/vm.txt |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index b606c2c..4de9d5b 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -477,12 +477,12 @@ the DMA zone.
>  Type(A) is called as "Node" order. Type (B) is "Zone" order.
>  
>  "Node order" orders the zonelists by node, then by zone within each node.
> -Specify "[Nn]ode" for zone order
> +Specify "[Nn]ode" for node order.
>  
>  "Zone Order" orders the zonelists by zone type, then by node within each
> -zone.  Specify "[Zz]one"for zode order.
> +zone.  Specify "[Zz]one" for zone order.
>  
> -Specify "[Dd]efault" to request automatic configuration.  Autoconfiguration
> +Specify "[Dd]efault" to request automatic configuration. Autoconfiguration
>  will select "node" order in following case.
>  (1) if the DMA zone does not exist or
>  (2) if the DMA zone comprises greater than 50% of the available memory or
> 			
> --
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
