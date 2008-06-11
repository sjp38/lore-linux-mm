Date: Wed, 11 Jun 2008 16:25:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
In-Reply-To: <20080611190311.GA30958@shadowen.org>
Message-ID: <Pine.LNX.4.64.0806111624200.23868@schroedinger.engr.sgi.com>
References: <20080606180506.081f686a.akpm@linux-foundation.org>
 <20080608163413.08d46427@bree.surriel.com> <20080608135704.a4b0dbe1.akpm@linux-foundation.org>
 <20080608173244.0ac4ad9b@bree.surriel.com> <20080608162208.a2683a6c.akpm@linux-foundation.org>
 <20080608193420.2a9cc030@bree.surriel.com> <20080608165434.67c87e5c.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com>
 <20080610153702.4019e042@cuia.bos.redhat.com> <20080610143334.c53d7d8a.akpm@linux-foundation.org>
 <20080611190311.GA30958@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008, Andy Whitcroft wrote:

> I think we can say that although NUMAQ can have up to 64 NUMA nodes, in
> fact I don't think we have any more with more than 4 nodes left.  From
> the other discussion it sounds like we have a maximum if 8 nodes on
> other sub-arches.  So it would not be unreasonable to reduce the shift
> to 3.  Which might allow us to reduce the size of the reserve.
> 
> The problem will come with SPARSEMEM as that stores the section number
> in the reserved field.  Which can mean we need the whole reserve, and
> there is currently no simple way to remove that.

But in that case we can use the section number to look up the node number. 
That is done automatically if we have too many page flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
