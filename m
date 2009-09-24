Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B11B6B0082
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:40:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8O0eatV010910
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 24 Sep 2009 09:40:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 398662AEA90
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 09:40:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EAB521EF084
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 09:40:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 995DDE78004
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 09:40:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49FD51DB8042
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 09:40:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: a patch drop request in -mm
In-Reply-To: <20090921152219.GQ12726@csn.ul.ie>
References: <2f11576a0909210800l639560e4jad6cfc2e7f74538f@mail.gmail.com> <20090921152219.GQ12726@csn.ul.ie>
Message-Id: <20090924092903.B648.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 24 Sep 2009 09:40:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Sep 22, 2009 at 12:00:51AM +0900, KOSAKI Motohiro wrote:
> > Mel,
> > 
> > Today, my test found following patch makes false-positive warning.
> > because, truncate can free the pages
> > although the pages are mlock()ed.
> > 
> > So, I think following patch should be dropped.
> > .. or, do you think truncate should clear PG_mlock before free the page?
> 
> Is there a reason that truncate cannot clear PG_mlock before freeing the
> page?

CC to Lee.
IIRC, Lee tried it at first. but after some trouble, he decided change free_hot_cold_page().
but unfortunately, I don't recall the reason ;-)

Lee, Can you recall it?


> > Can I ask your patch intention?
> 
> Locked pages being freed to the page allocator were considered
> unexpected and a counter was in place to determine how often that
> situation occurred. However, I considered it unlikely that the counter
> would be noticed so the warning was put in place to catch what class of
> pages were getting freed locked inappropriately. I think a few anomolies
> have been cleared up since. Ultimately, it should have been safe to
> delete the check.

OK. it seems reasonable. so, I only hope no see linus tree output false-positive warnings.
Thus, I propse 

  - don't merge this patch to linus tree
  - but, no drop from -mm
    it be holded in mm until this issue fixed.
  - I'll working on fixing this issue.

I think this is enough fair.


Hannes, I'm sorry. I haven't review your patch. I'm too busy now. please gime me more
sevaral time.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
