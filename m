Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 22F508D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 21:07:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CF00C3EE0AE
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:07:39 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B622445DE61
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:07:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A038E45DD74
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:07:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 93981E18005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:07:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FD361DB8038
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:07:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: skip zombie in OOM-killer
In-Reply-To: <alpine.DEB.2.00.1103061400170.23737@chino.kir.corp.google.com>
References: <20110306193519.49DD.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1103061400170.23737@chino.kir.corp.google.com>
Message-Id: <20110308105458.7EA2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Mar 2011 11:07:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> On Sun, 6 Mar 2011, KOSAKI Motohiro wrote:
> 
> > > When we check that task has flag TIF_MEMDIE, we forgot check that
> > > it has mm. A task may be zombie and a parent may wait a memor.
> > > 
> > > v2: Check that task doesn't have mm one time and skip it immediately
> > > 
> > > Signed-off-by: Andrey Vagin <avagin@openvz.org>
> > 
> > This seems incorrect. Do you have a reprodusable testcasae?
> > Your patch only care thread group leader state, but current code
> > care all thread in the process. Please look at oom_badness() and 
> > find_lock_task_mm(). 
> > 
> 
> That's all irrelevant, the test for TIF_MEMDIE specifically makes the oom 
> killer a complete no-op when an eligible task is found to have been oom 
> killed to prevent needlessly killing additional tasks.  oom_badness() and 
> find_lock_task_mm() have nothing to do with that check to return 
> ERR_PTR(-1UL) from select_bad_process().

I don't understand you think which task is eligible and unnecessary.
But, Look! Andrey is not talking about zombie process case. But, this v2
patch have factored out other tasks too. This IS the problem. No need
unrelated talk.

> 
> Andrey is patching the case where an eligible TIF_MEMDIE process is found 
> but it has already detached its ->mm.  In combination with the patch 
> posted to linux-mm, oom: prevent unnecessary oom kills or kernel panics, 
> which makes select_bad_process() iterate over all threads, it is an 
> effective solution.

Guys, It was alread NAKed. I've already talk kind explanation. Why do
you bother to look actual code. Why do you continue to talk funny your
dream?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
