Date: Mon, 20 Aug 2007 11:57:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/5] mm/... convert #include "linux/..." to #include
 <linux/...>
In-Reply-To: <1187635766.5963.3.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708201157320.28863@schroedinger.engr.sgi.com>
References: <1187561983.4200.145.camel@localhost>
 <Pine.LNX.4.64.0708201106230.25248@schroedinger.engr.sgi.com>
 <1187635766.5963.3.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Perches <joe@perches.com>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Aug 2007, Joe Perches wrote:

> Maybe.  I think it's just a simple error.
> 
> mm/slab.c has 2 other includes of
> 
> 	#include <linux/kmalloc_sizes.h>
> 
> cheers, Joe

Ahh. ok.

Then

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
