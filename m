Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 045356B0012
	for <linux-mm@kvack.org>; Tue, 17 May 2011 09:55:58 -0400 (EDT)
Message-ID: <4DD27E62.50806@redhat.com>
Date: Tue, 17 May 2011 09:55:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [rfc patch 4/6] memcg: reclaim statistics
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org> <1305212038-15445-5-git-send-email-hannes@cmpxchg.org> <BANLkTi=yCyAsOc_uTQLp1kWp5w0i9gomxg@mail.gmail.com> <20110516231028.GV16531@cmpxchg.org> <BANLkTimLNZfc-jcA3yBG5D3k2u=0_JnrhQ@mail.gmail.com> <20110517074230.GY16531@cmpxchg.org>
In-Reply-To: <20110517074230.GY16531@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/17/2011 03:42 AM, Johannes Weiner wrote:

> It does hierarchical soft limit reclaim once triggered, but I meant
> that soft limits themselves have no hierarchical meaning.  Say you
> have the following hierarchy:
>
>                  root_mem_cgroup
>
>               aaa               bbb
>
>             a1  a2             b1  b2
>
>          a1-1
>
> Consider aaa and a1 had a soft limit.  If global memory arose, aaa and
> all its children would be pushed back with the current scheme, the one
> you are proposing, and the one I am proposing.
>
> But now consider aaa hitting its hard limit.  Regular target reclaim
> will be triggered, and a1, a2, and a1-1 will be scanned equally from
> hierarchical reclaim.  That a1 is in excess of its soft limit is not
> considered at all.
>
> With what I am proposing, a1 and a1-1 would be pushed back more
> aggressively than a2, because a1 is in excess of its soft limit and
> a1-1 is contributing to that.

Ying, I think Johannes has a good point.  I do not see
a way to enforce the limits properly with the scheme we
came up with at LSF, in the hierarchical scenario above.

There may be a way, but until we think of it, I suspect
it will be better to go with Johannes's scheme for now.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
