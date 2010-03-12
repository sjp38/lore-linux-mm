Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9E3666B0114
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 22:07:21 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2C37J4e016090
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 12:07:19 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E024345DE54
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:07:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B848745DE53
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:07:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F0B41DB801A
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:07:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D475E08002
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 12:07:18 +0900 (JST)
Date: Fri, 12 Mar 2010 12:03:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/3] memcg: wake up filter in oom waitqueue
Message-Id: <20100312120341.857de693.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100312115429.b1b0d994.nishimura@mxp.nes.nec.co.jp>
References: <20100311165315.c282d6d2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311165559.3f9166b2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312113028.1449915f.nishimura@mxp.nes.nec.co.jp>
	<20100312113838.d6072ae4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312115429.b1b0d994.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, kirill@shutemov.name
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 11:54:29 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 12 Mar 2010 11:38:38 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 12 Mar 2010 11:30:28 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Thu, 11 Mar 2010 16:55:59 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > +	/* check hierarchy */
> > > > +	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
> > > > +	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
> > > > +		return 0;
> > > > +
> > > I think these conditions are wrong.
> > > This can wake up tasks in oom_wait_info->mem when:
> > > 
> > >   00/ <- wake_mem: use_hierarchy == false
> > >     aa/ <- oom_wait_info->mem: use_hierarchy == true;
> > > 
> > Hmm. I think this line bails out above case.
> > 
> > > +	if (!oom_wait_info->mem->use_hierarchy || !wake_mem->use_hierarchy)
> > > +		return 0;
> > 
> > No ?
> > 
> Oops! you're right. I misunderstood the code.
> 
> Then, this patch looks good to me.
> 
> 	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 

Thank you very much!

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
