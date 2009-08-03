Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BFDDE6B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 08:00:34 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n73CJxIb022001
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 3 Aug 2009 21:19:59 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 77F1B45DE62
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:19:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 539DC45DE4F
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:19:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 25A941DB803E
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:19:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF3051DB803F
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:19:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <20090803175557.645b9ca3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090803174519.74673413.kamezawa.hiroyu@jp.fujitsu.com> <20090803175557.645b9ca3.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090803211812.CC29.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  3 Aug 2009 21:19:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 3 Aug 2009 17:45:19 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > "just inherit at fork, change at exec" is an usual manner, I think.
> > If oom_adj_exec rather than oom_adj_child, I won't complain, more.
> > 
> But this/(and yours) requires users to rewrite their apps.
> Then, breaks current API.
> please fight with other guardians.

Definitely, I never agree regressionful ABI change ;)
At least, I still think it can be fixable.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
