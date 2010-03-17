Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 42A6460023A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 07:59:05 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id o2HBwn3O017856
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 22:58:49 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2HBr1sM1507328
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 22:53:01 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2HBwtgS008917
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 22:58:56 +1100
Date: Wed, 17 Mar 2010 17:28:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-ID: <20100317115855.GS18054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <1268609202-15581-2-git-send-email-arighi@develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1268609202-15581-2-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrea Righi <arighi@develer.com> [2010-03-15 00:26:38]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, file-mapped is maintaiend. But more generic update function
> will be needed for dirty page accounting.
> 
> For accountig page status, we have to guarantee lock_page_cgroup()
> will be never called under tree_lock held.
> To guarantee that, we use trylock at updating status.
> By this, we do fuzzy accounting, but in almost all case, it's correct.
>

I don't like this at all, but in almost all cases is not acceptable
for statistics, since decisions will be made on them and having them
incorrect is really bad. Could we do a form of deferred statistics and
fix this.

 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
