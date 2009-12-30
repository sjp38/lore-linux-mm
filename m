Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6072A60021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 08:13:49 -0500 (EST)
Date: Wed, 30 Dec 2009 22:13:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] vmstat: add anon_scan_ratio field to zoneinfo
In-Reply-To: <20091229140825.GQ3601@balbir.in.ibm.com>
References: <20091228164816.A68D.A69D9226@jp.fujitsu.com> <20091229140825.GQ3601@balbir.in.ibm.com>
Message-Id: <20091230220704.1A16.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-12-28 16:48:51]:
> 
> > Vmscan folks was asked "why does my system makes so much swap-out?"
> > in lkml at several times.
> > At that time, I made the debug patch to show recent_anon_{scanned/rorated}
> > parameter at least three times.
> > 
> > Thus, its parameter should be showed on /proc/zoneinfo. It help
> > vmscan folks debugging.
> >
> 
> Hmmm.. I think this should come under DEBUG_VM, a lot of tools use
> /proc/zoneinfo, the additional overhead may be high.. no? Also,
> I would recommend adding the additional details to the end, so
> as to not break existing tools (specifically dump line # based
> tools).

Thanks, I have three answer. 1)  I really hope to don't enclose DEBUG_VM. otherwise 
my harm doesn't solve. 2) but your performance worry is fair enough. I plan to remove 
to grab zone->lru_lock in reading /proc/zoneinfo. 3)  append new line doesn't break 
existing tools. because zoneinfo show vmstat and we often append new vmstat in past 
years. but I haven't seen zoneinfo breakage bug report. because zoneinfo file show 
multiple zone information, then nobody access it by line number.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
