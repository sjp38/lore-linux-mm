Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4FEF96B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 13:51:12 -0400 (EDT)
Date: Tue, 17 Aug 2010 12:51:09 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q3 20/23] slub: Shared cache to exploit cross cpu caching
 abilities.
In-Reply-To: <alpine.DEB.2.00.1008162246500.26781@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008171234130.12188@router.home>
References: <20100804024514.139976032@linux.com> <20100804024535.338543724@linux.com> <alpine.DEB.2.00.1008162246500.26781@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 2010, David Rientjes wrote:

> This explodes on the memset() in slab_alloc() because of __GFP_ZERO on my
> system:

Well that seems to be because __kmalloc_node returned invalid address. Run
with full debugging please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
