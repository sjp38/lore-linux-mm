Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DEA2E6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:32:05 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAI8W2aY018200
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Nov 2010 17:32:03 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 76EB33A62C2
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 17:32:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 537B91EF081
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 17:32:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 344581DB8019
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 17:32:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D609A1DB8014
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 17:32:01 +0900 (JST)
Date: Thu, 18 Nov 2010 17:26:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/8] Use memory compaction instead of lumpy reclaim
 during high-order allocations
Message-Id: <20101118172627.cf25b83a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101118081254.GB8135@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
	<20101117154641.51fd7ce5.akpm@linux-foundation.org>
	<20101118081254.GB8135@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010 08:12:54 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> > > I'm hoping that this series also removes the
> > > necessity for the "delete lumpy reclaim" patch from the THP tree.
> > 
> > Now I'm sad.  I read all that and was thinking "oh goody, we get to
> > delete something for once".  But no :(
> > 
> > If you can get this stuff to work nicely, why can't we remove lumpy
> > reclaim?
> 
> Ultimately we should be able to. Lumpy reclaim is still there for the
> !CONFIG_COMPACTION case and to have an option if we find that compaction
> behaves badly for some reason.
> 

Hmm. CONFIG_COMPACTION depends on CONFIG_MMU. lumpy reclaim will be for NOMMU,
finally ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
