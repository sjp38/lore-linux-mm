Date: Wed, 13 Sep 2006 11:00:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
In-Reply-To: <20060913174948.GA6533@sgi.com>
Message-ID: <Pine.LNX.4.64.0609131056260.18136@schroedinger.engr.sgi.com>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
 <1158046205.2992.1.camel@laptopd505.fenrus.org>
 <Pine.LNX.4.64.0609121024290.11188@schroedinger.engr.sgi.com>
 <yq0d5a0fbcj.fsf@jaguar.mkp.net> <Pine.LNX.4.64.0609130109030.15792@schroedinger.engr.sgi.com>
 <4507D4EE.4060501@sgi.com> <Pine.LNX.4.64.0609131015360.17927@schroedinger.engr.sgi.com>
 <20060913174948.GA6533@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Jes Sorensen <jes@sgi.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, Jack Steiner wrote:

> 	- will any IA64 platform require that ZONE_DMA be enabled (I think
> 	  the answer is "yes")

I think that still remains to be discussed. Today there are various means
to get around address restrictions.

> 	- if ZONE_DMA is enabled, ALTIX will still use only 1 zone. In your
> 	  statement above, you say that disabling ZONE_DMA save 1M cpu
> 	  structures. If ZONE_DMA is enabled, will these 1M structure be allocated
> 	  on SN even though they are not needed?

That has always been the case. In SLES9 and SLES10 we are using 1/4th of the pagesets.

Having no ZONE_DMA provides additional benefits besides saving memory. The 
VM balancing of allocations within a node becomes not necessary and 
various VM optimization can be performed. Loops are unrolled. Less zones 
have to be processed for draining / vm counter updates etc etc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
