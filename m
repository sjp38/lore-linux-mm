Subject: RE: Regression with SLUB on Netperf and Volanomark
From: Tim Chen <tim.c.chen@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
In-Reply-To: <Pine.LNX.4.64.0705041107290.23684@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
	 <Pine.LNX.4.64.0705031937560.16542@schroedinger.engr.sgi.com>
	 <1178298897.23795.195.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0705041107290.23684@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 04 May 2007 10:39:11 -0700
Message-Id: <1178300352.23795.202.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-04 at 11:10 -0700, Christoph Lameter wrote:
> On Fri, 4 May 2007, Tim Chen wrote:
> 
> > A side note is that for my tests, I bound the netserver and client to
> > separate cpu core on different sockets in my tests, to make sure that
> > the server and client do not share the same cache.  
> 
> Ahhh... You have some scripts that you run. Care to share?

I do

taskset -c 1 netserver

and

taskset -c 2 netperf  -t TCP_STREAM -l 60 -H 127.0.0.1 -- -s 57344 -S
57344 -m 4096

> 
> This is no NUMA syste? Two processors in an SMP system?

Yes, it is a SMP system with 2 socket.  Each socket has 4 cores.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
