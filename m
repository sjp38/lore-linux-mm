Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m8PEpc2X019097
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Sep 2008 23:51:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EE1F2AC027
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 23:51:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6774A12C049
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 23:51:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 500C21DB8038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 23:51:38 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D6551DB8037
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 23:51:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] Report the pagesize backing a VMA in /proc/pid/smaps
In-Reply-To: <1222202736-13311-2-git-send-email-mel@csn.ul.ie>
References: <1222202736-13311-1-git-send-email-mel@csn.ul.ie> <1222202736-13311-2-git-send-email-mel@csn.ul.ie>
Message-Id: <20080925234913.58AE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Sep 2008 23:51:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> It is useful to verify a hugepage-aware application is using the expected
> pagesizes for its memory regions. This patch creates an entry called
> KernelPageSize in /proc/pid/smaps that is the size of page used by the kernel
> to back a VMA. The entry is not called PageSize as it is possible the MMU
> uses a different size. This extension should not break any sensible parser
> that skips lines containing unrecognised information.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

looks good to me.
and, I tested this patch on x86_64 mmotm 0923 and it works well.


Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
