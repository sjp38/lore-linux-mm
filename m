Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 437C38D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 13:24:12 -0500 (EST)
Date: Tue, 8 Mar 2011 12:24:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/4] slub: automatically reserve bytes at the end of
 slab
In-Reply-To: <4D6CA84B.9080606@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103081222380.25214@router.home>
References: <4D6CA84B.9080606@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On Tue, 1 Mar 2011, Lai Jiangshan wrote:

> So we add a field "reserved" to struct kmem_cache, when a slab
> is allocated, kmem_cache->reserved bytes are automatically reserved
> at the end of the slab for slab's metadata.

The reserved field should be exported via sysfs. Please add the code to
show it in /sys/kernel/slab/<name>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
