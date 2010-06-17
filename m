Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DF3456B01B0
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:40 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1pcOg029627
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:38 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 269A945DE51
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0326E45DE4E
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DE7EFE08004
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C77F1DB803A
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] oom: rename badness() to oom_badness()
In-Reply-To: <alpine.DEB.2.00.1006161440360.11089@chino.kir.corp.google.com>
References: <20100616202920.72DA.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006161440360.11089@chino.kir.corp.google.com>
Message-Id: <20100617085336.FB48.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, 16 Jun 2010, KOSAKI Motohiro wrote:
> 
> > 
> > badness() is wrong name because it's too generic name. rename it.
> > 
> 
> This is already done in my badness heuristic rewrite, can we please focus 
> on its review?

Please resend that as individual patches. 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
