Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B9B726B007E
	for <linux-mm@kvack.org>; Thu, 14 May 2009 20:48:29 -0400 (EDT)
Date: Fri, 15 May 2009 09:38:53 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 0/3] fix stale swap cache account leak  in memcg v7
Message-Id: <20090515093853.e97fd120.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090515084716.544930d9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512095158.GB6351@balbir.in.ibm.com>
	<20090513093127.4dadac97.kamezawa.hiroyu@jp.fujitsu.com>
	<20090515084716.544930d9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 15 May 2009 08:47:16 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 13 May 2009 09:31:27 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 12 May 2009 15:21:58 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > > The patch set includes followng
> > > >  [1/3] add mem_cgroup_is_activated() function. which tell us memcg is _really_ used.
> > > >  [2/3] fix swap cache handling race by avoidng readahead.
> > > >  [3/3] fix swap cache handling race by check swapcount again.
> > > > 
> > > > Result is good under my test.
> > > 
> > > What was the result (performance data impact) of disabling swap
> > > readahead? Otherwise, this looks the most reasonable set of patches
> > > for this problem.
> > > 
> > I'll measure some and report it in the next post.
> > 
> I confirmed there are cases which swapin readahead works very well....
> 
> Nishimura-san, could you post a patch for fixing leak at writeback ? as [3/3]
> I'd like to fix readahead case...with some large patch.
> 
Sure.
I'll rebase my patch onto [1-2/3] of your new patch and post it.

> Hm, I didn't think this problem took 2 months to be fixed ;(
> 
I didn't think so either.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
