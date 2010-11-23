Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8B68F6B0093
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:17:02 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN7GxCb023822
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 16:17:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EDAA745DE61
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBE7F45DD73
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89752E08001
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BA37E18001
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Revert oom rewrite series
In-Reply-To: <20101115105735.0f9c1a22@lxorguk.ukuu.org.uk>
References: <alpine.DEB.2.00.1011150204060.2986@chino.kir.corp.google.com> <20101115105735.0f9c1a22@lxorguk.ukuu.org.uk>
Message-Id: <20101123160020.7B99.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 16:16:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, "Figo.zhang" <zhangtianfei@leadcoretech.com>, "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


sorry for the delay.

> > The goal was to make the oom killer heuristic as predictable as possible 
> > and to kill the most memory-hogging task to avoid having to recall it and 
> > needlessly kill several tasks.
> 
> Meta question - why is that a good thing. In a desktop environment it's
> frequently wrong, in a server environment it is often wrong. We had this
> before where people spend months fiddling with the vm and make it work
> slightly differently and it suits their workload, then other workloads go
> downhill. Then the cycle repeats.
> 
> > You have full control over disabling a task from being considered with 
> > oom_score_adj just like you did with oom_adj.  Since oom_adj is 
> > deprecated for two years, you can even use the old interface until then.
> 
> Which changeset added it to the Documentation directory as deprecated ?

It's insufficient.
a63d83f427fbce97a6cea0db2e64b0eb8435cd10 (oom: badness heuristic rewrite)
introduced a lot of incompatibility to oom_adj and oom_score.
Theresore I would sugestted full revert and resubmit some patches which
cherry pick no pain piece.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
