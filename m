Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id C04BB6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 05:59:10 -0400 (EDT)
Message-ID: <1335866334.13683.121.camel@twins>
Subject: Re: [patch 4/5] mm + fs: provide refault distance to page cache
 instantiations
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 01 May 2012 11:58:54 +0200
In-Reply-To: <20120501095543.GA2112@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
	 <1335861713-4573-5-git-send-email-hannes@cmpxchg.org>
	 <1335864640.13683.116.camel@twins> <20120501095543.GA2112@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2012-05-01 at 11:55 +0200, Johannes Weiner wrote:
> On Tue, May 01, 2012 at 11:30:40AM +0200, Peter Zijlstra wrote:
> > On Tue, 2012-05-01 at 10:41 +0200, Johannes Weiner wrote:
> > > Every site that does a find_or_create()-style allocation is converted
> > > to pass this refault information to the page_cache_alloc() family of
> > > functions, which in turn passes it down to the page allocator via
> > > current->refault_distance.=20
> >=20
> > That is rather icky..
>=20
> Fair enough, I just went with the easier solution to get things off
> the ground instead of dealing with adding an extra parameter to layers
> of config-dependent gfp API.  I'll revisit this for v2.

OK, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
