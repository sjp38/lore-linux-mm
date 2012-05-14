Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 6A0B46B00EB
	for <linux-mm@kvack.org>; Mon, 14 May 2012 09:47:50 -0400 (EDT)
Date: Mon, 14 May 2012 08:47:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Allow migration of mlocked page?
In-Reply-To: <4FB0B61E.6040902@kernel.org>
Message-ID: <alpine.DEB.2.00.1205140847340.26056@router.home>
References: <4FAC9786.9060200@kernel.org> <1336728026.1017.7.camel@twins>  <4FB0866D.4020203@kernel.org> <1336978573.2443.13.camel@twins> <4FB0B61E.6040902@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>

On Mon, 14 May 2012, Minchan Kim wrote:

> What's the meaning of "locked"? Isn't it pinning?

No. We agreed to that a long time ago when the page migration logic was
first merged. Mlock only means memory resident.

Hugh pushed for it initially.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
