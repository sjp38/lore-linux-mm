Date: Thu, 29 Nov 2007 12:18:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [3/10] per-zone active inactive counter
Message-Id: <20071129121834.c18ff796.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071129112406.c6820a5e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071127115525.e9779108.kamezawa.hiroyu@jp.fujitsu.com>
	<20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
	<1196284799.5318.34.camel@localhost>
	<20071129103702.cbc5cf73.kamezawa.hiroyu@jp.fujitsu.com>
	<20071129112406.c6820a5e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007 11:24:06 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 29 Nov 2007 10:37:02 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Maybe zonelists of NODE_DATA() is not initialized. you are right.
> > I think N_HIGH_MEMORY will be suitable here...(I'll consider node-hotplug case later.)
> > 
> > Thank you for test!
> > 
> Could you try this ? 
> 
Sorry..this can be a workaround but I noticed I miss something..

ok, just use N_HIGH_MEMORY here and add comment for hotplugging support is not yet.

Christoph-san, Lee-san, could you confirm following ?

- when SLAB is used, kmalloc_node() against offline node will success.
- when SLUB is used, kmalloc_node() against offline node will panic.

Then, the caller should take care that node is online before kmalloc().

Regards,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
