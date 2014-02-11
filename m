Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9D86F6B0037
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:45:32 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id o15so12229764qap.16
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:45:32 -0800 (PST)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id d67si13116101qgf.25.2014.02.11.10.45.31
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 10:45:31 -0800 (PST)
Date: Tue, 11 Feb 2014 12:45:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 2/3] topology: support node_numa_mem() for determining
 the fallback node
In-Reply-To: <20140210012918.GD12574@lge.com>
Message-ID: <alpine.DEB.2.10.1402111244381.28186@nuc>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com> <1391674026-20092-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060041040.21148@chino.kir.corp.google.com>
 <CAAmzW4PXkdpNi5pZ=4BzdXNvqTEAhcuw-x0pWidqrxzdePxXxA@mail.gmail.com> <alpine.DEB.2.02.1402061248450.9567@chino.kir.corp.google.com> <20140207054819.GC28952@lge.com> <alpine.DEB.2.10.1402071150090.15168@nuc> <alpine.DEB.2.10.1402071245040.20246@nuc>
 <20140210012918.GD12574@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Mon, 10 Feb 2014, Joonsoo Kim wrote:

> On Fri, Feb 07, 2014 at 12:51:07PM -0600, Christoph Lameter wrote:
> > Here is a draft of a patch to make this work with memoryless nodes.
> >
> > The first thing is that we modify node_match to also match if we hit an
> > empty node. In that case we simply take the current slab if its there.
>
> Why not inspecting whether we can get the page on the best node such as
> numa_mem_id() node?

Its expensive to do so.

> empty_node cannot be set on memoryless node, since page allocation would
> succeed on different node.

Ok then we need to add a check for being on the rignt node there too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
