Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 49D9F6B0095
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 11:09:57 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5EE0A82C2B6
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 11:13:50 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WwrDF7ESl0us for <linux-mm@kvack.org>;
	Tue, 17 Feb 2009 11:13:45 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8D80282C42B
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 11:12:50 -0500 (EST)
Date: Tue, 17 Feb 2009 11:01:30 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 1/8] slab: introduce kzfree()
In-Reply-To: <1234885876.11511.3.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0902171100520.29986@qirst.com>
References: <20090216142926.440561506@cmpxchg.org>  <20090216144725.572446535@cmpxchg.org> <20090216152751.GA27520@cmpxchg.org>  <alpine.DEB.1.10.0902171007010.19685@qirst.com> <1234885876.11511.3.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Feb 2009, Pekka Enberg wrote:

> Johannes, I suppose it would make sense to resend the series to Andrew
> with all the updates?

Ah now when looking at the whole set I see the point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
