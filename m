Date: Thu, 3 May 2007 17:44:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0705031740470.15240@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Tim C" <tim.c.chen@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 May 2007, Chen, Tim C wrote:

> We are still seeing a 5% regression on TCP streaming with
> slub_min_objects set at 16 and a 10% regression for Volanomark, after
> increasing slub_min_objects to 16 and setting slub_max_order=4 and using
> the 2.6.21-rc7-mm2 kernel.  The performance between slub_min_objects=8
> and 16 are similar.

Ok. We then need to look at partial list management. It could be that the 
sequence of partials is reversed. The problem is that I do not really 
have time to concentrate on performance right now. Stability comes 
first. We will likely end up putting some probes in there to find out 
where the overhead comes from.

> > Check slabinfo output for the network slabs and see what order is
> > used. The number of objects per slab is important for performance.
> 
> The order used is 0 for the buffer_head, which is the most used object.
> 
> I think they are 104 bytes per object.

Hmmm.... Then it was not affected by slab_max_order? Try 
slab_min_order=1 or 2 to increase that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
