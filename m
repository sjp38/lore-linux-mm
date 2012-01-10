Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 179856B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 04:44:57 -0500 (EST)
Date: Tue, 10 Jan 2012 09:44:52 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: vmscan: fix setting reclaim mode
Message-ID: <20120110094452.GC4118@suse.de>
References: <CAJd=RBAqzawZ=jEFt7TrZgU0gaejMkfiBxzH7Y19qqNnsZrJGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBAqzawZ=jEFt7TrZgU0gaejMkfiBxzH7Y19qqNnsZrJGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Jan 08, 2012 at 03:05:03PM +0800, Hillf Danton wrote:
> The check for under memory pressure is corrected, then lumpy reclaim or
> reclaim/compaction could be avoided either when for order-O reclaim or
> when free pages are already low enough.
> 

No explanation of problem, how this patch fixes it or what the impact
is.

At a glance, this will have the impact of using sync reclaim at low
reclaim priorities. This is unexpected so needs much better explanation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
