Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 3384A6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 05:30:55 -0400 (EDT)
Message-ID: <1335864640.13683.116.camel@twins>
Subject: Re: [patch 4/5] mm + fs: provide refault distance to page cache
 instantiations
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 01 May 2012 11:30:40 +0200
In-Reply-To: <1335861713-4573-5-git-send-email-hannes@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
	 <1335861713-4573-5-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2012-05-01 at 10:41 +0200, Johannes Weiner wrote:
> Every site that does a find_or_create()-style allocation is converted
> to pass this refault information to the page_cache_alloc() family of
> functions, which in turn passes it down to the page allocator via
> current->refault_distance.=20

That is rather icky..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
