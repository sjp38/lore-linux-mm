Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BFFA86B0033
	for <linux-mm@kvack.org>; Wed, 26 Oct 2011 02:24:13 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p9Q6O6np009335
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:24:10 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz1.hot.corp.google.com with ESMTP id p9Q6MhNv029893
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:24:04 -0700
Received: by pzk36 with SMTP id 36so5097472pzk.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 23:24:04 -0700 (PDT)
Date: Tue, 25 Oct 2011 23:24:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <CAMbhsRS+-jn7d1bTd4F0_RB9860iWjOHLfOkDsqLfWEUbR3TYA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1110252322220.20273@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com> <20111025090956.GA10797@suse.de> <alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com> <CAMbhsRQ3y2SBwEfjiYgfxz2-h0fgn20mLBYgFuBwGqon0f-a8g@mail.gmail.com>
 <alpine.DEB.2.00.1110252244270.18661@chino.kir.corp.google.com> <alpine.DEB.2.00.1110252311030.20273@chino.kir.corp.google.com> <CAMbhsRS+-jn7d1bTd4F0_RB9860iWjOHLfOkDsqLfWEUbR3TYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, 25 Oct 2011, Colin Cross wrote:

> > Or, rather, when pm_restrict_gfp_mask() clears __GFP_IO and __GFP_FS that
> > it also has the same behavior as __GFP_NORETRY in should_alloc_retry() by
> > setting a variable in file scope.
> >
> 
> Why do you prefer that over adding a gfp_required_mask?
> 

Because it avoids an unnecessary OR in the page and slab allocator 
fastpaths which are red hot :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
