Date: Wed, 24 Oct 2007 09:56:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB 0:1 SLAB (OOM during massive parallel kernel builds)
In-Reply-To: <84144f020710231341p189435b1y5514e5be981b9b1c@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0710240955480.26202@schroedinger.engr.sgi.com>
References: <20071023181615.GA10377@martell.zuzino.mipt.ru>
 <Pine.LNX.4.64.0710231227590.19626@schroedinger.engr.sgi.com>
 <84144f020710231304h6cba8626na4ab4bec0acda7a0@mail.gmail.com>
 <Pine.LNX.4.64.0710231305050.20095@schroedinger.engr.sgi.com>
 <84144f020710231341p189435b1y5514e5be981b9b1c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Oct 2007, Pekka Enberg wrote:

> Yeah, but we're _not failing_ when debugging is enabled. Thus, it's
> likely, that the _failing_ (non-debug) case has potential for more
> order 0 allocs, no? I am just guessing here but maybe it's
> slab_order() behaving differently from calculate_slab_order() so that
> we see more order 0 pressure in SLUB than SLAB?

Seesm that order 0 pressure is better than order 1?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
