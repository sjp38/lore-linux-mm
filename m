Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EDD406B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 22:18:30 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4L2ISGi019430
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 21 May 2010 11:18:28 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D132545DE52
	for <linux-mm@kvack.org>; Fri, 21 May 2010 11:18:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B546145DE4E
	for <linux-mm@kvack.org>; Fri, 21 May 2010 11:18:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A1D181DB8016
	for <linux-mm@kvack.org>; Fri, 21 May 2010 11:18:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DC891DB8013
	for <linux-mm@kvack.org>; Fri, 21 May 2010 11:18:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at first
In-Reply-To: <alpine.DEB.1.00.1005201859260.23122@tigran.mtv.corp.google.com>
References: <20100521103935.1E56.A69D9226@jp.fujitsu.com> <alpine.DEB.1.00.1005201859260.23122@tigran.mtv.corp.google.com>
Message-Id: <20100521111658.1E64.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 21 May 2010 11:18:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 21 May 2010, KOSAKI Motohiro wrote:
> > 
> > > Acked-by: Hugh Dickins <hughd@google.com>
> > > 
> > > Thanks - though I don't quite agree with your description: I can't
> > > see why the lru_cache_add_active_anon() was ever justified - that
> > > "active" came in along with the separate anon and file LRU lists.
> > 
> > If you have any worry, can you please share it? I'll test such workload
> > and fix the issue if necessary. You are expert than me in this area.
> 
> ?? I've acked the patch: my worry is only with the detail of your
> comments on the history - in my view it was always wrong to put on
> the active LRU there, and I'm glad that you have now fixed it.

Oops, I misparsed your text. very sorry. I thought you said opposite ;)

Thanks.


> If you really want to test some workload on 2.6.28 to see if it too
> works better with your fix, I won't stop you - but I'd much prefer
> you to be applying your mind to 2.6.35 and 2.6.36!
> 
> Hugh
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
