Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B84606B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 21:31:27 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA52VPXq005764
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Nov 2009 11:31:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 008F22AF1A1
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 11:31:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4E911EF093
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 11:31:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 75F0C1DB803A
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 11:31:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A549EE38003
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 11:31:20 +0900 (JST)
Date: Thu, 5 Nov 2009 11:28:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] show per-process swap usage via procfs
Message-Id: <20091105112844.b57e02f6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091105082357.54D3.A69D9226@jp.fujitsu.com>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1>
	<20091105082357.54D3.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu,  5 Nov 2009 08:25:28 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Wed, 4 Nov 2009, KAMEZAWA Hiroyuki wrote:
> > 
> > > Now, anon_rss and file_rss is counted as RSS and exported via /proc.
> > > RSS usage is important information but one more information which
> > > is often asked by users is "usage of swap".(user support team said.)
> > 
> > Hmmm... Could we do some rework of the counters first so that they are per
> > cpu?
> 
> per-cpu swap counter?
> It seems overkill effort....
> 
I nearly agree with you.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
