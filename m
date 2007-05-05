Date: Sat, 5 May 2007 12:00:54 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
In-Reply-To: <Pine.LNX.4.64.0705041258390.25267@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705051159010.20143@sbz-30.cs.Helsinki.FI>
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>
  <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
 <1178301545.24217.56.camel@twins>  <Pine.LNX.4.64.0705041104110.23539@schroedinger.engr.sgi.com>
  <1178302904.2767.6.camel@lappy>  <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com>
 <1178303538.2767.9.camel@lappy> <463B7F63.8070508@cs.helsinki.fi>
 <Pine.LNX.4.64.0705041147000.24625@schroedinger.engr.sgi.com>
 <463B815E.8010806@cs.helsinki.fi> <Pine.LNX.4.64.0705041258390.25267@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Christoph Lameter wrote:
> He is not able to calculate it just using the object size since he does 
> not know where the slab put the slab management structure. And in case of 
> SLUB there is no slab management structure... Which means he would have to 
> special case based on the slab allocator selected.

Let me state this once more: he is interested in _rough approximation_. It 
makes no sense to me to add this kind of fuzzy logic in the slab. Now, as 
the slab clearly cannot give a _precise number_ either, it shouldn't be 
added there.

But, if both of you really want to stick it in mm/slab.c, I guess I won't 
be too violently opposed to it. It just doesn't make any sense to me.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
