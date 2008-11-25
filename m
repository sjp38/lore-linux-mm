Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAP45mJ8017910
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 25 Nov 2008 13:05:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5B6645DD82
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:05:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0F5A45DD7C
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:05:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 860F71DB803B
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:05:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 082E61DB8040
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:05:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH/RFC] - support inheritance of mlocks across fork/exec
In-Reply-To: <1227561707.6937.61.camel@lts-notebook>
References: <1227561707.6937.61.camel@lts-notebook>
Message-Id: <20081125130424.26CB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 25 Nov 2008 13:05:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

> PATCH/RFC - support inheritance of mlocks across fork/exec
> 
> Against;  2.6.28-rc5-mmotm-081121
> 
> Add support for mlockall(MCL_INHERIT|MCL_RECURSIVE):
> 	MCL_CURRENT|MCL_INHERIT - inherit memory locks across fork()
> 	MCL_FUTURE|MCL_INHERIT - inherit "MCL_FUTURE" semantics across
> 	fork() and exec().
> 	MCL_RECURSIVE - inherit across future generations.
> 
> In support of a "lock prefix command"--e.g., mlock <cmd> <args> ...

I don't review yet, but I believe this patch is useful for mlock related kernel test.

I plan to review it tommorow.
thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
