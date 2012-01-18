Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 47E456B004D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 19:19:44 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C25593EE0BC
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:19:42 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A027F45DEF1
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:19:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 82DE045DEEC
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:19:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 74A971DB803C
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:19:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2898A1DB803F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:19:42 +0900 (JST)
Date: Wed, 18 Jan 2012 09:18:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 2/3] vmscan hook
Message-Id: <20120118091824.0bde46f7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120117230801.GA903@barrios-desktop.redhat.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-3-git-send-email-minchan@kernel.org>
	<20120117173932.1c058ba4.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117091356.GA29736@barrios-desktop.redhat.com>
	<20120117190512.047d3a03.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117230801.GA903@barrios-desktop.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, penberg@kernel.org, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>

On Wed, 18 Jan 2012 08:08:01 +0900
Minchan Kim <minchan@kernel.org> wrote:

> > 
> > 
> > > > 2. can't we measure page-in/page-out distance by recording something ?
> > > 
> > > I can't understand your point. What's relation does it with swapout prevent?
> > > 
> > 
> > If distance between pageout -> pagein is short, it means thrashing.
> > For example, recoding the timestamp when the page(mapping, index) was
> > paged-out, and check it at page-in.
> 
> Our goal is prevent swapout. When we found thrashing, it's too late.
> 

If you want to prevent swap-out, don't swapon any. That's all.
Then, you can check the number of FILE_CACHE and have threshold.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
