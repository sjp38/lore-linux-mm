Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 543ED900001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 03:27:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E062D3EE0AE
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:27:28 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C842245DE93
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:27:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B19B945DE77
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:27:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A372EE08001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:27:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F0761DB8037
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:27:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 2/8] compaction: make isolate_lru_page with filter aware
In-Reply-To: <BANLkTina+YuDgACZfDV8T_Lnipo50J6zVA@mail.gmail.com>
References: <20110428084820.GH12437@cmpxchg.org> <BANLkTina+YuDgACZfDV8T_Lnipo50J6zVA@mail.gmail.com>
Message-Id: <20110501162857.75DC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Sun,  1 May 2011 16:27:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

> > With the suggested flags argument from 1/8, this would look like:
> >
> > A  A  A  A flags = ISOLATE_BOTH;
> > A  A  A  A if (!cc->sync)
> > A  A  A  A  A  A  A  A flags |= ISOLATE_CLEAN;
> >
> > ?
> 
> Yes. I will change it.
> 
> >
> > Anyway, nice change indeed!
> 
> Thanks!

Yeah. That's very nice.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
