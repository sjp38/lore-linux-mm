Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E41D660021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 19:46:31 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB90kTCk017842
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Dec 2009 09:46:29 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E39DB45DE51
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:46:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C62C945DE4F
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:46:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ACDC4E1800A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:46:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 59F0D1DB803F
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 09:46:25 +0900 (JST)
Date: Wed, 9 Dec 2009 09:43:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-Id: <20091209094331.a1f53e6d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091204171640.GE19624@x200.localdomain>
References: <20091202125501.GD28697@random.random>
	<20091203134610.586E.A69D9226@jp.fujitsu.com>
	<20091204135938.5886.A69D9226@jp.fujitsu.com>
	<20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
	<20091204171640.GE19624@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009 09:16:40 -0800
Chris Wright <chrisw@redhat.com> wrote:

> * KAMEZAWA Hiroyuki (kamezawa.hiroyu@jp.fujitsu.com) wrote:
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > Windows kernel have zero page thread and it clear the pages in free list
> > > periodically. because many windows subsystem prerefer zero filled page.
> > > hen, if we use windows guest, zero filled page have plenty mapcount rather
> > > than other typical sharing pages, I guess.
> > > 
> > > So, can we mark as unevictable to zero filled ksm page? 
> 
> That's why I mentioned the page of zeroes as the prime example of
> something with a high mapcount that shouldn't really ever be evicted.
> 
> > Hmm, can't we use ZERO_PAGE we have now ?
> > If do so,
> >  - no mapcount check
> >  - never on LRU
> >  - don't have to maintain shared information because ZERO_PAGE itself has
> >    copy-on-write nature.
> 
> It's a somewhat special case, but wouldn't it be useful to have a generic
> method to recognize this kind of sharing since it's a generic issue?
> 

I just remembered that why ZERO_PAGE was removed (in past). It was becasue
cache-line ping-pong at fork beacause of page->mapcount. And KSM introduces
zero-pages which have mapcount again. If no problems in realitsitc usage of
KVM, ignore me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
