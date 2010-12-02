Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9CBBB6B00B6
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 21:51:03 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB22p0A0030863
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Dec 2010 11:51:00 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A1D745DE5C
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 11:51:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 00F8D45DE58
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 11:51:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E72D8E38004
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 11:50:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B271CE08003
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 11:50:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Difference between CommitLimit and Comitted_AS?
In-Reply-To: <585ebcca-1e2f-496b-ad10-84b6f0f3e4fd@blur>
References: <20101202103408.1584.A69D9226@jp.fujitsu.com> <585ebcca-1e2f-496b-ad10-84b6f0f3e4fd@blur>
Message-Id: <20101202115121.158D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Dec 2010 11:50:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Westerdale, John" <John.Westerdale@stryker.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Kosaki, 
> 
> Thanks for your contribution.
> 
> This system is only running 25 pct of projected load, so I am concerned. 
> 
> If we add up physical memory plus swap would that be a comfortable limit for  
> committed_AS?
> 
> Can tomcat  (or whaever webshere uses for servelets) be tuned to allocate a  
> fixed amount per session?  
> 
> as there are other applications on the same server, need to set up good  
> fences.
>  
> can I use ulimits to exercise some rough level of control?

When running Java, address space limitation (committed_AS and ulimit) are useless.
Java runtime consume much much AS rather than physical. So, I would recommend you
use memory cgroup.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
