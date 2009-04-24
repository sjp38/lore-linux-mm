Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 752F56B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 00:34:12 -0400 (EDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp [192.51.44.35])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3O4YgqU016261
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 24 Apr 2009 13:34:42 +0900
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3O4YdJ1021387
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 24 Apr 2009 13:34:39 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E8BC45DD75
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 13:34:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CA2C45DD6C
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 13:34:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 097791DB8012
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 13:34:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B119FE08004
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 13:34:38 +0900 (JST)
Date: Fri, 24 Apr 2009 13:33:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] fix swap entries is not reclaimed in proper way
 for mem+swap controller
Message-Id: <20090424133306.0d9fb2ce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
References: <20090421162121.1a1d15fe.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422143833.2e11e10b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009 14:38:33 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
> > +extern void mem_cgroup_mark_swapcache_stale(struct page *page);
> > +extern void mem_cgroup_fixup_swapcache(struct page *page);
> >  #else
> >  static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
> >  {
> >  }
> > +static void mem_cgroup_check_mark_swapcache_stale(struct page *page)
> > +{
> > +}
> > +static void mem_cgroup_fixup_swapcache(struct page *page)
> > +{
> > +}
> >  #endif
> >  
> I think they should be defined in MEM_RES_CTLR case.
> Exhausting swap entries problem is not depend on MEM_RES_CTLR_SWAP.
> 
Could you explain this more ? I can't understand.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
