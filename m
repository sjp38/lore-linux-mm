Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7F3C56B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 13:30:52 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0ED7882CE56
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 13:36:52 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1zoftn0T21rU for <linux-mm@kvack.org>;
	Thu, 29 Oct 2009 13:36:46 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3917882CE55
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 13:36:45 -0400 (EDT)
Date: Thu, 29 Oct 2009 17:30:09 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH/RFC] slab:  handle memoryless nodes efficiently
In-Reply-To: <1256836094.16599.67.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.10.0910291728200.30007@V090114053VZO-1>
References: <1256836094.16599.67.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Maybe better introduce an alternative to numa_node_id that refers to the
next memory node?

numa_mem_node_id?

We can then use that in various subsystems and could use it consistently
also in slab.c

One problem with such a scheme (and also this patch) is that multiple
memory nodes may be at the same distance to a processor on a memoryless
node. Should the allocation not take memory from any of these nodes?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
