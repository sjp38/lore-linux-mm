Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4661E6B01F3
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 15:11:28 -0400 (EDT)
Date: Wed, 25 Aug 2010 14:11:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: linux-next: Tree for August 25 (mm/slub)
In-Reply-To: <20100825094559.bc652afe.randy.dunlap@oracle.com>
Message-ID: <alpine.DEB.2.00.1008251409260.22117@router.home>
References: <20100825132057.c8416bef.sfr@canb.auug.org.au> <20100825094559.bc652afe.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010, Randy Dunlap wrote:

> and in different builds:
>
> mm/slub.c:1898: note: expected 'struct kmem_cache *' but argument is of type 'struct kmem_cache **'
> mm/slub.c:1756: note: expected 'struct kmem_cache *' but argument is of type 'struct kmem_cache **'

Hmmm... Any details on the configuration that got you this result?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
