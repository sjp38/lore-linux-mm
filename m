Subject: Re: [patch 00/20] VM pageout scalability improvements
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20071223201149.7b88888f@bree.surriel.com>
References: <20071218211539.250334036@redhat.com>
	 <476D7334.4010301@linux.vnet.ibm.com>
	 <20071222192119.030f32d5@bree.surriel.com>
	 <476EE858.202@linux.vnet.ibm.com>
	 <20071223201149.7b88888f@bree.surriel.com>
Content-Type: text/plain
Date: Thu, 27 Dec 2007 21:20:41 -0600
Message-Id: <1198812041.4406.63.camel@cinder.waste.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 2007-12-23 at 20:11 -0500, Rik van Riel wrote:
> On Mon, 24 Dec 2007 04:29:36 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > Rik van Riel wrote:
> 
> > > In the real world, users with large JVMs on their servers, which
> > > sometimes go a little into swap, can trigger this system.  All of
> > > the CPUs end up scanning the active list, and all pages have the
> > > referenced bit set.  Even if the system eventually recovers, it
> > > might as well have been dead.
> > > 
> > > Going into swap a little should only take a little bit of time.
> > 
> > Very fascinating, so we need to scale better with larger memory.
> > I suspect part of the answer will lie with using large/huge pages.
> 
> Linus vetoed going to a larger soft page size, with good reason.
> 
> Just look at how much the 64kB page size on PPC64 sucks for most
> workloads - it works for PPC64 because people buy PPC64 monster
> systems for the kinds of monster workloads that work well with a
> large page size, but it definately isn't general purpose.

Indeed, machines already exist with >> 1TB of RAM, so even going to 1MB
pages leaves these machines in trouble. Going to big pages a few years
ago would have pushed the problem back a few years, but now we need real
fixes.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
