Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8E3ED8D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 10:15:34 -0400 (EDT)
Date: Wed, 3 Nov 2010 22:15:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] cgroup: prefer [kv]zalloc over [kv]malloc+memset in
 memory controller code.
Message-ID: <20101103141529.GA7713@localhost>
References: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
 <20101101200122.GH840@cmpxchg.org>
 <alpine.LNX.2.00.1011012056250.12889@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1011012056250.12889@swampdragon.chaosbits.net>
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 01, 2010 at 08:59:13PM +0100, Jesper Juhl wrote:

> @@ -4169,13 +4169,11 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  	 */
>  	if (!node_state(node, N_NORMAL_MEMORY))
>  		tmp = -1;
> -	pn = kmalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
> +	pn = kmalloc_node(sizeof(*pn), GFP_KERNEL|__GFP_ZERO, tmp);

Use the simpler kzalloc_node()? It's introduced here:

        commit 979b0fea2d9ae5d57237a368d571cbc84655fba6
        Author: Jeff Layton <jlayton@redhat.com>
        Date:   Thu Jun 5 22:47:00 2008 -0700

            vm: add kzalloc_node() inline


Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
