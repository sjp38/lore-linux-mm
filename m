Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8D6F46B004F
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 11:04:55 -0400 (EDT)
Date: Wed, 29 Jul 2009 17:04:44 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH -mm] throttle direct reclaim when too many pages are
	isolated already (v3)
Message-ID: <20090729150443.GB1534@ucw.cz>
References: <20090715223854.7548740a@bree.surriel.com> <20090715194820.237a4d77.akpm@linux-foundation.org> <4A5E9A33.3030704@redhat.com> <20090715202114.789d36f7.akpm@linux-foundation.org> <4A5E9E4E.5000308@redhat.com> <20090715203854.336de2d5.akpm@linux-foundation.org> <20090715235318.6d2f5247@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090715235318.6d2f5247@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed 2009-07-15 23:53:18, Rik van Riel wrote:
> When way too many processes go into direct reclaim, it is possible
> for all of the pages to be taken off the LRU.  One result of this
> is that the next process in the page reclaim code thinks there are
> no reclaimable pages left and triggers an out of memory kill.
> 
> One solution to this problem is to never let so many processes into
> the page reclaim path that the entire LRU is emptied.  Limiting the
> system to only having half of each inactive list isolated for
> reclaim should be safe.

Is this still racy? Like on 100cpu machine, with LRU size of 50...?
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
