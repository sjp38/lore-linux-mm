Subject: Re: [PATCH take3] Memoryless nodes:  use "node_memory_map" for
	cpuset mems_allowed validation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070725220023.GK18510@us.ibm.com>
References: <20070711182219.234782227@sgi.com>
	 <20070711182250.005856256@sgi.com>
	 <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
	 <1185309019.5649.69.camel@localhost>  <20070725220023.GK18510@us.ibm.com>
Content-Type: text/plain
Date: Thu, 26 Jul 2007 09:04:30 -0400
Message-Id: <1185455070.5070.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-25 at 15:00 -0700, Nishanth Aravamudan wrote:
> On 24.07.2007 [16:30:19 -0400], Lee Schermerhorn wrote:
> > Memoryless Nodes:  use "node_memory_map" for cpusets - take 3
> > 
> > Against 2.6.22-rc6-mm1 atop Christoph Lameter's memoryless nodes
> > series
> > 
> > take 2:
> > + replaced node_online_map in cpuset_current_mems_allowed()
> >   with node_states[N_MEMORY]
> > + replaced node_online_map in cpuset_init_smp() with
> >   node_states[N_MEMORY]
> > 
> > take 3:
> > + fix up comments and top level cpuset tracking of nodes
> >   with memory [instead of on-line nodes].
> > + maybe I got them all this time?
> 
> My ack stands, but I believe Documentation/cpusets.txt will need
> updating too :)

When [he says hopefully] I get the patches memoryless patches tested on
23-rc1-mm1, I'll include a documentation update patch.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
