Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 17B546B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:13:45 -0400 (EDT)
Date: Thu, 12 Jul 2012 14:13:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 -mm] memcg: prevent from OOM with too many dirty
 pages
Message-Id: <20120712141343.e1cb7776.akpm@linux-foundation.org>
In-Reply-To: <20120712070501.GB21013@tiehlicka.suse.cz>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
	<20120619150014.1ebc108c.akpm@linux-foundation.org>
	<20120620101119.GC5541@tiehlicka.suse.cz>
	<alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
	<20120712070501.GB21013@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Thu, 12 Jul 2012 09:05:01 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> When we are back to the patch. Is it going into 3.5? I hope so and I
> think it is really worth stable as well. Andrew?

What patch.   "memcg: prevent OOM with too many dirty pages"?

I wasn't planning on 3.5, given the way it's been churning around.  How
about we put it into 3.6 and tag it for a -stable backport, so it gets
a bit of a run in mainline before we inflict it upon -stable users?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
