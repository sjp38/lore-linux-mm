Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0DD8A6001DA
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 03:55:24 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1N8tLT6028227
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Feb 2010 17:55:21 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DACDE45DE50
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:55:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B206945DE4D
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:55:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 81EDAE38006
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:55:20 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 37B631DB8037
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:55:20 +0900 (JST)
Date: Tue, 23 Feb 2010 17:51:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 36/36] khugepaged
Message-Id: <20100223175126.784aac5e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100223165807.ade20de6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100221141009.581909647@redhat.com>
	<20100221141758.658303189@redhat.com>
	<20100223165807.ade20de6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: aarcange@redhat.com, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 16:58:07 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Sun, 21 Feb 2010 15:10:45 +0100

> > +	spin_lock(ptl);
> > +	isolated = __collapse_huge_page_isolate(vma, address, pte);
> > +	spin_unlock(ptl);
> 
> Is it safe to take zone->lock under pte_lock and anon_vma->lock ?
> 
> I think usual way is
> 	page = follow_page(FOLL_GET)
> 	isolate_page(page)
> 

I'm sorry it was written in rmap.c as
 *       mapping->i_mmap_lock
 *         anon_vma->lock
 *           mm->page_table_lock or pte_lock
 *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
