Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 986F46B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 00:26:53 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id o215NFi1030208
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 16:23:15 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o215LFED1478870
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 16:21:15 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o215QjjT028616
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 16:26:46 +1100
Date: Mon, 1 Mar 2010 10:56:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: fix typos in memcg_test.txt
Message-ID: <20100301052643.GH19665@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1267191557-23444-1-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1267191557-23444-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Kirill A. Shutemov <kirill@shutemov.name> [2010-02-26 15:39:16]:

> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>  Documentation/cgroups/memcg_test.txt |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
> index 4d32e0e..f7f68b2 100644
> --- a/Documentation/cgroups/memcg_test.txt
> +++ b/Documentation/cgroups/memcg_test.txt
> @@ -337,7 +337,7 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
>  	race and lock dependency with other cgroup subsystems.
> 
>  	example)
> -	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
> +	# mount -t cgroup none /cgroup -o cpuset,memory,cpu,devices
> 
>  	and do task move, mkdir, rmdir etc...under this.
> 
> @@ -348,7 +348,7 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
> 
>  	For example, test like following is good.
>  	(Shell-A)
> -	# mount -t cgroup none /cgroup -t memory
> +	# mount -t cgroup none /cgroup -o memory
>  	# mkdir /cgroup/test
>  	# echo 40M > /cgroup/test/memory.limit_in_bytes
>  	# echo 0 > /cgroup/test/tasks


Looks good,

Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
