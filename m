Date: Fri, 25 May 2007 14:43:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
In-Reply-To: <1180127552.21879.15.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705251441510.8208@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
 <200705242241.35373.ak@suse.de> <1180040744.5327.110.camel@localhost>
 <Pine.LNX.4.64.0705241417130.31587@schroedinger.engr.sgi.com>
 <1180104952.5730.28.camel@localhost>  <Pine.LNX.4.64.0705250823260.5850@schroedinger.engr.sgi.com>
  <1180109165.5730.32.camel@localhost>  <Pine.LNX.4.64.0705250914510.6070@schroedinger.engr.sgi.com>
  <1180114648.5730.64.camel@localhost>  <Pine.LNX.4.64.0705251156460.7281@schroedinger.engr.sgi.com>
 <1180127552.21879.15.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007, Lee Schermerhorn wrote:

> ??? Why?  Different processes could set different policies on the file
> in the file system.  The last one [before the file was mapped?] would
> rule.

Then the policy would be set on a file and not by processes. So there is 
one way of controlling the memory policy.

> Seems like a lot of extra effort that could be applied to other tasks,
> but you've worn me down.  I'll debug the numa_maps hang with hugetlb
> shmem segments with shared policy in the current code base, and reorder
> the patch set to handle correct display of shmem policy from all tasks
> first.  Next week or so.  

It may be worthwhile to split off the huge tlb pieces and cc those 
interested in huge pages. Maybe they can be treated like shmem?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
