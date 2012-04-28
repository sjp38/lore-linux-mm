Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 4D1166B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 09:19:51 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1228691ghr.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 06:19:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335554086-4294-1-git-send-email-yinghan@google.com>
References: <1335554086-4294-1-git-send-email-yinghan@google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 28 Apr 2012 09:19:29 -0400
Message-ID: <CAHGf_=q4JmSNrj_rdFuFQGNBCJQkpHDMeYEobAt6VWLXkf5CUg@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg: add mlock statistic in memory.stat
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Apr 27, 2012 at 3:14 PM, Ying Han <yinghan@google.com> wrote:
> We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
> patch adds the mlock field into per-memcg memory stat. The stat itself enhances
> the metrics exported by memcg since the unevictable lru includes more than
> mlock()'d page like SHM_LOCK'd.
>
> Why we need to count mlock'd pages while they are unevictable and we can not
> do much on them anyway?
>
> This is true. The mlock stat I am proposing is more helpful for system admin
> and kernel developer to understand the system workload. The same information
> should be helpful to add into OOM log as well. Many times in the past that we
> need to read the mlock stat from the per-container meminfo for different
> reason. Afterall, we do have the ability to read the mlock from meminfo and
> this patch fills the info in memcg.
>
> Note:
> Here are the places where I didn't add the hook:
> 1. in the mlock_migrate_page() since the owner of oldpage and newpage is the same.
> 2. in the freeing path since page shouldn't get to there at the first place.

Looks good. (even though I don't like unreliable mlock statistics)
 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
