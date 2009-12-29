Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1607F60021B
	for <linux-mm@kvack.org>; Tue, 29 Dec 2009 09:09:24 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBTE7YFY022916
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 01:07:34 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBTE54nb860326
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 01:05:05 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBTE9JIi020343
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 01:09:19 +1100
Date: Tue, 29 Dec 2009 19:38:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] vmstat: add anon_scan_ratio field to zoneinfo
Message-ID: <20091229140825.GQ3601@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091228164451.A687.A69D9226@jp.fujitsu.com>
 <20091228164816.A68D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091228164816.A68D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-12-28 16:48:51]:

> Vmscan folks was asked "why does my system makes so much swap-out?"
> in lkml at several times.
> At that time, I made the debug patch to show recent_anon_{scanned/rorated}
> parameter at least three times.
> 
> Thus, its parameter should be showed on /proc/zoneinfo. It help
> vmscan folks debugging.
>

Hmmm.. I think this should come under DEBUG_VM, a lot of tools use
/proc/zoneinfo, the additional overhead may be high.. no? Also,
I would recommend adding the additional details to the end, so
as to not break existing tools (specifically dump line # based
tools).
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
