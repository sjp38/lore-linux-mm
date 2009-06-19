Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 243E56B004D
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 12:42:22 -0400 (EDT)
Date: Fri, 19 Jun 2009 09:43:38 -0700
From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class
 citizen
Message-ID: <20090619094338.4d3c566d@jbarnes-g45>
In-Reply-To: <20090619093224.GA30898@localhost>
References: <20090516090005.916779788@intel.com>
	<1242485776.32543.834.camel@laptop>
	<20090617141135.0d622bfe@jbarnes-g45>
	<20090618012532.GB19732@localhost>
	<20090619090011.GA30561@localhost>
	<1245402289.13761.24606.camel@twins>
	<20090619093224.GA30898@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "tytso@mit.edu" <tytso@mit.edu>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "Wang, Roger" <roger.wang@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jun 2009 17:32:24 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Fri, Jun 19, 2009 at 05:04:49PM +0800, Peter Zijlstra wrote:
> > On Fri, 2009-06-19 at 17:00 +0800, Wu, Fengguang wrote:
> > > [add CC]
> > > 
> > > This OOM case looks like the same bug encountered by David
> > > Howells.
> > > 
> > > > Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426766]
> > > > Active_anon:290797 active_file:28 inactive_anon:97034 Jun 18
> > > > 07:44:53 jbarnes-g45 kernel: [64377.426767]  inactive_file:61
> > > > unevictable:11322 dirty:0 writeback:0 unstable:0 Jun 18
> > > > 07:44:53 jbarnes-g45 kernel: [64377.426768]  free:3341
> > > > slab:13776 mapped:5880 pagetables:6851 bounce:0
> > > 
> > > active/inactive_anon pages take up 4/5 memory.  Are you using
> > > TMPFS a lot?
> > 
> > I suspect its his GEM thingy ;-)
> 
> Very likely - GEM allocates drm objects from the internal tmpfs,
> and libdrm_intel seems to never free drm objects from its cache.

Yeah, a good chunk of that is GEM objects.  I generally haven't seen
OOMs due to excessive GEM allocation though, until recently.  We've got
some patches queued up to manage the object cache better (actually free
pages when we don't need them!), so that should help.

-- 
Jesse Barnes, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
