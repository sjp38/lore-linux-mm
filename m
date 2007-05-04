Subject: RE: Regression with SLUB on Netperf and Volanomark
From: Tim Chen <tim.c.chen@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
In-Reply-To: <Pine.LNX.4.64.0705041658350.28260@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
	 <Pine.LNX.4.64.0705031937560.16542@schroedinger.engr.sgi.com>
	 <1178298897.23795.195.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0705041118490.24283@schroedinger.engr.sgi.com>
	 <1178318609.23795.214.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0705041658350.28260@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 04 May 2007 16:42:56 -0700
Message-Id: <1178322176.23795.219.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-04 at 16:59 -0700, Christoph Lameter wrote:

> > 
> > to run the tests.  The results are about the same as the non-NUMA case,
> > with slab about 5% better than slub.  
> 
> Hmmmm... both tests were run in the same context? NUMA has additional 
> overhead in other areas.

Both slab and slub tests are tested with the same NUMA options and
config.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
