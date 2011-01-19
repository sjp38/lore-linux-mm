Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 89CFB6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 19:54:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7CE393EE0BB
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:54:09 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6095F45DE5E
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:54:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 37C0345DE58
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:54:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 23C2EE08003
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:54:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E2F601DB803F
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 09:54:08 +0900 (JST)
Date: Wed, 19 Jan 2011 09:48:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4] mm: add replace_page_cache_page() function
Message-Id: <20110119094813.2ea20439.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110119092733.4927f935.nishimura@mxp.nes.nec.co.jp>
References: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
	<20110118152844.88cfdc2c.akpm@linux-foundation.org>
	<20110119092733.4927f935.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, minchan.kim@gmail.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011 09:27:33 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 18 Jan 2011 15:28:44 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Tue, 18 Jan 2011 12:18:11 +0100
> > Miklos Szeredi <miklos@szeredi.hu> wrote:
> > 
> > > +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> > > +{
> > > +	int error;
> > > +	struct mem_cgroup *memcg = NULL;
> > 
> > I'm suspecting that the unneeded initialisation was added to suppress a
> > warning?
> > 
> No.
> It's necessary for mem_cgroup_{prepare|end}_migration().
> mem_cgroup_prepare_migration() will return without doing anything in
> "if (mem_cgroup_disabled()" case(iow, "memcg" is not overwritten),
> but mem_cgroup_end_migration() depends on the value of "memcg" to decide
> whether prepare_migration has succeeded or not.
> This may not be a good implementation, but IMHO I'd like to to initialize
> valuable before using it in general.
> 

I think it can be initlized in mem_cgroup_prepare_migration().
I'll send patch later.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
