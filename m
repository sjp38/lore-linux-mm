Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A587D8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 23:01:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8B06D3EE0C2
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:01:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D43E45DE4D
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:01:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F90845DE5B
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:01:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C694E18005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:01:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBB8DE08004
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:01:24 +0900 (JST)
Date: Tue, 15 Mar 2011 11:54:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-Id: <20110315115451.7a7d3605.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTineM7M1R6fVFJe0ax-DN=_Rnb+7Cmk5HTH0D+Na@mail.gmail.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
	<20110311171006.ec0d9c37.akpm@linux-foundation.org>
	<AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
	<20110315105612.f600a659.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTineM7M1R6fVFJe0ax-DN=_Rnb+7Cmk5HTH0D+Na@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Mon, 14 Mar 2011 19:51:22 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Mon, Mar 14, 2011 at 6:56 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 14 Mar 2011 11:29:17 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> >
> >> On Fri, Mar 11, 2011 at 5:10 PM, Andrew Morton
> The foreign dirtier issue is all about identifying the memcg (or
> possibly multiple bdi) that need balancing.    If the foreign dirtier
> issue is not important then we can focus on identifying inodes to
> writeback that will lower the current's memcg dirty usage.  I am fine
> ignoring the foreign dirtier issue for now and breaking the problem
> into smaller pieces.
> 
ok.

> I think this can be done with out any additional state.  Can just scan
> the memcg lru to find dirty file pages and thus inodes to pass to
> sync_inode(), or some other per-inode writeback routine?
> 

I think it works, finding inodes to be cleaned by LRU scanning.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
