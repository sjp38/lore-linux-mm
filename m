Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 066336B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:11:45 -0400 (EDT)
Message-ID: <4FB4F902.1050708@redhat.com>
Date: Thu, 17 May 2012 09:11:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] refault distance-based file cache sizing
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org> <4FB33A4E.1010208@gmail.com>
In-Reply-To: <4FB33A4E.1010208@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "nai.xia" <nai.xia@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/16/2012 01:25 AM, nai.xia wrote:
> Hi Johannes,
>
> Just out of curiosity(since I didn't study deep into the
> reclaiming algorithms), I can recall from here that around 2005,
> there was an(or some?) implementation of the "Clock-pro" algorithm
> which also have the idea of "reuse distance", but it seems that algo
> did not work well enough to get merged?

The main issue with clock-pro was scalability.

Johannes has managed to take the good parts of clock-pro,
and add it on top of our split lru VM, which lets us keep
the scalability, while still being able to deal with file
faults from beyond the inactive list.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
