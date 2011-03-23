Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 993238D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 04:45:04 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 850D83EE0B5
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 17:45:01 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A0E445DE50
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 17:45:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 509F745DE4E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 17:45:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FA951DB803F
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 17:45:01 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0992E1DB8037
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 17:45:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <20110323082423.GA1969@barrios-desktop>
References: <20110323161354.1AD2.A69D9226@jp.fujitsu.com> <20110323082423.GA1969@barrios-desktop>
Message-Id: <20110323174545.1AE2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 23 Mar 2011 17:44:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

> > Boo.
> > You seems forgot why you introduced current all_unreclaimable() function.
> > While hibernation, we can't trust all_unreclaimable.
> 
> Hmm. AFAIR, the why we add all_unreclaimable is when the hibernation is going on,
> kswapd is freezed so it can't mark the zone->all_unreclaimable.
> So I think hibernation can't be a problem.
> Am I miss something?

Ahh, I missed. thans correct me. Okay, I recognized both mine and your works.
Can you please explain why do you like your one than mine?

btw, Your one is very similar andrey's initial patch. If your one is
better, I'd like to ack with andrey instead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
