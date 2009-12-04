Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F0EEB6007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 03:26:54 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB48Qqcp019426
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 17:26:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 10B6745DE51
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:26:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E389745DE50
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:26:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C937C1DB803C
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:26:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C37F1DB8038
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:26:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmscan: more simplify shrink_inactive_list()
In-Reply-To: <20091127091357.A7CC.A69D9226@jp.fujitsu.com>
References: <20091127091357.A7CC.A69D9226@jp.fujitsu.com>
Message-Id: <20091204172429.5889.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  4 Dec 2009 17:26:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> This patch depend on "vmscan : simplify code" patch (written by Huang Shijie)
> 
> =========================================
> Now, max_scan of shrink_inactive_list() is always passed less than
> SWAP_CLUSTER_MAX. then, we can remove scanning pages loop in it.
> 
> detail
>  - remove "while (nr_scanned < max_scan)" loop
>  - remove nr_freed variable (now, we use nr_reclaimed directly)
>  - remove nr_scan variable (now, we use nr_scanned directly)
>  - rename max_scan to nr_to_scan
>  - pass nr_to_scan into isolate_pages() directly instead
>    using SWAP_CLUSTER_MAX

Andrew, please don't pick up this patch series awhile. I and some vmscan
folks are working on fixing Larry's AIM7 problem. it is important than this
and it might makes conflict against this.

I'll rebase this patch series awhile after.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
