Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A188860021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 00:19:23 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB45JKFS006344
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Dec 2009 14:19:20 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 44E5945DE64
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:19:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 197AC45DE55
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:19:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE05E1DB803A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:19:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FE50E78001
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:19:19 +0900 (JST)
Date: Fri, 4 Dec 2009 14:16:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-Id: <20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091204135938.5886.A69D9226@jp.fujitsu.com>
References: <20091202125501.GD28697@random.random>
	<20091203134610.586E.A69D9226@jp.fujitsu.com>
	<20091204135938.5886.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  4 Dec 2009 14:06:07 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > Umm?? Personally I don't like knob. If you have problematic workload,
> > please tell it us. I will try to make reproduce environment on my box.
> > If current code doesn't works on KVM or something-else, I really want
> > to fix it.
> > 
> > I think Larry's trylock idea and your 64 young bit idea can be combinate.
> > I only oppose the page move to inactive list without clear young bit. IOW,
> > if VM pressure is very low and the page have lots young bit, the page should
> > go back active list although trylock(ptelock) isn't contended.
> > 
> > But unfortunatelly I don't have problem workload as you mentioned. Anyway
> > we need evaluate way to your idea. We obviouslly more info.
> 
> [Off topic start]
> 
> Windows kernel have zero page thread and it clear the pages in free list
> periodically. because many windows subsystem prerefer zero filled page.
> hen, if we use windows guest, zero filled page have plenty mapcount rather
> than other typical sharing pages, I guess.
> 
> So, can we mark as unevictable to zero filled ksm page? 
> 

Hmm, can't we use ZERO_PAGE we have now ?
If do so,
 - no mapcount check
 - never on LRU
 - don't have to maintain shared information because ZERO_PAGE itself has
   copy-on-write nature.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
