Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 042E06B005D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 05:11:22 -0400 (EDT)
Subject: Re: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem
 in sl[aou]b
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090626090355.GA11450@wotan.suse.de>
References: <20090625193137.GA16861@linux.vnet.ibm.com>
	 <1245965239.21085.393.camel@calx>  <20090626090355.GA11450@wotan.suse.de>
Date: Fri, 26 Jun 2009 12:11:40 +0300
Message-Id: <1246007500.27533.23.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-26 at 11:03 +0200, Nick Piggin wrote:
> On Thu, Jun 25, 2009 at 04:27:19PM -0500, Matt Mackall wrote:
> > On Thu, 2009-06-25 at 12:31 -0700, Paul E. McKenney wrote:
> > > Hello!
> > > 
> > > Jesper noted that kmem_cache_destroy() invokes synchronize_rcu() rather
> > > than rcu_barrier() in the SLAB_DESTROY_BY_RCU case, which could result
> > > in RCU callbacks accessing a kmem_cache after it had been destroyed.
> > > 
> > > The following untested (might not even compile) patch proposes a fix.
> > 
> > Acked-by: Matt Mackall <mpm@selenic.com>
> > 
> > Nick, you'll want to make sure you get this in SLQB.
> 
> Thanks Matt. Paul, I think this should be appropriate for
> stable@kernel.org too?

Yup, I added cc to the patch. Thanks!

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
