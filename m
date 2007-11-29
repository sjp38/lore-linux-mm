Date: Wed, 28 Nov 2007 19:26:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [3/10] per-zone active inactive counter
In-Reply-To: <20071129121834.c18ff796.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0711281924580.20367@schroedinger.engr.sgi.com>
References: <20071127115525.e9779108.kamezawa.hiroyu@jp.fujitsu.com>
 <20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
 <1196284799.5318.34.camel@localhost> <20071129103702.cbc5cf73.kamezawa.hiroyu@jp.fujitsu.com>
 <20071129112406.c6820a5e.kamezawa.hiroyu@jp.fujitsu.com>
 <20071129121834.c18ff796.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007, KAMEZAWA Hiroyuki wrote:

> ok, just use N_HIGH_MEMORY here and add comment for hotplugging support is not yet.
> 
> Christoph-san, Lee-san, could you confirm following ?
> 
> - when SLAB is used, kmalloc_node() against offline node will success.
> - when SLUB is used, kmalloc_node() against offline node will panic.
> 
> Then, the caller should take care that node is online before kmalloc().

Hmmmm... An offline node implies that the per node structure does not 
exist. SLAB should fail too. If there is something wrong with the allocs 
then its likely a difference in the way hotplug was put into SLAB and 
SLUB.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
