Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 4A53D6B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 18:43:36 -0400 (EDT)
Received: by ggm4 with SMTP id 4so3586485ggm.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 15:43:35 -0700 (PDT)
Date: Thu, 12 Jul 2012 15:42:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 -mm] memcg: prevent from OOM with too many dirty
 pages
In-Reply-To: <20120712141343.e1cb7776.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1207121539150.27721@eggly.anvils>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz> <20120619150014.1ebc108c.akpm@linux-foundation.org> <20120620101119.GC5541@tiehlicka.suse.cz> <alpine.LSU.2.00.1207111818380.1299@eggly.anvils> <20120712070501.GB21013@tiehlicka.suse.cz>
 <20120712141343.e1cb7776.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Thu, 12 Jul 2012, Andrew Morton wrote:
> On Thu, 12 Jul 2012 09:05:01 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > When we are back to the patch. Is it going into 3.5? I hope so and I
> > think it is really worth stable as well. Andrew?
> 
> What patch.   "memcg: prevent OOM with too many dirty pages"?

Yes.

> 
> I wasn't planning on 3.5, given the way it's been churning around.

I don't know if you had been intending to send it in for 3.5 earlier;
but I'm sorry if my late intervention on may_enter_fs has delayed it.

> How
> about we put it into 3.6 and tag it for a -stable backport, so it gets
> a bit of a run in mainline before we inflict it upon -stable users?

That sounds good enough to me, but does fall short of Michal's hope.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
