Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 003816B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 22:39:41 -0400 (EDT)
Received: by pzk16 with SMTP id 16so730857pzk.22
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 19:39:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100401085718.d091eda6.kamezawa.hiroyu@jp.fujitsu.com>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
	 <1269940489-5776-15-git-send-email-mel@csn.ul.ie>
	 <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100331112730.GB27389@csn.ul.ie>
	 <20100401085718.d091eda6.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 1 Apr 2010 11:39:42 +0900
Message-ID: <q2r28c262361003311939zbfa8e980ifa9c58cb9d62dc83@mail.gmail.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of PageSwapCache
	pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 1, 2010 at 8:57 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com>
>
> rmap_walk_anon() is called against unmapped pages.
> Then, !page_mapped() is always true. So, the behavior will not be different from
> the last one.
>

rmap_walk_anon can be also called in case of failing try_to_unmap.
Then, In unmap_and_move, page_mapped is true and
remove_migration_ptes can be called.

But I am not sure this Mel's patch about this part is really needed.

> Thanks,
> -Kame
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
