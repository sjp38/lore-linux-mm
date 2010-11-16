Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B63C6B0085
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 16:22:27 -0500 (EST)
Date: Tue, 16 Nov 2010 13:21:57 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] Make swap accounting default behavior
 configurable
Message-ID: <20101116212157.GB9359@kroah.com>
References: <20101116101726.GA21296@tiehlicka.suse.cz>
 <20101116124615.978ed940.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101116124615.978ed940.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 16, 2010 at 12:46:15PM -0800, Andrew Morton wrote:
> On Tue, 16 Nov 2010 11:17:26 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Hi Andrew,
> > could you consider the following patch for the Linus tree, please?
> > The discussion took place in this email thread 
> > http://lkml.org/lkml/2010/11/10/114.
> > The patch is based on top of 151f52f09c572 commit in the Linus tree.
> > 
> > Please let me know if there I should route this patch through somebody
> > else.
> > 
> > Thanks!
> > 
> > ---
> > >From 30238aaec758988493af793939f14b0ba83dc4b3 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Wed, 10 Nov 2010 13:30:04 +0100
> > Subject: [PATCH] Make swap accounting default behavior configurable
> > 
> > Swap accounting can be configured by CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > configuration option and then it is turned on by default. There is
> > a boot option (noswapaccount) which can disable this feature.
> > 
> > This makes it hard for distributors to enable the configuration option
> > as this feature leads to a bigger memory consumption and this is a no-go
> > for general purpose distribution kernel. On the other hand swap
> > accounting may be very usuful for some workloads.
> 
> This patch is needed by distros, and distros use the -stable tree, I
> assume.  Do you see reasons why this patch should be backported into
> -stable, so distros don't need to patch it themselves?  If so, any
> particular kernel versions?  2.6.37?

Sorry, I really don't want to start backporting features to stable
kernels if at all possible.  Distros can pick them up on their own if
they determine it is needed.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
