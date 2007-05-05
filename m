Date: Fri, 4 May 2007 18:02:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <1178322083.23795.217.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705041800070.28492@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
  <Pine.LNX.4.64.0705031839480.16296@schroedinger.engr.sgi.com>
 <1178322083.23795.217.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Tim Chen wrote:

> On Thu, 2007-05-03 at 18:45 -0700, Christoph Lameter wrote:
> > Hmmmm.. One potential issues are the complicated way the slab is 
> > handled. Could you try this patch and see what impact it has?
> > 
> The patch boost the throughput of TCP_STREAM test by 5%, for both slab
> and slub.  But slab is still 5% better in my tests.

Really? buffer head handling improves TCP performance? I think you have 
run to run variances. I need to look at this myself.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
