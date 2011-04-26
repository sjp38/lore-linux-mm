Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 834D1900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:51:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A451A3EE0BC
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:51:07 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 89FCF45DE92
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:51:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 71B8545DE91
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:51:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 65C1B1DB8038
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:51:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 313C01DB8037
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 14:51:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] use oom_killer_disabled in page fault oom path
In-Reply-To: <20110426053150.GA11949@darkstar>
References: <20110426053150.GA11949@darkstar>
Message-Id: <20110426145320.F387.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Apr 2011 14:51:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com

> Currently oom_killer_disabled is only used in __alloc_pages_slowpath,
> For page fault oom case it is not considered. One use case is
> virtio balloon driver, when memory pressure is high, virtio ballooning
> will cause oom killing due to such as page fault oom.
> 
> Thus add oom_killer_disabled checking in pagefault_out_of_memory.
> 
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>

Thank you.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
