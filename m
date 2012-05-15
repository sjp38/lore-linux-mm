Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 33B6D6B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 21:23:02 -0400 (EDT)
Message-ID: <4FB1B012.1090506@kernel.org>
Date: Tue, 15 May 2012 10:23:30 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: Allow migration of mlocked page?
References: <4FAC9786.9060200@kernel.org> <1336728026.1017.7.camel@twins>  <4FB0866D.4020203@kernel.org> <1336978573.2443.13.camel@twins> <4FB0B61E.6040902@kernel.org> <alpine.DEB.2.00.1205140847340.26056@router.home>
In-Reply-To: <alpine.DEB.2.00.1205140847340.26056@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>

On 05/14/2012 10:47 PM, Christoph Lameter wrote:

> On Mon, 14 May 2012, Minchan Kim wrote:
> 
>> What's the meaning of "locked"? Isn't it pinning?
> 
> No. We agreed to that a long time ago when the page migration logic was
> first merged. Mlock only means memory resident.


I realized it through Peter's link on opengroup.
Hmm, The problem is that it's not consistent with man pages which says "no fault happen".
So many developers have been used it by meaning of "making sure latency". :(

> 
> Hugh pushed for it initially.

> 

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
