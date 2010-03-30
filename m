Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 964376B01FA
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 02:09:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U68sOp022110
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Mar 2010 15:08:54 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 71C2845DE4F
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:08:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D31E45DE53
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:08:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 210DF1DB803A
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:08:54 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE0441DB8044
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:08:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100330055304.GA2983@sli10-desk.sh.intel.com>
References: <20100330055304.GA2983@sli10-desk.sh.intel.com>
Message-Id: <20100330150453.8E9F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Mar 2010 15:08:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

Hi

> Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> With it, our tmpfs test always oom. The test has a lot of rotated anon
> pages and cause percent[0] zero. Actually the percent[0] is a very small
> value, but our calculation round it to zero. The commit makes vmscan
> completely skip anon pages and cause oops.
> An option is if percent[x] is zero in get_scan_ratio(), forces it
> to 1. See below patch.
> But the offending commit still changes behavior. Without the commit, we scan
> all pages if priority is zero, below patch doesn't fix this. Don't know if
> It's required to fix this too.

Can you please post your /proc/meminfo and reproduce program? I'll digg it.

Very unfortunately, this patch isn't acceptable. In past time, vmscan 
had similar logic, but 1% swap-out made lots bug reports. 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
