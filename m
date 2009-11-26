Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 177466B009D
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 20:35:26 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAQ1ZNqu011594
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Nov 2009 10:35:23 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E34E045DE52
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:35:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BF89545DE4F
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:35:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A0A441DB8040
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:35:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A6961DB803C
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:35:22 +0900 (JST)
Date: Thu, 26 Nov 2009 10:32:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
Message-Id: <20091126103234.806a4982.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B0DC764.8040205@gmail.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>
	<abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
	<20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>
	<20091125124433.GB27615@random.random>
	<4B0DC764.8040205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Nov 2009 01:10:12 +0100
Vedran FuraA? <vedran.furac@gmail.com> wrote:

> Andrea Arcangeli wrote:
> 
> > Hello,
> 
> Hi all!
> 
> > lengthy discussion on something I think is quite obviously better and
> > I tried to change a couple of years back already (rss instead of
> > total_vm).
> 
> Now that 2.6.32 is almost out, is it possible to get OOMK fixed in
> 2.6.33 so that I could turn overcommit on (overcommit_memory=0) again
> without fear of loosing my work?
> 
I'll try fork-bomb detector again. That will finally help your X.org.
But It may lose 2.6.33.

Adding new counter to mm_struct is now rejected because of scalability, so
total work will need more time (than expected).
I'm sorry I can't get enough time in these weeks.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
