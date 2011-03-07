Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 59BFD8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 02:59:14 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8B1CA3EE0C0
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:59:11 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7177F45DE5F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:59:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F06445DE5A
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:59:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 420891DB804E
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:59:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0230C1DB8048
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:59:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCHv2] procfs: fix /proc/<pid>/maps heap check
In-Reply-To: <1299244994-5284-1-git-send-email-aaro.koskinen@nokia.com>
References: <1299244994-5284-1-git-send-email-aaro.koskinen@nokia.com>
Message-Id: <20110307165145.89FE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Mar 2011 16:59:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, stable@kernel.org

> The current code fails to print the "[heap]" marking if the heap is
> splitted into multiple mappings.
> 
> Fix the check so that the marking is displayed in all possible cases:
> 	1. vma matches exactly the heap
> 	2. the heap vma is merged e.g. with bss
> 	3. the heap vma is splitted e.g. due to locked pages
> 
> Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
> Cc: stable@kernel.org
> ---
> 
> v2: Rewrote the changelog.

Looks good.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
