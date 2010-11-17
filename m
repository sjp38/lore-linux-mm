Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA178D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:40:17 -0500 (EST)
Date: Wed, 17 Nov 2010 09:23:39 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] Make swap accounting default behavior configurable
Message-Id: <20101117092339.1b7c2d6d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101116124615.978ed940.akpm@linux-foundation.org>
References: <20101116101726.GA21296@tiehlicka.suse.cz>
	<20101116124615.978ed940.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, stable@kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Nov 2010 12:46:15 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

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
> 
> > This patch adds a new configuration option which controls the default
> > behavior (CGROUP_MEM_RES_CTLR_SWAP_ENABLED). If the option is selected
> > then the feature is turned on by default.
> > 
> > It also adds a new boot parameter swapaccount which (contrary to
> > noswapaccount) enables the feature. (I would consider swapaccount=yes|no
> > semantic with removed noswapaccount parameter much better but this
> > parameter is kind of API which might be in use and unexpected breakage
> > is no-go.)
> > 
> > The default behavior is unchanged (if CONFIG_CGROUP_MEM_RES_CTLR_SWAP is
> > enabled then CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED is enabled as well)
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  Documentation/kernel-parameters.txt |    3 +++
> >  init/Kconfig                        |   13 +++++++++++++
> >  mm/memcontrol.c                     |   15 ++++++++++++++-
> >  3 files changed, 30 insertions(+), 1 deletions(-)
> > 
> > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > index ed45e98..14eafa5 100644
> > --- a/Documentation/kernel-parameters.txt
> > +++ b/Documentation/kernel-parameters.txt
> > @@ -2385,6 +2385,9 @@ and is between 256 and 4096 characters. It is defined in the file
> >  			improve throughput, but will also increase the
> >  			amount of memory reserved for use by the client.
> >  
> > +	swapaccount	[KNL] Enable accounting of swap in memory resource
> > +			controller. (See Documentation/cgroups/memory.txt)
> 
> So we have swapaccount and noswapaccount.  Ho hum, "swapaccount=[1|0]"
> would have been better.
> 
I suggested to keep "noswapaccount" for compatibility.
If you and other guys don't like having two parameters, I don't stick to
the old parameter.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
