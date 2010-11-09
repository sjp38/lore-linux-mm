Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6E2986B00D5
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 06:01:38 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA9B1aiU018828
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 20:01:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9217F45DE53
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:01:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 44CF645DE51
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:01:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D1881DB8043
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:01:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D9FC11DB8049
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:01:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
In-Reply-To: <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com>
References: <1288834737.2124.11.camel@myhost> <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com>
Message-Id: <20101109195726.BC9E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 20:01:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Figo.zhang" <zhangtianfei@leadcoretech.com>, figo zhang <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 4 Nov 2010, Figo.zhang wrote:
> 
> > > > CAP_SYS_RESOURCE also had better get 3% bonus for protection.
> > > >
> > > 
> > > 
> > > Would you like to elaborate as to why?
> > > 
> > > 
> > 
> > process with CAP_SYS_RESOURCE capibility which have system resource
> > limits, like journaling resource on ext3/4 filesystem, RTC clock. so it
> > also the same treatment as process with CAP_SYS_ADMIN.
> > 
> 
> NACK, there's no justification that these tasks should be given a 3% 
> memory bonus in the oom killer heuristic; in fact, since they can allocate 
> without limits it is more important to target these tasks if they are 
> using an egregious amount of memory.  CAP_SYS_RESOURCE threads have the 
> ability to lower their own oom_score_adj values, thus, they should protect 
> themselves if necessary like everything else.

David, Stupid are YOU. you removed CAP_SYS_RESOURCE condition with ZERO
explanation and Figo reported a regression. That's enough the reason to
undo. YOU have a guilty to explain why do you want to change and why
do you think it has justification.

Don't blame bug reporter. That's completely wrong.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
