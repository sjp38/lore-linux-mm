Date: Fri, 12 Oct 2007 13:41:52 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch 001/002] extract kmem_cache_shrink
In-Reply-To: <Pine.LNX.4.64.0710112054220.1882@schroedinger.engr.sgi.com>
References: <20071012112648.B99F.Y-GOTO@jp.fujitsu.com> <Pine.LNX.4.64.0710112054220.1882@schroedinger.engr.sgi.com>
Message-Id: <20071012134021.B9A7.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 12 Oct 2007, Yasunori Goto wrote:
> 
> > Make kmem_cache_shrink_node() for callback routine of memory hotplug
> > notifier. This is just extract a part of kmem_cache_shrink().
> 
> Could we just call kmem_cache_shrink? It will do the shrink on every node 
> but memory hotplug is rare?

Yes it is. Memory hotplug is rare.
Ok. I'll do it.

Thanks.
-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
