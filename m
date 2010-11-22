Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8E42D6B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 20:37:12 -0500 (EST)
Date: Mon, 22 Nov 2010 09:36:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] vmscan: Make move_active_pages_to_lru more generic
Message-ID: <20101122013655.GA10126@localhost>
References: <1290349496-13297-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290349496-13297-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 21, 2010 at 10:24:56PM +0800, Minchan Kim wrote:
> Now move_active_pages_to_lru can move pages into active or inactive.
> if it moves the pages into inactive, it itself can clear PG_acive.
> It makes the function more generic.

Do you plan to use this "more generic" function? Because the patch in
itself makes code slightly less efficient. It adds one "if" test, and
moves one operation into the spin lock.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
