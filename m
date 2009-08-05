Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3C90D6B005D
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 23:07:14 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7537ExI031630
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 5 Aug 2009 12:07:14 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F345A45DE4F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 12:07:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BED445DE57
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 12:07:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 805701DB8038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 12:07:06 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A3241DB803C
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 12:07:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing script for page-allocator-related ftrace events
In-Reply-To: <20090804112246.4e6d0ab1.akpm@linux-foundation.org>
References: <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org>
Message-Id: <20090805113207.5B9C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  5 Aug 2009 12:07:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Larry Woodman <lwoodman@redhat.com>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> On Tue,  4 Aug 2009 19:12:26 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > This patch adds a simple post-processing script for the page-allocator-related
> > trace events. It can be used to give an indication of who the most
> > allocator-intensive processes are and how often the zone lock was taken
> > during the tracing period. Example output looks like
> > 
> > find-2840
> >  o pages allocd            = 1877
> >  o pages allocd under lock = 1817
> >  o pages freed directly    = 9
> >  o pcpu refills            = 1078
> >  o migrate fallbacks       = 48
> >    - fragmentation causing = 48
> >      - severe              = 46
> >      - moderate            = 2
> >    - changed migratetype   = 7
> 
> The usual way of accumulating and presenting such measurements is via
> /proc/vmstat.  How do we justify adding a completely new and different
> way of doing something which we already do?

I think this approach have following merit.

 - It can collect per-process information.
   (Of cource, ftrace event filter can filter more various condtion)
 - It can integrate perf-counter easily.
 -




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
