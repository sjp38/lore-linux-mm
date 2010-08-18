Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 084996B01F3
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:20:52 -0400 (EDT)
Date: Thu, 19 Aug 2010 00:13:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Over-eager swapping
Message-ID: <20100818161346.GA12932@localhost>
References: <AANLkTi=wRPXY9BTuoCe_sDCwhnRjmmwtAf_bjDKG3kXQ@mail.gmail.com>
 <20100804032400.GA14141@localhost>
 <20100804095811.GC2326@arachsys.com>
 <20100804114933.GA13527@localhost>
 <20100804120430.GB23551@arachsys.com>
 <20100818143801.GA9086@localhost>
 <20100818144655.GX2370@arachsys.com>
 <20100818152103.GA11268@localhost>
 <1282147034.77481.33.camel@useless.localdomain>
 <20100818155825.GA2370@arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100818155825.GA2370@arachsys.com>
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 18, 2010 at 11:58:25PM +0800, Chris Webb wrote:
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> writes:
> 
> > On Wed, 2010-08-18 at 23:21 +0800, Wu Fengguang wrote:
> > > Andi, Christoph and Lee:
> > > 
> > > This looks like an "unbalanced NUMA memory usage leading to premature
> > > swapping" problem.
> > 
> > What is the value of the vm.zone_reclaim_mode sysctl?  If it is !0, the
> > system will go into zone reclaim before allocating off-node pages.
> > However, it shouldn't "swap" in this case unless (zone_reclaim_mode & 4)
> > != 0.  And even then, zone reclaim should only reclaim file pages, not
> > anon.  In theory...
> 
> Hi. This is zero on all our machines:
> 
> # sysctl vm.zone_reclaim_mode
> vm.zone_reclaim_mode = 0

Chris, can you post /proc/vmstat on the problem machines?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
