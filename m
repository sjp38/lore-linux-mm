Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CCDA76B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 04:00:27 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8G80POK030340
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Sep 2009 17:00:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E796B45DE4E
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 17:00:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B3C9045DE52
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 17:00:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6649D1DB803F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 17:00:24 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 017ED1DB805B
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 17:00:24 +0900 (JST)
Date: Wed, 16 Sep 2009 16:58:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memcg merge for 2.6.32 (was Re: 2.6.32 -mm merge plans)
Message-Id: <20090916165819.b8843f36.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090916073727.GP4846@balbir.in.ibm.com>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
	<20090916073727.GP4846@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009 13:07:27 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Andrew Morton <akpm@linux-foundation.org> [2009-09-15 16:15:35]:
> 
> > 
> > memcg-remove-the-overhead-associated-with-the-root-cgroup.patch
> > memcg-remove-the-overhead-associated-with-the-root-cgroup-fix.patch
> > memcg-remove-the-overhead-associated-with-the-root-cgroup-fix-2.patch
> > #memcg-add-comments-explaining-memory-barriers.patch: needs update (Balbir)
> > memcg-add-comments-explaining-memory-barriers.patch
> > memcg-add-comments-explaining-memory-barriers-checkpatch-fixes.patch
> > memory-controller-soft-limit-documentation-v9.patch
> > memory-controller-soft-limit-interface-v9.patch
> > memory-controller-soft-limit-organize-cgroups-v9.patch
> > memory-controller-soft-limit-organize-cgroups-v9-fix.patch
> > memory-controller-soft-limit-refactor-reclaim-flags-v9.patch
> > memory-controller-soft-limit-reclaim-on-contention-v9.patch
> > memory-controller-soft-limit-reclaim-on-contention-v9-fix.patch
> > memory-controller-soft-limit-reclaim-on-contention-v9-fix-softlimit-css-refcnt-handling.patch
> > memory-controller-soft-limit-reclaim-on-contention-v9-fix-softlimit-css-refcnt-handling-fix.patch
> > memcg-improve-resource-counter-scalability.patch
> > memcg-improve-resource-counter-scalability-checkpatch-fixes.patch
> > memcg-improve-resource-counter-scalability-v5.patch
> > memcg-show-swap-usage-in-stat-file.patch
> > memcg-show-swap-usage-in-stat-file-fix.patch
> > 
> >   Merge after checking with Balbir
> 
> 
> I think these are ready for merging, I'll let Kame and Daisuke comment
> on it more.

While testing memcg, I feel that only I and Balbir and Nishimura are heavy
testers of memcg in mmotm. Because Nishimura's test is very good, I think
we could get good quality to some extent.
 
Then, I think it's time to move to -rc for getting wider testers.

But Balbir, soft-limit is a difficult thing. plz keep checking.

> The resource counter scalability patch is the most
> important patch in the series.
> 
plz don't call it as resource counter scalability patch ;)
It just skips resoruce_counter, resource_counter itself is still slow.
root-cgroup-memcg-scalability patch is good name.

I'll post other-cgroup-memcg-scalability patch series when it seems ready.
It's what I need but not for 2.6.32.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
