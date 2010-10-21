Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 55FD16B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 17:07:38 -0400 (EDT)
Date: Thu, 21 Oct 2010 16:07:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
In-Reply-To: <alpine.DEB.2.00.1010211353540.17944@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1010211606010.32674@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <alpine.DEB.2.00.1010211259360.24115@router.home> <alpine.DEB.2.00.1010211353540.17944@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, David Rientjes wrote:

> This sets us up for node-targeted shrinking, but nothing is currently
> using it.  Do you have a patch (perhaps from Andi?) that can immediately
> use it?  That would be a compelling reason to merge this.

There is Nick's work coming into the tree soon which will need something
for icache and dcache I think. And there is the unified allocator which I
also want to use the shrinkers for expiring queues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
