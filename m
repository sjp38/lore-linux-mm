Date: Fri, 4 May 2007 11:47:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
In-Reply-To: <463B7F63.8070508@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0705041147000.24625@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>
  <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
 <1178301545.24217.56.camel@twins>  <Pine.LNX.4.64.0705041104110.23539@schroedinger.engr.sgi.com>
  <1178302904.2767.6.camel@lappy>  <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com>
 <1178303538.2767.9.camel@lappy> <463B7F63.8070508@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Pekka Enberg wrote:

> Again, slab has no way of actually estimating how many pages you need for a
> given number of objects. So we end up calculating some upper bound which
> doesn't belong in mm/slab.c. I am perfectly okay with:

It can give a worst case number and that is what he wants.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
