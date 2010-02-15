Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6B7EE6B007B
	for <linux-mm@kvack.org>; Sun, 14 Feb 2010 20:25:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1F1PAi1009552
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Feb 2010 10:25:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EB6545DE6B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 10:25:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 24FED45DE61
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 10:25:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D5E81DB803E
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 10:25:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 062AA8F8007
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 10:25:07 +0900 (JST)
Date: Mon, 15 Feb 2010 10:21:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm] memcg: update memcg_test.txt
Message-Id: <20100215102144.a48aced2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100215094913.57922cab.nishimura@mxp.nes.nec.co.jp>
References: <20100203110048.6c8f66c4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100215094913.57922cab.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010 09:49:13 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Update memcg_test.txt to describe how to test the move-charge feature.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thank you !!
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  Documentation/cgroups/memcg_test.txt |   22 ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
> index 72db89e..e011488 100644
> --- a/Documentation/cgroups/memcg_test.txt
> +++ b/Documentation/cgroups/memcg_test.txt
> @@ -1,6 +1,6 @@
>  Memory Resource Controller(Memcg)  Implementation Memo.
> -Last Updated: 2009/1/20
> -Base Kernel Version: based on 2.6.29-rc2.
> +Last Updated: 2010/2
> +Base Kernel Version: based on 2.6.33-rc7-mm(candidate for 34).
>  
>  Because VM is getting complex (one of reasons is memcg...), memcg's behavior
>  is complex. This is a document for memcg's internal behavior.
> @@ -378,3 +378,21 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
>  	#echo 50M > memory.limit_in_bytes
>  	#echo 50M > memory.memsw.limit_in_bytes
>  	run 51M of malloc
> +
> + 9.9 Move charges at task migration
> +	Charges associated with a task can be moved along with task migration.
> +
> +	(Shell-A)
> +	#mkdir /cgroup/A
> +	#echo $$ >/cgroup/A/tasks
> +	run some programs which uses some amount of memory in /cgroup/A.
> +
> +	(Shell-B)
> +	#mkdir /cgroup/B
> +	#echo 1 >/cgroup/B/memory.move_charge_at_immigrate
> +	#echo "pid of the program running in group A" >/cgroup/B/tasks
> +
> +	You can see charges have been moved by reading *.usage_in_bytes or
> +	memory.stat of both A and B.
> +	See 8.2 of Documentation/cgroups/memory.txt to see what value should be
> +	written to move_charge_at_immigrate.
> -- 
> 1.6.4
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
