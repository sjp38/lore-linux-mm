Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 113F46B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 14:21:38 -0400 (EDT)
Message-ID: <4FA017FA.2000707@redhat.com>
Date: Tue, 01 May 2012 13:06:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
References: <1335214564-17619-1-git-send-email-yinghan@google.com> <CAPa8GCATMxi2ON22T_daE9EMFg8BWgK4vRTDadDFR66aj_uGTg@mail.gmail.com> <CALWz4ixeBq7cMoopukaRZxUmH1i0+L4xZ_49B0YpZ4iZuRC+Uw@mail.gmail.com> <CAPa8GCC1opy9u6NHy9m=1xU4EfRsHu8VN2kU-bXtRz=z_Mq0PA@mail.gmail.com> <CALWz4iyv1wSkdS0e9iezbpAg_adBhKvxRVqmXX1i4mk3x_V34g@mail.gmail.com>
In-Reply-To: <CALWz4iyv1wSkdS0e9iezbpAg_adBhKvxRVqmXX1i4mk3x_V34g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 05/01/2012 12:18 PM, Ying Han wrote:

> The current logic seems perfer to reclaim more than going oom kill,
> and that might not fit all user's expectation. However, I guess it is
> hard to convince for any changes since different users has different
> bias as you said....

However, it is a sure thing that desktop users and smartphone
users do want an earlier OOM kill.

I wonder if doing an OOM kill when the number of free pages
plus the number of file lru pages in every zone is below
pages_high and there is no more swap available might work?

On the other hand, that still leaves us cgroups. What could
be appropriate there?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
