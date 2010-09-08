Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 76B5C6B0047
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 22:44:13 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o882i9cK029580
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Sep 2010 11:44:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7284945DE4D
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 45B1B45DE50
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 20E6F1DB8037
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C50C41DB803B
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX for 2.6.36][RESEND][PATCH 1/2] oom: remove totalpage normalization from oom_badness()
In-Reply-To: <20100831181911.87E7.A69D9226@jp.fujitsu.com>
References: <20100831181911.87E7.A69D9226@jp.fujitsu.com>
Message-Id: <20100907120046.C90A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed,  8 Sep 2010 11:44:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

> ok, this one got no objection except original patch author.
> then, I'll push it to mainline. I'm glad that I who stabilization
> developer have finished this work.
> 
> If you think this patch is slightly large, please run,
>  % git diff a63d83f42^ mm/oom_kill.c
> you'll understand this is minimal revert of unnecessary change.


Andrew, please don't be lazy this one. I don't hope to slip this anymore.
I was making the patch as you requested. but no responce. I who stabilization
developr can't permit this userland breakage and sucky status. please
join to fix it. Sadly, The delay will be increase, I have to switch 
full revert entirely instead your opinion.

Spell out: I don't hope to continus this crazy discussion. a userland 
breakage bug is a bug, not anything else. I don't hope to talk this 
one anymore even though it's only 5 miniture. I don't think any rare
usecase feature should die. but ZERO USER FEATURE SHOULDN'T BREAK USERLAND.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
