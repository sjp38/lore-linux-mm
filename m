Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id A3D166B0002
	for <linux-mm@kvack.org>; Tue, 14 May 2013 17:08:25 -0400 (EDT)
Message-ID: <5192A73F.3060606@redhat.com>
Date: Tue, 14 May 2013 17:06:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 9/9] mm: vmscan: Move logic from balance_pgdat() to kswapd_shrink_zone()
References: <1368432760-21573-1-git-send-email-mgorman@suse.de> <1368432760-21573-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1368432760-21573-10-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/13/2013 04:12 AM, Mel Gorman wrote:
> balance_pgdat() is very long and some of the logic can and should
> be internal to kswapd_shrink_zone(). Move it so the flow of
> balance_pgdat() is marginally easier to follow.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
