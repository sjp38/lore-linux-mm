Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A8AA06B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 20:50:45 -0500 (EST)
Received: by iwn33 with SMTP id 33so2760623iwn.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 17:50:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101122013655.GA10126@localhost>
References: <1290349496-13297-1-git-send-email-minchan.kim@gmail.com>
	<20101122013655.GA10126@localhost>
Date: Mon, 22 Nov 2010 10:50:44 +0900
Message-ID: <AANLkTimVvgKuND8tVyubkanEr5L4Vgy66jiOqxpF7ZQ_@mail.gmail.com>
Subject: Re: [PATCH] vmscan: Make move_active_pages_to_lru more generic
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hi Wu,

On Mon, Nov 22, 2010 at 10:36 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> On Sun, Nov 21, 2010 at 10:24:56PM +0800, Minchan Kim wrote:
>> Now move_active_pages_to_lru can move pages into active or inactive.
>> if it moves the pages into inactive, it itself can clear PG_acive.
>> It makes the function more generic.
>
> Do you plan to use this "more generic" function? Because the patch in
> itself makes code slightly less efficient. It adds one "if" test, and
> moves one operation into the spin lock.

I tried to use it in my deactivate page series but couldn't use it due
some problem.
So I don't have a plan to use it. It's just my preference(and I hope
others think like me :) )

I hope function itself would be generic and clear because some people
in future might use it and reference it.
If my change makes big cost, I am not against you. otherwise, I hope
move_active_pages_to_lru become self-contained.

>
> Thanks,
> Fengguang
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
