Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 07CA36B00AB
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 07:26:06 -0500 (EST)
Date: Tue, 9 Nov 2010 12:24:37 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
Message-ID: <20101109122437.2e0d71fd@lxorguk.ukuu.org.uk>
In-Reply-To: <20101109195726.BC9E.A69D9226@jp.fujitsu.com>
References: <1288834737.2124.11.camel@myhost>
	<alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com>
	<20101109195726.BC9E.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: David Rientjes <rientjes@google.com>, figo zhang <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> > > process with CAP_SYS_RESOURCE capibility which have system resource
> > > limits, like journaling resource on ext3/4 filesystem, RTC clock. so it
> > > also the same treatment as process with CAP_SYS_ADMIN.
> > > 
> > 
> > NACK, there's no justification that these tasks should be given a 3% 
> > memory bonus in the oom killer heuristic; in fact, since they can allocate 
> > without limits it is more important to target these tasks if they are 
> > using an egregious amount of memory.
> 
> David, Stupid are YOU. you removed CAP_SYS_RESOURCE condition with ZERO
> explanation and Figo reported a regression. That's enough the reason to
> undo. YOU have a guilty to explain why do you want to change and why
> do you think it has justification.
> 
> Don't blame bug reporter. That's completely wrong.

Can people stop throwing things at each other and worry about the facts

- If it's a regression it should get reverted or fixed. But is it
  actually a regression ? Has the underlying behaviour changed in a
  problematic way?

"CAP_SYS_RESOURCE threads have the ability to lower their own oom_score_adj
 values, thus, they should protect themselves if necessary like
 everything else."

The reverse can be argued equally - that they can unprotect themselves if
necessary. In fact it seems to be a "point of view" sort of question
which way you deal with CAP_SYS_RESOURCE, and that to me argues that
changing from old expected behaviour to a new behaviour is a regression.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
