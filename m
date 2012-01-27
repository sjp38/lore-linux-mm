Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 31E4B6B006E
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 11:36:21 -0500 (EST)
Message-ID: <4F22D265.9040303@redhat.com>
Date: Fri, 27 Jan 2012 11:35:49 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [resubmit] Re: [PATCH] tracing: adjust shrink_slab beginning
 trace event name
References: <20111223141619.GA19720@x61.redhat.com> <20120127124405.GA2092@x61.redhat.com>
In-Reply-To: <20120127124405.GA2092@x61.redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>Andrew Morton <akpm@linux-foundation.org>

On 01/27/2012 07:44 AM, Rafael Aquini wrote:
> While reviewing vmscan tracing events, I realized all functions which establish paired tracepoints (one at the beginning and another at the end of the function block) were following this naming pattern:
>    <tracepoint-name>_begin
>    <tarcepoint-name>_end
>
> However, the 'beginning' tracing event for shrink_slab() did not follow the aforementioned naming pattern. This patch renames that trace event to adjust this naming inconsistency.
>
> Signed-off-by: Rafael Aquini<aquini@redhat.com>
> Reviewed-by: Minchan Kim<minchan@kernel.org>
> Acked-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
