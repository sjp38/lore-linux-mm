Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2A5706B004A
	for <linux-mm@kvack.org>; Sun, 28 Nov 2010 21:26:21 -0500 (EST)
Received: by vws10 with SMTP id 10so1076125vws.14
        for <linux-mm@kvack.org>; Sun, 28 Nov 2010 18:26:19 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH v2 1/3] deactivate invalidated pages
In-Reply-To: <20101129110848.82A8.A69D9226@jp.fujitsu.com>
References: <20101129090514.829C.A69D9226@jp.fujitsu.com> <87pqto3n77.fsf@gmail.com> <20101129110848.82A8.A69D9226@jp.fujitsu.com>
Date: Sun, 28 Nov 2010 21:26:15 -0500
Message-ID: <8739qk3lx4.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010 11:13:53 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> I'm not againt DONT_NEED feature. I only said PG_reclaim trick is not
> so effective. Every feature has their own pros/cons. I think the cons
> is too big. Also, nobody have mesured PG_reclaim performance gain. Did you?
> 
Not yet. Finally back from vacation here in the States. I'll try sitting
down to put together a test tonight.

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
