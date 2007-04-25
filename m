Date: Wed, 25 Apr 2007 12:17:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] syctl for selecting global zonelist[] order
In-Reply-To: <20070425121946.9eb27a79.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0704251211070.17886@schroedinger.engr.sgi.com>
References: <20070425121946.9eb27a79.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Apr 2007, KAMEZAWA Hiroyuki wrote:

> Make zonelist policy selectable from sysctl.
> 
> Assume 2 node NUMA, only node(0) has ZONE_DMA (ZONE_DMA32).
> 
> In this case, default (node0's) zonelist order is
> 
> Node(0)'s NORMAL -> Node(0)'s DMA -> Node(1)"s NORMAL.
> 
> This means Node(0)'s DMA is used before Node(1)'s NORMAL.

So a IA64 platform with i386 sicknesses? And pretty bad case of it since I 
assume that the memory sizes per node are equal. Your solution of taking 
4G off node 0 and then going to node 1 first must hurt some 
processes running on node 0. But there is no easy solution since 
the hardware is badly screwed up with 32 bit I/O. Whatever you do the 
memory balance between the two nodes is making the system behave in
an unsymmetric way.

> In some server, some application uses large memory allcation.
> This exhaust memory in the above order.

Could we add a boot time option instead that changes the zonelist build 
behavior? Maybe an arch hook that can deal with it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
