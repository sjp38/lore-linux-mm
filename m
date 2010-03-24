Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EE45F6B01B4
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 01:26:37 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2O5Qa7c006182
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Mar 2010 14:26:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C38145DE55
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 14:26:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F282445DE54
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 14:26:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D97FD1DB8038
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 14:26:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 968F71DB8043
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 14:26:35 +0900 (JST)
Date: Wed, 24 Mar 2010 14:22:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] [BUGFIX] pagemap: fix pfn calculation for hugepage
Message-Id: <20100324142250.62753e03.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100324051845.GA9017@spritzerA.linux.bs1.fc.nec.co.jp>
References: <1268979996-12297-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20100319161023.d6a4ea8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319162732.58633847.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319171310.7d82f8eb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100324051845.GA9017@spritzerA.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, andi.kleen@intel.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 24 Mar 2010 14:18:45 +0900
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> On Fri, Mar 19, 2010 at 05:13:10PM +0900, KAMEZAWA Hiroyuki wrote:
> ...
> > > 
> > > But, this means hugeltb_entry() is not called per hugetlb entry...isn't it ?
> > > 
> > > Why hugetlb_entry() cannot be called per hugeltb entry ? Don't we need a code
> > > for a case as pmd_size != hugetlb_size in walk_page_range() for generic fix ?
> > > 
> > 
> > How about this style ? This is an idea-level patch. not tested at all.
> > (I have no test enviroment for multiple hugepage size.)
> > 
> > feel free to reuse fragments from this patch.
> >
> 
> So the point is calling hugetlb_entry() for each huge page, right?
> 
yes.

> It looks good.
> I've rewritten my patch based on your idea and make sure it works.
> Is it ok to add your Signed-off-by?
Of course.

Thanks.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
