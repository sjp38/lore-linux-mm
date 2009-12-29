Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 77CFF60021B
	for <linux-mm@kvack.org>; Tue, 29 Dec 2009 09:10:55 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBTEAoXL013974
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 01:10:50 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBTE6ZW81650722
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 01:06:35 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBTEAoEJ008817
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 01:10:50 +1100
Date: Tue, 29 Dec 2009 19:39:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] memcg: add anon_scan_ratio to memory.stat file
Message-ID: <20091229140957.GR3601@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091228164451.A687.A69D9226@jp.fujitsu.com>
 <20091228164857.A690.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091228164857.A690.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-12-28 16:49:27]:

> anon_scan_ratio feature doesn't only useful for global VM pressure
> analysis, but it also useful for memcg memroy pressure analysis.
> 
> Then, this patch add anon_scan_ratio field to memory.stat file too.
> 
> Instead, following debug statistics was removed. It isn't so user and/or
> developer friendly.
> 
> 	- recent_rotated_anon
> 	- recent_rotated_file
> 	- recent_scanned_anon
> 	- recent_scanned_file
>

I've been using these to look at statistics - specifically reclaim
data on my developer kernels.
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
