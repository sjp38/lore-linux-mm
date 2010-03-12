Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8836B0113
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 22:02:39 -0500 (EST)
Date: Fri, 12 Mar 2010 11:54:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 1/3] memcg: wake up filter in oom waitqueue
Message-Id: <20100312115429.b1b0d994.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100312113838.d6072ae4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100311165315.c282d6d2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311165559.3f9166b2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312113028.1449915f.nishimura@mxp.nes.nec.co.jp>
	<20100312113838.d6072ae4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, kirill@shutemov.name, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 11:38:38 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 12 Mar 2010 11:30:28 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Thu, 11 Mar 2010 16:55:59 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > +	/* check hierarchy */
> > > +	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
> > > +	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
> > > +		return 0;
> > > +
> > I think these conditions are wrong.
> > This can wake up tasks in oom_wait_info->mem when:
> > 
> >   00/ <- wake_mem: use_hierarchy == false
> >     aa/ <- oom_wait_info->mem: use_hierarchy == true;
> > 
> Hmm. I think this line bails out above case.
> 
> > +	if (!oom_wait_info->mem->use_hierarchy || !wake_mem->use_hierarchy)
> > +		return 0;
> 
> No ?
> 
Oops! you're right. I misunderstood the code.

Then, this patch looks good to me.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
