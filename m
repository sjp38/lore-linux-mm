Date: Tue, 12 Jun 2007 14:03:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
In-Reply-To: <20070612205738.309078596@sgi.com>
Message-ID: <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com>
References: <20070612204843.491072749@sgi.com>
 <20070612205738.309078596@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, clameter@sgi.com wrote:

> Index: linux-2.6.22-rc4-mm2/include/linux/nodemask.h
> ===================================================================
> --- linux-2.6.22-rc4-mm2.orig/include/linux/nodemask.h	2007-06-12 12:32:38.000000000 -0700
> +++ linux-2.6.22-rc4-mm2/include/linux/nodemask.h	2007-06-12 13:45:44.000000000 -0700
> @@ -64,12 +64,16 @@
>   *
>   * int node_online(node)		Is some node online?
>   * int node_possible(node)		Is some node possible?
> + * int node_memory(node)		Does a node have memory?
>   *

This name doesn't make sense; wouldn't node_has_memory() be better?

>   * int any_online_node(mask)		First online node in mask
>   *
>   * node_set_online(node)		set bit 'node' in node_online_map
>   * node_set_offline(node)		clear bit 'node' in node_online_map
>   *
> + * node_set_memory(node)		set bit 'node' in node_memory_map
> + * node_clear_memoryd(node)		clear bit 'node' in node_memory_map
> + *

Extra 'd' there in node_clear_memory().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
