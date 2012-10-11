Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 40EA96B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 16:32:01 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so1085243dad.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 13:32:00 -0700 (PDT)
Date: Thu, 11 Oct 2012 13:31:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2]suppress "Device nodeX does not have a release()
 function" warning
In-Reply-To: <50765896.4000300@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1210111326000.28062@chino.kir.corp.google.com>
References: <507656D1.5020703@jp.fujitsu.com> <50765896.4000300@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, liuj97@gmail.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On Thu, 11 Oct 2012, Yasuaki Ishimatsu wrote:

> When calling unregister_node(), the function shows following message at
> device_release().
> 
> "Device 'node2' does not have a release() function, it is broken and must
> be fixed."
> 
> The reason is node's device struct does not have a release() function.
> 
> So the patch registers node_device_release() to the device's release()
> function for suppressing the warning message. Additionally, the patch adds
> memset() to initialize a node struct into register_node(). Because the node
> struct is part of node_devices[] array and it cannot be freed by
> node_device_release(). So if system reuses the node struct, it has a garbage.
> 

Nice catch on reuse of the statically allocated node_devices[] for node 
hotplug.

> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>

Can register_node() be made static in drivers/base/node.c and its 
declaration removed from linux/node.h?

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
