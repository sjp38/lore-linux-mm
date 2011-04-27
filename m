Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4C5426B0012
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:46:50 -0400 (EDT)
Message-ID: <4DB8AAE3.20806@redhat.com>
Date: Wed, 27 Apr 2011 19:46:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 6/8] In order putback lru core
References: <cover.1303833415.git.minchan.kim@gmail.com> <51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
In-Reply-To: <51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>

On 04/26/2011 12:25 PM, Minchan Kim wrote:

> But this approach has a problem on contiguous pages.
> In this case, my idea can not work since friend pages are isolated, too.
> It means prev_page->next == next_page always is false and both pages are not
> LRU any more at that time. It's pointed out by Rik at LSF/MM summit.
> So for solving the problem, I can change the idea.
> I think we don't need both friend(prev, next) pages relation but
> just consider either prev or next page that it is still same LRU.

> Any comment?

If the friend pages are isolated too, then your condition
"either prev or next page that it is still same LRU" is
likely to be false, no?


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
