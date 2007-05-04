Date: Fri, 4 May 2007 16:59:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <1178318609.23795.214.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705041658350.28260@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
  <Pine.LNX.4.64.0705031937560.16542@schroedinger.engr.sgi.com>
 <1178298897.23795.195.camel@localhost.localdomain>
 <Pine.LNX.4.64.0705041118490.24283@schroedinger.engr.sgi.com>
 <1178318609.23795.214.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Tim Chen wrote:

> On Fri, 2007-05-04 at 11:27 -0700, Christoph Lameter wrote:
> 
> > 
> > Not sure where to go here. Increasing the per cpu slab size may hold off 
> > the issue up to a certain cpu cache size. For that we would need to 
> > identify which slabs create the performance issue.
> > 
> > One easy way to check that this is indeed the case: Enable fake NUMA. You 
> > will then have separate queues for each processor since they are on 
> > different "nodes". Create two fake nodes. Run one thread in each node and 
> > see if this fixes it.
> 
> I tried with fake NUMA (boot with numa=fake=2) and use
> 
> numactl --physcpubind=1 --membind=0 ./netserver
> numactl --physcpubind=2 --membind=1 ./netperf -t TCP_STREAM -l 60 -H
> 127.0.0.1 -i 5,5 -I 99,5 -- -s 57344 -S 57344 -m 4096
> 
> to run the tests.  The results are about the same as the non-NUMA case,
> with slab about 5% better than slub.  

Hmmmm... both tests were run in the same context? NUMA has additional 
overhead in other areas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
