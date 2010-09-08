Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4A2986B007D
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 22:44:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o882iBSV002192
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Sep 2010 11:44:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AD65045DE55
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BC2C45DE51
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 76E5F1DB803B
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:11 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 339301DB8038
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 11:44:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX for 2.6.36][RESEND][PATCH 1/2] oom: remove totalpage normalization from oom_badness()
In-Reply-To: <alpine.DEB.2.00.1009011508440.29305@chino.kir.corp.google.com>
References: <20100831181911.87E7.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009011508440.29305@chino.kir.corp.google.com>
Message-Id: <20100907114223.C907.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed,  8 Sep 2010 11:44:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 31 Aug 2010, KOSAKI Motohiro wrote:
> 
> > ok, this one got no objection except original patch author.
> 
> Would you care to respond to my objections?
> 
> I replied to these two patches earlier with my nack, here they are:
> 
> 	http://marc.info/?l=linux-mm&m=128273555323993
> 	http://marc.info/?l=linux-mm&m=128337879310476
> 
> Please carry on a useful debate of the issues rather than continually 
> resending patches and labeling them as bugfixes, which they aren't.

You are still talking about only your usecase. Why do we care you? Why?
Why don't you fix the code by yourself? Why? Why do you continue selfish
development? Why? I can't understand.



> > then, I'll push it to mainline. I'm glad that I who stabilization
> > developer have finished this work.
> > 
> 
> You're not the maintainer of this code, patches go through Andrew.
> 
> That said, I'm really tired of you trying to make this personal with me; 
> I've been very respectful and accomodating during this discussion and I 
> hope that you will be the same.

As I said, You only need to don't break userland and fix the code immediately.
You don't have to expect stabilization developer allow userland and code
breakage.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
