Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 76AFC6B0047
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 22:44:12 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o882i8OV013787
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Sep 2010 11:44:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 53B2545DE57
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 29CB645DE52
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F35341DB8046
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:07 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A9C4C1DB8038
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 2/2] oom: use old_mm for oom_disable_count in exec
In-Reply-To: <alpine.DEB.2.00.1009011748190.22920@chino.kir.corp.google.com>
References: <20100902092039.D05C.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009011748190.22920@chino.kir.corp.google.com>
Message-Id: <20100907102532.C8EC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed,  8 Sep 2010 11:44:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Looks good. However you need to use tsk->signal->oom_adj == OOM_DISABLE because
> > I removed OOM_SCORE_ADJ_MIN.
> > 
> 
> KOSAKI, I'm not going to argue this with you.  VM patches, like where you 
> revert oom_score_adj, go through Andrew.  That's not up for debate.
> 
> Thanks for the review.


Don't mind. but general warning: If you continue to crappy objection, We
are going to revert full of your userland breakage entirely instead minimum fix. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
