Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7945B6B01B9
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:41:39 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:38:35 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 04/16] slub: Use a constant for a unspecified node.
In-Reply-To: <20100628112550.87fbb1e4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006291037410.16135@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212103.443416439@quilx.com> <20100628112550.87fbb1e4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010, KAMEZAWA Hiroyuki wrote:

> On Fri, 25 Jun 2010 16:20:30 -0500
> Christoph Lameter <cl@linux-foundation.org> wrote:
>
> > kmalloc_node() and friends can be passed a constant -1 to indicate
> > that no choice was made for the node from which the object needs to
> > come.
> >
> > Use NUMA_NO_NODE instead of -1.
> >
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> >
> Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> How about more updates ?

Would be a great idea. Can you take over this patch and add the missing
pieces? I dont have too much time in the next weeks. Also am on vacation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
