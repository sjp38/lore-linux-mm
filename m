Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D89F59000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 07:52:20 -0400 (EDT)
Received: by wwf10 with SMTP id 10so10109799wwf.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:52:18 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 26 Sep 2011 17:21:12 +0530
Message-ID: <CAFPAmTRHFOT+tc=J-=jTBpvi8ksnp6H32UsEwptrrv=hagjUsA@mail.gmail.com>
Subject: Why isn't shrink_slab more zone oriented ?
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

I was going through the do_try_to_free_pages(), balance_pgdat(),
__zone_reclaim()
functions and I see that shrink_zone and shrink_slab are called for each zone.

But, shrink_slab() doesn't seem to bother about the zone from where it
is freeing
memory.

My questions are:

- Will this be a strain on the direct/indirect reclamation algorithm ?
  The loops involved expects to free something from that particular zone.
  shrink_slab might take more time than is required to free up pages from that
  particular zone which might not be optimal.
  Am I right about this conclusion ?

- If the above is correct, then is there any work happening on this
front, i.e., to
  make shrink_slab functionality and the shrinker callbacks more zone-centric ?
  Are there any patches that I could look at or download from
somewhere for this ?

- Are there any other considerations to be careful of for making
shrink_slab more
  zone centric ? Can there be other side effects that affects
performance if the
  shrink_slab and shrinker callbacks are made to free pages only from
a particular
  zone ?

Thanks,
Kautuk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
