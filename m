Date: Wed, 2 Nov 2005 10:17:39 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051102091739.GA4856@elte.hu>
References: <4366D469.2010202@yahoo.com.au> <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu> <1130854224.14475.60.camel@localhost> <20051101142959.GA9272@elte.hu> <1130856555.14475.77.camel@localhost> <20051101150142.GA10636@elte.hu> <1130858580.14475.98.camel@localhost> <20051102084946.GA3930@elte.hu> <436880B8.1050207@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <436880B8.1050207@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Arjan van de Ven <arjanv@infradead.org>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Ingo Molnar wrote:
> 
> >really, once you accept that, the path out of this mess becomes 'easy': 
> >we _have to_ compromise on the feature side! And the moment we give up 
> >the notion of 'generic kernel RAM' and focus on the hot-removability of 
> >a limited-functionality zone, the complexity of the solution becomes 
> >three orders of magnitude smaller. No fragmentation avoidance necessary.  
> >No 'have to handle dozens of very hard problems to become 99% 
> >functional' issues. Once you make that zone an opt-in thing, it becomes 
> >much better from a development dynamics point of view as well.
> >
> 
> I agree. Especially considering that all this memory hotplug usage for 
> hypervisors etc. is a relatively new thing with few of our userbase 
> actually using it. I think a simple zones solution is the right way to 
> go for now.

btw., virtualization is pretty much a red herring here. Xen already has 
a 'balooning driver', where a guest OS can give back unused RAM on a 
page-granular basis. This is an advantage of having a fully virtualized 
guest OS. That covers 99% of the 'remove RAM' needs. So i believe the 
real target audience of hot-unplug is mostly limited to hardware-level 
RAM unplug.

[ Xen also offers other features like migration of live images to
  another piece of hardware, which further dampen the cost of
  virtualization (mapping overhead, etc.). With hot-remove you dont get
  such compound benefits of a conceptually more robust and thus more
  pervasive approach. ]

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
