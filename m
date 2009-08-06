Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4C9E46B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 04:07:40 -0400 (EDT)
Received: by yxe14 with SMTP id 14so843780yxe.12
        for <linux-mm@kvack.org>; Thu, 06 Aug 2009 01:07:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f11576a0908052213m3fba4154ifb73ab1ae2ea74d6@mail.gmail.com>
References: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
	 <20090805163945.056c463c.akpm@linux-foundation.org>
	 <2f11576a0908052213m3fba4154ifb73ab1ae2ea74d6@mail.gmail.com>
Date: Thu, 6 Aug 2009 17:07:41 +0900
Message-ID: <28c262360908060107i4d1d23f3h47c112b48f1d8e48@mail.gmail.com>
Subject: Re: [PATCH for 2.6.31 0/4] fix oom_adj regression v2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, Kosaki.

On Thu, Aug 6, 2009 at 2:13 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> So I merged these but I have a feeling that this isn't the last I'll be
>> hearing on the topic ;)
>>
>> Given the amount of churn, the amount of discussion and the size of the
>> patches, this doesn't look like something we should push into 2.6.31.
>>
>> If we think that the 2ff05b2b regression is sufficiently serious to be
>> a must-fix for 2.6.31 then can we please find something safer and
>> smaller? =C2=A0Like reverting 2ff05b2b?
>
> I don't think the serious problem is only =C2=A0this issue, I oppose to
> ignore regression
> bug report ;-)
>
> Yes, your point makes sense. then, I'll make two patch series.
> 1. reverting 2ff05b2b for 2.6.31
> 2. retry fix oom livelock for -mm
>
> I expect I can do that next sunday.
>
>
>> These patches clash with the controversial
>> mm-introduce-proc-pid-oom_adj_child.patch, so I've disabled that patch
>> now.
>
> I think we can drop this because workaround patch is only needed until
> the issue not fixed.


I looked over your this patches.
I can't find out merge point our both idea.

I think it would be better than mine.

As kame pointed out, you patch can solve long stall time of do_each_thread
as well as livelock.

So I will wait for you to finish this work and review then.
I ask you add me in CC, then. :)

Thanks.

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
