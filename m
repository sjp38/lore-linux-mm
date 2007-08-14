Date: Tue, 14 Aug 2007 23:29:55 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
Message-ID: <20070814212955.GC23308@one.firstfloor.org>
References: <20070814153021.446917377@sgi.com> <20070814153501.766137366@sgi.com> <p73vebhnauo.fsf@bingen.suse.de> <Pine.LNX.4.64.0708141209270.29498@schroedinger.engr.sgi.com> <20070814203329.GA22202@one.firstfloor.org> <Pine.LNX.4.64.0708141341120.31513@schroedinger.engr.sgi.com> <20070814204454.GC22202@one.firstfloor.org> <Pine.LNX.4.64.0708141414260.31693@schroedinger.engr.sgi.com> <20070814212355.GA23308@one.firstfloor.org> <Pine.LNX.4.64.0708141425000.31693@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708141425000.31693@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 14, 2007 at 02:26:43PM -0700, Christoph Lameter wrote:
> On Tue, 14 Aug 2007, Andi Kleen wrote:
> 
> > > So every spinlock would have an array of chars sized to NR_CPUS and set 
> > > the flag when the lock is taken?
> > 
> > I was more thinking of a single per cpu flag for all of page reclaim
> > That keeps it also cache local.
> 
> We already have such a flag in the zone structure

Zone structure is not strictly CPU local so it's broader
than needed. But it might work.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
