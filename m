Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BB92F6B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 02:44:10 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB87i87u016642
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Dec 2010 16:44:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 450B445DE81
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:43:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D19C45DE74
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:43:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0960BE08006
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:43:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C262D1DB803C
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:43:37 +0900 (JST)
Date: Wed, 8 Dec 2010 16:37:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101208163726.53ab7c34.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101208162257.1748.A69D9226@jp.fujitsu.com>
References: <1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101207123308.GD5422@csn.ul.ie>
	<20101208162257.1748.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Ying Han <yinghan@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  8 Dec 2010 16:22:30 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > +struct kswapd {
> > > +	struct task_struct *kswapd_task;
> > > +	wait_queue_head_t kswapd_wait;
> > > +	struct mem_cgroup *kswapd_mem;
> > > +	pg_data_t *kswapd_pgdat;
> > > +};
> > > +
> > > +#define MAX_KSWAPDS MAX_NUMNODES
> > > +extern struct kswapd kswapds[MAX_KSWAPDS];
> > 
> > This is potentially very large for a static structure. Can they not be
> > dynamically allocated and kept on a list? Yes, there will be a list walk
> > involved if yonu need a particular structure but that looks like it's a
> > rare operation at this point.
> 
> Why can't we use normal workqueue mechanism?
> 
Sounds much simpler than self management of threads.

My only concern is cpu-time-stealing by background works but ....

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
