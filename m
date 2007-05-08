Date: Mon, 7 May 2007 21:57:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <1178584834.15701.18.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705072150490.4939@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
  <Pine.LNX.4.64.0705031839480.16296@schroedinger.engr.sgi.com>
 <1178322083.23795.217.camel@localhost.localdomain>
 <Pine.LNX.4.64.0705041800070.28492@schroedinger.engr.sgi.com>
 <1178584834.15701.18.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 May 2007, Tim Chen wrote:

> However, the output from TCP_STREAM is quite stable.  
> I am still seeing a 4% difference between the SLAB and SLUB kernel.
> Looking at the L2 cache miss rate with emon, I saw 6% more cache miss on
> the client side with SLUB.  The server side has the same amount of cache
> miss.  This is test under SMP mode with client and server bound to
> different core on separate package.

If this is cache miss related then a larger page order may take are 
of this. Boot with (assume you got 2.6.21-mm1 at least...)

slub_min_order=6 slub_max_order=7

which will give you an allocation unit of 256k. Just tried it. It 
actually works but has no effect here whatsoever on UP netperf 
performance. netperf performance dropped from 6MB(slab)/6.2MB(slub) on 
2.6.21-rc7-mm1 to 4.5MB (both) on 2.6.21-mm1. So I guess there is 
something also going on with the networking layer.

Still have not found a machine here where I could repeat your 
results.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
