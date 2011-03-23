Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9F158D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 05:03:28 -0400 (EDT)
Received: by iwl42 with SMTP id 42so11487741iwl.14
        for <linux-mm@kvack.org>; Wed, 23 Mar 2011 02:02:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110323174545.1AE2.A69D9226@jp.fujitsu.com>
References: <20110323161354.1AD2.A69D9226@jp.fujitsu.com>
	<20110323082423.GA1969@barrios-desktop>
	<20110323174545.1AE2.A69D9226@jp.fujitsu.com>
Date: Wed, 23 Mar 2011 18:02:58 +0900
Message-ID: <AANLkTi=w62=WR5WACJGk6JNhyCYpgNhFQK3CyQ5Ag-Yj@mail.gmail.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct
 reclaim path completely
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Mar 23, 2011 at 5:44 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Boo.
>> > You seems forgot why you introduced current all_unreclaimable() function.
>> > While hibernation, we can't trust all_unreclaimable.
>>
>> Hmm. AFAIR, the why we add all_unreclaimable is when the hibernation is going on,
>> kswapd is freezed so it can't mark the zone->all_unreclaimable.
>> So I think hibernation can't be a problem.
>> Am I miss something?
>
> Ahh, I missed. thans correct me. Okay, I recognized both mine and your works.
> Can you please explain why do you like your one than mine?

Just _simple_ :)
I don't want to change many lines although we can do it simple and very clear.

>
> btw, Your one is very similar andrey's initial patch. If your one is
> better, I'd like to ack with andrey instead.

When Andrey sent a patch, I though this as zone_reclaimable() is right
place to check it than out of zone_reclaimable. Why I didn't ack is
that Andrey can't explain root cause but you did so you persuade me.

I don't mind if Andrey move the check in zone_reclaimable and resend
or I resend with concrete description.

Anyway, most important thing is good description to show the root cause.
It is applied to your patch, too.
You should have written down root cause in description.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
