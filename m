Date: Wed, 13 Sep 2006 10:23:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
In-Reply-To: <4507D4EE.4060501@sgi.com>
Message-ID: <Pine.LNX.4.64.0609131015360.17927@schroedinger.engr.sgi.com>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
 <1158046205.2992.1.camel@laptopd505.fenrus.org>
 <Pine.LNX.4.64.0609121024290.11188@schroedinger.engr.sgi.com>
 <yq0d5a0fbcj.fsf@jaguar.mkp.net> <Pine.LNX.4.64.0609130109030.15792@schroedinger.engr.sgi.com>
 <4507D4EE.4060501@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jes Sorensen <jes@sgi.com>
Cc: Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, Jes Sorensen wrote:

> > There was the floppy driver and one type of USB stick that I noticed 
> > during the work on the project. But other drivers may depend also depend 
> > indirectly on DMA functionality and may also be disabled.
> 
> Ok, USB should ring alarm bells, floppy I think is less relevant these
> days :)

If you want all drivers then you must of course have ZONE_DMA. 
Distributions that want to cover all drivers will have it on by default 
and ZONE_DMA is available by default.

However, if you want to create a lean and mean kernel then you can switch 
ZONE_DMA off and if there is just one zone left then the VM can 
optimized much better because loops are avoided and some macros 
become constant etc etc.

Some architectures never need ZONE_DMA because all hardware supports DMA 
to all of memory. SGI Altix is one example. Carrying an additional 
useless zone around unecessarily bloats the kernel both in term of code 
and data. Data is a particular issue since zones contain per cpu elements. 
For a 1k cpu 1k node configuration this saves around 1 million per cpu 
structures (one zone per node with 1k per cpu pagesets).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
