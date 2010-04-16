Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 804196B021C
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 20:54:44 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G0sfZf009293
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Apr 2010 09:54:41 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49D6845DE52
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 09:54:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F0A045DE50
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 09:54:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF62FE08009
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 09:54:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E5EDE08008
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 09:54:40 +0900 (JST)
Date: Fri, 16 Apr 2010 09:50:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 8/8] numa:  update Documentation/vm/numa, add memoryless
 node info
Message-Id: <20100416095045.46ab6552.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100415173042.8801.17049.sendpatchset@localhost.localdomain>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
	<20100415173042.8801.17049.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Apr 2010 13:30:42 -0400
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> Against:  2.6.34-rc3-mmotm-100405-1609
> 
> Kamezawa Hiroyuki requested documentation for the numa_mem_id()
> and slab related changes.  He suggested Documentation/vm/numa for
> this documentation.  Looking at this file, it seems to me to be
> hopelessly out of date relative to current Linux NUMA support.
> At the risk of going down a rathole, I have made an attempt to
> rewrite the doc at a slightly higher level [I think] and provide
> pointers to other in-tree documents and out-of-tree man pages that
> cover the details.
> 
> Let the games begin.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 

Thank you, seems very nice and covers almost all range we have to explain
to new comers. 
My eye can't check details enough but...;)

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I think this patch itself is very good.

Being more greedy...

Hmm, from user's view, I feel quick guide of

/sys/devices/system/node/
and 
 /sys/devices/system/node/node0/numastat 
can be added somewhere. (Documentation/numastat.txt is not under /vm :( )

And one more important? thing.

[kamezawa@firextal Documentation]$ cat /sys/bus/pci/devices/0000\:00\:01.0/numa_node
-1

PCI device (and other??) has numa_node_id in it, if it has locality information.
I hear some guy had to be aware locality of NIC to do high-throuput network
transaction. Then, "how to get device's locality via sysfs" is worth to be
written.

And mentioning what "nid = -1" means may help new comer.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
