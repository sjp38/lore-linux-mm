Date: Fri, 4 May 2007 11:10:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <1178298897.23795.195.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705041107290.23684@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
  <Pine.LNX.4.64.0705031937560.16542@schroedinger.engr.sgi.com>
 <1178298897.23795.195.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Tim Chen wrote:

> A side note is that for my tests, I bound the netserver and client to
> separate cpu core on different sockets in my tests, to make sure that
> the server and client do not share the same cache.  

Ahhh... You have some scripts that you run. Care to share?

This is no NUMA syste? Two processors in an SMP system?

So its likely an issue of partial slabs shifting between multiple cpus and 
if the partial slab is now used on the other cpu then it may be cache cold 
there. Different sockets mean limitations to FSB bandwidth and bad caching 
effects. I hope I can reproduce this somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
