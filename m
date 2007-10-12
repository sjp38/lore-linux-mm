Date: Thu, 11 Oct 2007 21:09:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch 001/002] extract kmem_cache_shrink
In-Reply-To: <20071012112648.B99F.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0710112054220.1882@schroedinger.engr.sgi.com>
References: <20071012111008.B995.Y-GOTO@jp.fujitsu.com>
 <20071012112236.B99B.Y-GOTO@jp.fujitsu.com> <20071012112648.B99F.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Oct 2007, Yasunori Goto wrote:

> Make kmem_cache_shrink_node() for callback routine of memory hotplug
> notifier. This is just extract a part of kmem_cache_shrink().

Could we just call kmem_cache_shrink? It will do the shrink on every node 
but memory hotplug is rare?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
