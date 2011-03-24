Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 388B58D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 03:34:05 -0400 (EDT)
Received: by iwl42 with SMTP id 42so12991524iwl.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 00:34:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324162936.CC87.A69D9226@jp.fujitsu.com>
References: <20110324160349.CC83.A69D9226@jp.fujitsu.com>
	<AANLkTi=rOCdojotYG3wyX2Bt+aDrgxTO9DQWe7h1BQrC@mail.gmail.com>
	<20110324162936.CC87.A69D9226@jp.fujitsu.com>
Date: Thu, 24 Mar 2011 16:34:03 +0900
Message-ID: <AANLkTimafdn8wPD7Zu3tK4PLgik=-0MeE62nGxq7ks4N@mail.gmail.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct
 reclaim path completely
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Mar 24, 2011 at 4:28 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> For example, In 4G desktop system.
>> 32M full scanning and fail to reclaim a page.
>> It's under 1% coverage.
>
> ?? I'm sorry. I haven't catch it.
> Where 32M come from?

(1<<12) * 4K + (1<<11) + 4K + .. (1 << 0) + 4K in shrink_zones.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
