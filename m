Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 716A06B02A3
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 23:00:46 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6930gBd011300
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Jul 2010 12:00:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 854DE45DE57
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 12:00:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1845545DE53
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 12:00:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 004671DB8038
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 12:00:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C26331DB805A
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 12:00:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 07/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <20100702153508.fda82eb9.akpm@linux-foundation.org>
References: <20100613201257.6199.A69D9226@jp.fujitsu.com> <20100702153508.fda82eb9.akpm@linux-foundation.org>
Message-Id: <20100705110018.CC9F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  9 Jul 2010 12:00:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Unfortunatelly, I don't have enough time now. then, I expect my next review
> > is not quite soon. but I'll promise I'll do.
> 
> So where do we go from here?  I have about 12,000 oom-killer related
> emails saved up in my todo folder, ready for me to read next time I1
> have an oom-killer session.

At least, all deadlock issue should be fixed. I don't know Michel's problem
is still there. plus I think all desktop related issue also sould be fixed.

but I'm not aggressive to include domain specific OOM tendency. It should
be cared user-land callback and userland daemon. because any usecase specific
change can be considered as regression from another usecase guys.

About David's patch, I dunnno. he didn't explain his patch makes which
change. If he will explained the worth and anybody agree it, it can be
merged. but otherwise.....



> What would happen if I just deleted them all?

Probably, no problem.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
