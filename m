Subject: Re: [PATCH 00/14] NUMA: Memoryless node support V4
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070727205937.GU18510@us.ibm.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727205937.GU18510@us.ibm.com>
Content-Type: text/plain
Date: Mon, 30 Jul 2007 09:48:28 -0400
Message-Id: <1185803309.5492.1.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 13:59 -0700, Nishanth Aravamudan wrote:
> On 27.07.2007 [15:43:16 -0400], Lee Schermerhorn wrote:
> > Changes V3->V4:
> > - Refresh against 23-rc1-mm1
> > - teach cpusets about memoryless nodes.
> > 
> > Changes V2->V3:
> > - Refresh patches (sigh)
> > - Add comments suggested by Kamezawa Hiroyuki
> > - Add signoff by Jes Sorensen
> > 
> > Changes V1->V2:
> > - Add a generic layer that allows the definition of additional node bitmaps
> 
> Are you carrying this stack anywhere publicly? Like in a git tree or
> even just big patch format?


Sorry.  Christoph did ask me to do this, but I booked out of here on
Friday w/o doing so.  Tarball now at:

http://free.linux.hp.com/~lts/Patches/MemlessNodes/

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
