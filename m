Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A707C6B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 19:37:55 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n89NbtVM005909
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Sep 2009 08:37:55 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C6D145DE54
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:37:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BDC245DE53
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:37:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BBBA1DB805D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:37:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C6CD31DB8038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:37:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
In-Reply-To: <20090909163212.11464d64.akpm@linux-foundation.org>
References: <20090910081020.9CAE.A69D9226@jp.fujitsu.com> <20090909163212.11464d64.akpm@linux-foundation.org>
Message-Id: <20090910083727.9CBA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Sep 2009 08:37:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, hugh@veritas.com, jpirko@redhat.com, linux-kernel@vger.kernel.org, oleg@redhat.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

> On Thu, 10 Sep 2009 08:17:27 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > 
> > > The changelog had lots of ^------- lines in it.  But those are
> > > conventionally the end-of-changelog separator so I rewrote them to
> > > ^=======
> > 
> > sorry, I have stupid question.
> > I thought "--" and "---" have special meaning. but other length "-" are safe.
> > Is this incorrect?
> > 
> > or You mean it's easy confusing bad style?
> 
> Ideally, ^---$ is the only pattern we need to worry about.
> 
> In the real world, ^-------- might trigger people's sloppy scripts so
> it's best to be safe and avoid it altogether.

Ah I see.
Thank you! 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
