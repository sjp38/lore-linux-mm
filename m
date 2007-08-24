Subject: Re: [PATCH] Fix find_next_best_node (Re: [BUG] 2.6.23-rc3-mm1
	Kernel panic - not syncing: DMA: Memory would be corrupted)
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070824145233.GA26374@skynet.ie>
References: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com>
	 <20070823142133.9359a1ce.akpm@linux-foundation.org>
	 <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
	 <20070824145233.GA26374@skynet.ie>
Content-Type: text/plain
Date: Fri, 24 Aug 2007 11:49:31 -0400
Message-Id: <1187970572.5869.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-08-24 at 15:52 +0100, Mel Gorman wrote:
> On (24/08/07 15:53), Yasunori Goto didst pronounce:
> > 
> > I found find_next_best_node() was wrong.
> > I confirmed boot up by the following patch.
> > Mel-san, Kamalesh-san, could you try this?
> > 
> 
> This boots the IA-64 successful and gets rid of that DMA corrupts
> memory message. As a bonus, it fixes up the memoryless nodes (the bug
> where Total pages == 0 and there is a BUG in page_alloc.c) by building
> zonelists properly. The machine still fails to boot with the more familiar
> net/core/skbuff.c:95 but that is a separate problem.
> 
> Well spotted Yasunori-san.
> 
> Andrew, this fixes a real problem and should be considered a fix to
> memoryless-nodes-fixup-uses-of-node_online_map-in-generic-code.patch unless
> Christoph Lameter objects.

I reworked that patch and posted the update on 16aug which does not have
this problem:

http://marc.info/?l=linux-mm&m=118729871101418&w=4

This should replace
memoryless-nodes-fixup-uses-of-node_online_map-in-generic-code.patch
in -mm.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
