Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 069E66B0088
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 01:39:54 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBA6dqqT021209
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Dec 2010 15:39:52 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F55345DE63
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 15:39:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 137C245DE60
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 15:39:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F3FAD1DB804C
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 15:39:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B72A8E38006
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 15:39:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] Add per cpuset meminfo
In-Reply-To: <1291949345-13892-1-git-send-email-yinghan@google.com>
References: <1291949345-13892-1-git-send-email-yinghan@google.com>
Message-Id: <20101210153753.C7C1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Dec 2010 15:39:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Paul Menage <menage@google.com>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mel@csn.ul.ie>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Export per cpuset meminfo through cpuset.meminfo file. This is easier than
> user program to aggregate it across each nodes in nodemask.

Now userland folks calculate it by userland tools by using /sys/device/node/meminfo.
So, The description should explain why do you want to avoid userland calculation.
Avoid annoying? Or you've found some corner case?

Also please avoid cut-n-paste code duplication. please try unify with 
other meminfo code.


> 
> Ying Han (2):
>   Add hugetlb_report_nodemask_meminfo()
>   Add per cpuset meminfo
> 
>  include/linux/hugetlb.h |    3 +
>  kernel/cpuset.c         |  118 +++++++++++++++++++++++++++++++++++++++++++++++
>  mm/hugetlb.c            |   21 ++++++++
>  3 files changed, 142 insertions(+), 0 deletions(-)
> 
> -- 
> 1.7.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
