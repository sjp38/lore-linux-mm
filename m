Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback
	list initialization
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <200602171315.45419.ak@suse.de>
References: <200602170223.34031.ak@suse.de> <200602171058.33078.ak@suse.de>
	 <20060217112324.GA31068@localhost>  <200602171315.45419.ak@suse.de>
Content-Type: text/plain
Date: Fri, 17 Feb 2006 09:34:13 -0500
Message-Id: <1140186854.5219.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Bob Picco <bob.picco@hp.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Christoph Lameter <clameter@engr.sgi.com>, torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-02-17 at 13:15 +0100, Andi Kleen wrote:
> On Friday 17 February 2006 12:23, Bob Picco wrote:
> 
> > Yasunori thanks for mentioning memory less nodes for ia64.  This is my
> > concern with the patch.
> 
> I very much doubt it worked before without this patch in 2.6.16-* (unless you have
> the memory less nodes all at the end and not in the middle) 

Yes, that is the case with HP NUMA platforms.  When configure with fully
hardware interleaved memory, all of the real nodes, 0-n, show up as having
no memory while containing all the cpus.  The memory shows up as a ficticious
node n+1 with no cpus.  For completeness, I should mention that even when
configured for "100% cell local memory", the platforms still have the 
memory-only pseudo-node containing 512MB [on 4 node system, e.g.] of 
interleaved memory--at physaddr 0, I believe.  

Except for the ACPI slab corruption that Bjorn fixed recently, 2.6.16-rc*
has successfully booted on these platforms.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
