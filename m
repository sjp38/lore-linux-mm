Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 616726B0082
	for <linux-mm@kvack.org>; Thu, 14 May 2009 20:55:29 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4F0uHui004045
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 15 May 2009 09:56:19 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F41E45DD76
	for <linux-mm@kvack.org>; Fri, 15 May 2009 09:56:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 60C9445DD74
	for <linux-mm@kvack.org>; Fri, 15 May 2009 09:56:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F87BE08001
	for <linux-mm@kvack.org>; Fri, 15 May 2009 09:56:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E7500E08002
	for <linux-mm@kvack.org>; Fri, 15 May 2009 09:56:16 +0900 (JST)
Date: Fri, 15 May 2009 09:54:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] fix stale swap cache account leak  in memcg v7
Message-Id: <20090515095445.9492fe13.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090515093853.e97fd120.nishimura@mxp.nes.nec.co.jp>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512095158.GB6351@balbir.in.ibm.com>
	<20090513093127.4dadac97.kamezawa.hiroyu@jp.fujitsu.com>
	<20090515084716.544930d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090515093853.e97fd120.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 15 May 2009 09:38:53 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 15 May 2009 08:47:16 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 13 May 2009 09:31:27 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Tue, 12 May 2009 15:21:58 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > > The patch set includes followng
> > > > >  [1/3] add mem_cgroup_is_activated() function. which tell us memcg is _really_ used.
> > > > >  [2/3] fix swap cache handling race by avoidng readahead.
> > > > >  [3/3] fix swap cache handling race by check swapcount again.
> > > > > 
> > > > > Result is good under my test.
> > > > 
> > > > What was the result (performance data impact) of disabling swap
> > > > readahead? Otherwise, this looks the most reasonable set of patches
> > > > for this problem.
> > > > 
> > > I'll measure some and report it in the next post.
> > > 
> > I confirmed there are cases which swapin readahead works very well....
> > 
> > Nishimura-san, could you post a patch for fixing leak at writeback ? as [3/3]
> > I'd like to fix readahead case...with some large patch.
> > 
> Sure.
> I'll rebase my patch onto [1-2/3] of your new patch and post it.
> 
Ah, plz go ahead and don't wait for me. Mine is just under rough design now.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
