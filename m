Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 853676B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 00:18:11 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n614Igs0024196
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Jul 2009 13:18:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 26C5E45DE53
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:18:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D300745DE4E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:18:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B1196E08004
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:18:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 522631DB803F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:18:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Found the commit that causes the OOMs
In-Reply-To: <20090701040649.GA12832@localhost>
References: <4A4AD07E.2040508@redhat.com> <20090701040649.GA12832@localhost>
Message-Id: <20090701131734.85D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Jul 2009 13:18:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jun 30, 2009 at 10:57:02PM -0400, Rik van Riel wrote:
> > KOSAKI Motohiro wrote:
> >
> >>> [ 1522.019259] Active_anon:11 active_file:6 inactive_anon:0
> >>> [ 1522.019260]  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
> >>> [ 1522.019261]  free:1985 slab:44399 mapped:132 pagetables:61830 bounce:0
> >>> [ 1522.019262]  isolate:69817
> >>
> >> OK. thanks.
> >> I plan to submit this patch after small more tests. it is useful for OOM analysis.
> >
> > It is also useful for throttling page reclaim.
> >
> > If more than half of the inactive pages in a zone are
> > isolated, we are probably beyond the point where adding
> > additional reclaim processes will do more harm than good.
> 
> There are probably more problems in this case. For example,
> followed is the vmstat after first (successful) run of msgctl11.
> 
> The question is: Why kswapd reclaims are absent here?

if direct reclaim isolate all pages, kswapd can't reclaim any pages.

I believe Rik's idea solve this problem.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
