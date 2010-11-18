Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 28A356B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:22:47 -0500 (EST)
Date: Thu, 18 Nov 2010 09:21:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [stable] [PATCH] Make swap accounting default behavior
 configurable
Message-ID: <20101118082132.GA15928@tiehlicka.suse.cz>
References: <20101116101726.GA21296@tiehlicka.suse.cz>
 <20101116124615.978ed940.akpm@linux-foundation.org>
 <20101116212157.GB9359@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101116212157.GB9359@kroah.com>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue 16-11-10 13:21:57, Greg KH wrote:
> On Tue, Nov 16, 2010 at 12:46:15PM -0800, Andrew Morton wrote:
> > On Tue, 16 Nov 2010 11:17:26 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > Hi Andrew,
> > > could you consider the following patch for the Linus tree, please?
> > > The discussion took place in this email thread 
> > > http://lkml.org/lkml/2010/11/10/114.
> > > The patch is based on top of 151f52f09c572 commit in the Linus tree.
> > > 
> > > Please let me know if there I should route this patch through somebody
> > > else.
> > > 
> > > Thanks!
> > > 
> > > ---
> > > >From 30238aaec758988493af793939f14b0ba83dc4b3 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.cz>
> > > Date: Wed, 10 Nov 2010 13:30:04 +0100
> > > Subject: [PATCH] Make swap accounting default behavior configurable
> > > 
> > > Swap accounting can be configured by CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > > configuration option and then it is turned on by default. There is
> > > a boot option (noswapaccount) which can disable this feature.
> > > 
> > > This makes it hard for distributors to enable the configuration option
> > > as this feature leads to a bigger memory consumption and this is a no-go
> > > for general purpose distribution kernel. On the other hand swap
> > > accounting may be very usuful for some workloads.
> > 
> > This patch is needed by distros, and distros use the -stable tree, I
> > assume.  Do you see reasons why this patch should be backported into
> > -stable, so distros don't need to patch it themselves?  If so, any
> > particular kernel versions?  2.6.37?

I have suggested pushing to the stable in the original thread as well. 
I was told that this is not a bug fix.

I do not care much in which particular version to push this but I
guess this doesn't qualify as "regression fix only Linus policy" so it
is probably too late for .37.
Nevertheless, if we reconsider -stable then .37 would be much really
helpful to get it into stable ASAP.

> 
> Sorry, I really don't want to start backporting features to stable
> kernels if at all possible.  Distros can pick them up on their own if
> they determine it is needed.

I really do agree with the part about features. But isn't this patch
basically for distros (to help them to provide the swapaccounting feature
without the cost of higher memory consumption in default configuration)?
If this doesn't go to the stable then all (interested) of them would
need to maintain the patch. Otherwise the change would come directly
from the upstream.

Moreover, it is not a new feature it just consolidates the default
behavior of the already existing functionality.

> 
> thanks,
> 
> greg k-h

Thanks
-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
