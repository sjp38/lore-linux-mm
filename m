Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id B85E96B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 03:57:56 -0400 (EDT)
Message-ID: <4FA23A83.4040604@kernel.org>
Date: Thu, 03 May 2012 16:57:55 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: vmevent: question?
References: <4F9E39F1.5030600@kernel.org> <CAOJsxLE3A3b5HSrRm0NVCBmzv7AAs-RWEiZC1BL=se309+=WTA@mail.gmail.com> <4F9E44AD.8020701@kernel.org> <CAOJsxLGd_-ZSxpY2sL8XqyiYxpnmYDJJ+Hfx-zi1Ty=-1igcLA@mail.gmail.com> <4F9E4F0A.8030900@kernel.org> <alpine.LFD.2.02.1205031019410.3686@tux.localdomain>
In-Reply-To: <alpine.LFD.2.02.1205031019410.3686@tux.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <anton.vorontsov@linaro.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

On 05/03/2012 04:24 PM, Pekka Enberg wrote:

> On Mon, 30 Apr 2012, Minchan Kim wrote:
>>> What kind of consistency guarantees do you mean? The data sent to
>>> userspace is always a snapshot of the state and therefore can be stale
>>> by the time it reaches userspace.
>>
>> Consistency between component of snapshot.
>> let's assume following as
>>
>> 1. User expect some events's value would be minus when event he expect happen.
>>    A : -3, B : -4, C : -5, D : -6
>> 2. Logically, it's not possible to mix plus and minus values for the events.
>>    A : -3, B : -4, C : -5, D : -6 ( O )
>>    A : -3, B : -4, C : 1, D : 2   ( X )
>>    
>> But in current implementation, some of those could be minus and some of those could be plus.
>> Which event could user believe?
>> At least, we need a _captured_ value when event triggered so that user can ignore other values.
> 
> Sorry, I still don't quite understand the problem.


Sorry for my poor explanation.
My point is when userspace get vmevent_event by reading fd, it could enumerate
several attribute all at once. 
Then, one of attribute(call A) made by vmevent_match in kernel and other attributes(call B, C, D)
are just extra for convenience. Because there is time gap when kernel get attribute values, B,C,D could be stale.
Then, how can user determine which event is really triggered? A or B or C or D?
Which event really happens?


> 
> The current implementation provides the same kind of snapshot consistency 
> as reading from /proc/vmstat does (modulo the fact that we read them 
> twice) for the values we support.
> 
> 			Pekka
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
