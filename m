Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DE59E8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:04:48 -0400 (EDT)
Received: by pwi10 with SMTP id 10so27182pwi.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:04:46 -0700 (PDT)
Date: Fri, 25 Mar 2011 00:04:30 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/5] mm: introduce wait_on_page_locked_killable
Message-ID: <20110324150430.GA1938@barrios-desktop>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
 <20110322194721.B05E.A69D9226@jp.fujitsu.com>
 <20110322200904.B06A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322200904.B06A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Mar 22, 2011 at 08:08:41PM +0900, KOSAKI Motohiro wrote:
> commit 2687a356 (Add lock_page_killable) introduced killable
> lock_page(). Similarly this patch introdues killable
> wait_on_page_locked().
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
