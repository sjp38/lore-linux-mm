Date: Tue, 19 Aug 2008 21:50:07 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with
 _RET_IP_.
In-Reply-To: <48AB0D69.4090703@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0808192149340.21961@sbz-30.cs.Helsinki.FI>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
 <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro>
 <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro>
 <48AB0D69.4090703@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu wrote:
> >  void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
> >  {
> > -	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
> > +	return slab_alloc(s, gfpflags, -1, (void *) _RET_IP_);
> >  }
 
On Tue, 19 Aug 2008, Christoph Lameter wrote:
> Could you get rid of the casts by changing the type of parameter of slab_alloc()?

Yeah. How about something like this?

		Pekka
