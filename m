Date: Wed, 2 May 2007 13:14:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <20070502195412.GC9044@uranus.ravnborg.org>
Message-ID: <Pine.LNX.4.64.0705021312410.1978@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <20070501133618.93793687.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705021346170.16517@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705021002040.32271@schroedinger.engr.sgi.com>
 <20070502121105.de3433d5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705021234470.1543@schroedinger.engr.sgi.com>
 <20070502195412.GC9044@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Sam Ravnborg wrote:

> To facilitate this do NOT introduce CONFIG_SLAB until we decide
> that SLUB are default. In this way we can make CONFIG_SLUB be default
> and people will not continue with CONFIG_SLAB because they had it in their
> config already.

We already have CONFIG_SLAB. If you use your existing .config then
you will stay with SLAB.

> The point is make sure that LSUB becomes default for people that does
> an make oldconfig (explicit or implicit).

Hmmmm... We can think about that when we actually want to make SLUB the 
default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
