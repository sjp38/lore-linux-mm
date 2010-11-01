Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 680B48D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 16:01:35 -0400 (EDT)
Date: Mon, 1 Nov 2010 16:01:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] cgroup: prefer [kv]zalloc over [kv]malloc+memset in
 memory controller code.
Message-ID: <20101101200122.GH840@cmpxchg.org>
References: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 01, 2010 at 08:40:56PM +0100, Jesper Juhl wrote:
> Hi (please CC me on replies),
> 
> 
> Apologies to those who receive this multiple times. I screwed up the To: 
> field in my original mail :-(
> 
> 
> In mem_cgroup_alloc() we currently do either kmalloc() or vmalloc() then 
> followed by memset() to zero the memory. This can be more efficiently 
> achieved by using kzalloc() and vzalloc().
> 
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Looks good to me, but there is also the memset after kmalloc in
alloc_mem_cgroup_per_zone_info().  Can you switch that over as well in
this patch?  You can pass __GFP_ZERO to kmalloc_node() for zeroing.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
