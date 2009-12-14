Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 372706B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 11:19:53 -0500 (EST)
Date: Mon, 14 Dec 2009 17:19:44 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
Message-ID: <20091214161944.GB16474@basil.fritz.box>
References: <20091210185626.26f9828a@cuia.bos.redhat.com> <87pr6hya86.fsf@basil.nowhere.org> <1260800599.6666.4.camel@dhcp-100-19-198.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1260800599.6666.4.camel@dhcp-100-19-198.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, Dec 14, 2009 at 09:23:19AM -0500, Larry Woodman wrote:
> On Mon, 2009-12-14 at 14:08 +0100, Andi Kleen wrote:
> > Rik van Riel <riel@redhat.com> writes:
> > 
> > > +max_zone_concurrent_reclaim:
> > > +
> > > +The number of processes that are allowed to simultaneously reclaim
> > > +memory from a particular memory zone.
> > > +
> > > +With certain workloads, hundreds of processes end up in the page
> > > +reclaim code simultaneously.  This can cause large slowdowns due
> > > +to lock contention, freeing of way too much memory and occasionally
> > > +false OOM kills.
> > > +
> > > +To avoid these problems, only allow a smaller number of processes
> > > +to reclaim pages from each memory zone simultaneously.
> > > +
> > > +The default value is 8.
> > 
> > I don't like the hardcoded number. Is the same number good for a 128MB
> > embedded system as for as 1TB server?  Seems doubtful.
> > 
> > This should be perhaps scaled with memory size and number of CPUs?
> 
> Remember this a per-zone number.

A zone could be 64MB or 32GB. And the system could have 1 or 1024 CPUs.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
