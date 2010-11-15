Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 54D5B8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 05:59:00 -0500 (EST)
Date: Mon, 15 Nov 2010 10:57:35 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Revert oom rewrite series
Message-ID: <20101115105735.0f9c1a22@lxorguk.ukuu.org.uk>
In-Reply-To: <alpine.DEB.2.00.1011150204060.2986@chino.kir.corp.google.com>
References: <1289402093.10699.25.camel@localhost.localdomain>
	<1289402666.10699.28.camel@localhost.localdomain>
	<20101114141913.E019.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1011141330120.22262@chino.kir.corp.google.com>
	<4CE0A87E.1030304@leadcoretech.com>
	<alpine.DEB.2.00.1011150204060.2986@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: "Figo.zhang" <zhangtianfei@leadcoretech.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> The goal was to make the oom killer heuristic as predictable as possible 
> and to kill the most memory-hogging task to avoid having to recall it and 
> needlessly kill several tasks.

Meta question - why is that a good thing. In a desktop environment it's
frequently wrong, in a server environment it is often wrong. We had this
before where people spend months fiddling with the vm and make it work
slightly differently and it suits their workload, then other workloads go
downhill. Then the cycle repeats.

> You have full control over disabling a task from being considered with 
> oom_score_adj just like you did with oom_adj.  Since oom_adj is 
> deprecated for two years, you can even use the old interface until then.

Which changeset added it to the Documentation directory as deprecated ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
