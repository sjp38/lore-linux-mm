Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0DB506B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 23:29:38 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1K4TaKD006347
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 20 Feb 2010 13:29:36 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2569E45DE4D
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:29:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 03FF045DE50
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:29:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D66E01DB8041
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:29:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C03F1DB8038
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:29:35 +0900 (JST)
Date: Sat, 20 Feb 2010 13:26:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 4/4] memcg: Update memcg_test.txt to describe
 memory thresholds
Message-Id: <20100220132604.0609db47.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <fe8b000f9eb2cd469f21d92dcd87a6b3feb5efd7.1266618391.git.kirill@shutemov.name>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
	<a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
	<6afbe14e8bb2480d88377c14cb15d96edd2d18f6.1266618391.git.kirill@shutemov.name>
	<fe8b000f9eb2cd469f21d92dcd87a6b3feb5efd7.1266618391.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Feb 2010 00:28:19 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  Documentation/cgroups/memcg_test.txt |   21 +++++++++++++++++++++
>  1 files changed, 21 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
> index e011488..4d32e0e 100644
> --- a/Documentation/cgroups/memcg_test.txt
> +++ b/Documentation/cgroups/memcg_test.txt
> @@ -396,3 +396,24 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
>  	memory.stat of both A and B.
>  	See 8.2 of Documentation/cgroups/memory.txt to see what value should be
>  	written to move_charge_at_immigrate.
> +
> + 9.10 Memory thresholds
> +	Memory controler implements memory thresholds using cgroups notification
> +	API. You can use Documentation/cgroups/cgroup_event_listener.c to test
> +	it.
> +
> +	(Shell-A) Create cgroup and run event listener
> +	# mkdir /cgroup/A
> +	# ./cgroup_event_listener /cgroup/A/memory.usage_in_bytes 5M
> +
> +	(Shell-B) Add task to cgroup and try to allocate and free memory
> +	# echo $$ >/cgroup/A/tasks
> +	# a="$(dd if=/dev/zero bs=1M count=10)"
> +	# a=
> +
> +	You will see message from cgroup_event_listener every time you cross
> +	the thresholds.
> +
> +	Use /cgroup/A/memory.memsw.usage_in_bytes to test memsw thresholds.
> +
> +	It's good idea to test root cgroup as well.
> -- 
> 1.6.6.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
