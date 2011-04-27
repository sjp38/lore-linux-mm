Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 748E39000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:18:39 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8D58D3EE0C2
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:18:35 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 73A1C45DE97
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:18:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A6F845DE77
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:18:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4885DE18002
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:18:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 11DC1E08003
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:18:35 +0900 (JST)
Date: Wed, 27 Apr 2011 17:11:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 4/8] Make clear description of putback_lru_page
Message-Id: <20110427171157.3751528f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <bb2acc3882594cf54689d9e29c61077ff581c533.1303833417.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<bb2acc3882594cf54689d9e29c61077ff581c533.1303833417.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 27 Apr 2011 01:25:21 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Commonly, putback_lru_page is used with isolated_lru_page.
> The isolated_lru_page picks the page in middle of LRU and
> putback_lru_page insert the lru in head of LRU.
> It means it could make LRU churning so we have to be very careful.
> Let's clear description of putback_lru_page.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

seems good...
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But is there consensus which side of LRU is tail? head?
I always need to revisit codes when I see a word head/tail....


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
