Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2113E6B0087
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 10:16:16 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DACD382C4E9
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 10:20:09 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sYAbqqQxKltl for <linux-mm@kvack.org>;
	Tue, 17 Feb 2009 10:20:05 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 81B8082C4EA
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 10:20:00 -0500 (EST)
Date: Tue, 17 Feb 2009 10:08:21 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 1/8] slab: introduce kzfree()
In-Reply-To: <20090216152751.GA27520@cmpxchg.org>
Message-ID: <alpine.DEB.1.10.0902171007010.19685@qirst.com>
References: <20090216142926.440561506@cmpxchg.org> <20090216144725.572446535@cmpxchg.org> <20090216152751.GA27520@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Why would you want to zero an object on release? Is this for security?

Please give us some rationale for this. Do we need free on zero now for
all allocators?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
