Subject: Re: [PATCH 5/5] mm/... convert #include "linux/..." to #include
	<linux/...>
From: Joe Perches <joe@perches.com>
In-Reply-To: <Pine.LNX.4.64.0708201106230.25248@schroedinger.engr.sgi.com>
References: <1187561983.4200.145.camel@localhost>
	 <Pine.LNX.4.64.0708201106230.25248@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 20 Aug 2007 11:49:26 -0700
Message-Id: <1187635766.5963.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-20 at 11:06 -0700, Christoph Lameter wrote:
> On Sun, 19 Aug 2007, Joe Perches wrote:
> > diff --git a/mm/slab.c b/mm/slab.c
> > -#include "linux/kmalloc_sizes.h"
> > +#include <linux/kmalloc_sizes.h>
> But I think this was done intentionally to point out that the file 
> includes is *not* a regular include file.

Maybe.  I think it's just a simple error.

mm/slab.c has 2 other includes of

	#include <linux/kmalloc_sizes.h>

cheers, Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
