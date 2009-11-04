Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EC7BE6B0062
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 18:25:32 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA4NPUVs006186
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Nov 2009 08:25:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 061EA45DE4E
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 08:25:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D7A5D45DE5D
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 08:25:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4F5F1DB8038
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 08:25:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 627021DB803C
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 08:25:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] show per-process swap usage via procfs
In-Reply-To: <alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1>
Message-Id: <20091105082357.54D3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Nov 2009 08:25:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> On Wed, 4 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Now, anon_rss and file_rss is counted as RSS and exported via /proc.
> > RSS usage is important information but one more information which
> > is often asked by users is "usage of swap".(user support team said.)
> 
> Hmmm... Could we do some rework of the counters first so that they are per
> cpu?

per-cpu swap counter?
It seems overkill effort....



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
