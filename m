Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C90D76B0044
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:24:19 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id nAQ1O28x013224
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 12:24:02 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAPEKUcf1425652
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 01:20:30 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAPEO16Q029473
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 01:24:01 +1100
Date: Wed, 25 Nov 2009 19:53:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/9] ksm: mem cgroup charge swapin copy
Message-ID: <20091125142355.GD2970@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
 <Pine.LNX.4.64.0911241648520.25288@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0911241648520.25288@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh.dickins@tiscali.co.uk> [2009-11-24 16:51:13]:

> But ksm swapping does require one small change in mem cgroup handling.
> When do_swap_page()'s call to ksm_might_need_to_copy() does indeed
> substitute a duplicate page to accommodate a different anon_vma (or a
> different index), that page escaped mem cgroup accounting, because of
> the !PageSwapCache check in mem_cgroup_try_charge_swapin().
> 

The duplicate page doesn't show up as PageSwapCache or are we optimizing
for the race condition where the page is not in SwapCache? I should
probably look at the full series.

> That was returning success without charging, on the assumption that
> pte_same() would fail after, which is not the case here.  Originally I
> proposed that success, so that an unshrinkable mem cgroup at its limit
> would not fail unnecessarily; but that's a minor point, and there are
> plenty of other places where we may fail an overallocation which might
> later prove unnecessary.  So just go ahead and do what all the other
> exceptions do: proceed to charge current mm.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>


Thanks for the patch!
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
