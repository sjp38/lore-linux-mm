Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6D8296B0249
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 22:56:51 -0400 (EDT)
Message-ID: <4E0159E9.10800@redhat.com>
Date: Wed, 22 Jun 2011 10:56:41 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <20110620165844.GA9396@suse.de> <4DFF7E3B.1040404@redhat.com> <4DFF7F0A.8090604@redhat.com> <4DFF8106.8090702@redhat.com> <4DFF8327.1090203@redhat.com> <4DFF84BB.3050209@redhat.com> <4DFF8848.2060802@redhat.com> <20110620182558.GF4749@redhat.com> <20110620192117.GG20843@redhat.com> <4E00192E.70901@redhat.com> <20110621144346.GQ20843@redhat.com>
In-Reply-To: <20110621144346.GQ20843@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 22:43, Andrea Arcangeli a??e??:
> On Tue, Jun 21, 2011 at 12:08:14PM +0800, Cong Wang wrote:
>> The thing is that we can save ~10K by adding 3 lines of code as this
>> patch showed, where else in kernel can you save 10K by 3 lines of code?
>> (except some kfree() cases, of course) So, again, why not have it? ;)
>
> Because you could save it with a more complicated patch that doesn't
> cripple down functionality.


Why do you prefer "more complicated" things to simple ones? ;-)

I realized this patch changed the original behavior of "=never",
thus proposed a new "=0" parameter.

But to be honest, "=never" should be renamed to "=disable".

> Again if you want to optimize this ~8KB gain, I recommend to add a
> param to make the hash size dynamic not to prevent the feature to ever
> be enabled again, so by making the code more complex at least it will
> also be useful if we want to increase the size hash at boot time (not
> only to decrease it).
>

Not only such things, the more serious thing is that you are
enforcing a policy to users, as long as I enable THP in Kconfig,
I have no way to disable it.

Why are you so sure that every user who has no chance to change
.config likes THP?

And, what can I do if I want to prevent any process from having
a chance to enable THP? Because as long as THP exists in /sys,
any process has the right privilege can change it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
