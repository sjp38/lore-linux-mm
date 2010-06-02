Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 392586B01B5
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:54:07 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o52Ds53i021508
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Jun 2010 22:54:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E3D9045DE4F
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:04 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C857645DE4E
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:04 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B37FE1DB8014
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A6951DB8013
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1006011140110.32024@chino.kir.corp.google.com>
References: <20100601163627.245D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011140110.32024@chino.kir.corp.google.com>
Message-Id: <20100602225252.F536.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed,  2 Jun 2010 22:54:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Why?
> 
> If it's because the patch is too big, I've explained a few times that 
> functionally you can't break it apart into anything meaningful.  I do not 
> believe it is better to break functional changes into smaller patches that 
> simply change function signatures to pass additional arguments that are 
> unused in the first patch, for example.
> 
> If it's because it adds /proc/pid/oom_score_adj in the same patch, that's 
> allowed since otherwise it would be useless with the old heuristic.  In 
> other words, you cannot apply oom_score_adj's meaning to the bitshift in 
> any sane way.
> 
> I'll suggest what I have multiple times: the easiest way to review the 
> functional change here is to merge the patch into your own tree and then 
> review oom_badness().  I agree that the way the diff comes out it is a 
> little difficult to read just from the patch form, so merging it and 
> reviewing the actual heuristic function is the easiest way.

I've already explained the reason. 1) all-of-rewrite patches are 
always unacceptable. that's prevent our code maintainance. 2) no justification
patches are also unacceptable. you need to write more proper patch descriptaion
at least.

We don't need pointless suggestion. you only need to fix the patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
