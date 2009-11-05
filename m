Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 82C966B007B
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 19:09:42 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA509dnW009621
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Nov 2009 09:09:40 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A32C945DE50
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 09:09:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 86E4945DE4C
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 09:09:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CB2B1DB803F
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 09:09:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 25BCE1DB8040
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 09:09:39 +0900 (JST)
Date: Thu, 5 Nov 2009 09:06:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] show per-process swap usage via procfs
Message-Id: <20091105090659.9a5d17b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Nov 2009 14:15:40 -0500 (EST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Wed, 4 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Now, anon_rss and file_rss is counted as RSS and exported via /proc.
> > RSS usage is important information but one more information which
> > is often asked by users is "usage of swap".(user support team said.)
> 
> Hmmm... Could we do some rework of the counters first so that they are per
> cpu?
> 
I don't think swap_usage counter has much costs because it's call path
is always slow path. But, I'm not in hurry. So rework is ok.

I'll post my percpu array counter with some rework, CCing you.
Maybe it can be used in this case.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
