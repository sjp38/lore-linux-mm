Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E98066B004A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 07:43:12 -0500 (EST)
Subject: Re: [PATCH 0/8] Use memory compaction instead of lumpy reclaim during high-order allocations
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
From: Theodore Tso <tytso@MIT.EDU>
In-Reply-To: <20101119104856.GB28613@csn.ul.ie>
Date: Fri, 19 Nov 2010 07:43:02 -0500
Content-Transfer-Encoding: 7bit
Message-Id: <4B8266CB-F658-4CC8-BCA3-677C22BAFAE0@mit.edu>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie> <20101117154641.51fd7ce5.akpm@linux-foundation.org> <20101118081254.GB8135@csn.ul.ie> <20101118172627.cf25b83a.kamezawa.hiroyu@jp.fujitsu.com> <20101118083828.GA24635@cmpxchg.org> <20101118092044.GE8135@csn.ul.ie> <20101118114928.ecb2d6b0.akpm@linux-foundation.org> <20101119104856.GB28613@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Nov 19, 2010, at 5:48 AM, Mel Gorman wrote:

> At least as long as !CONFIG_COMPACTION exists. That will be a while because
> bear in mind CONFIG_COMPACTION is disabled by default (although I believe
> some distros are enabling it at least). Maybe we should choose to deprecate
> it in 2.6.40 and delete it at the infamous time of 2.6.42? That would give
> ample time to iron out any issues that crop up with reclaim/compaction
> (what this series has turned into).

How about making the default before 2.6.40, as an initial step?

-Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
