Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 2F2216B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 04:14:12 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SPrAv-00010C-3c
	for linux-mm@kvack.org; Thu, 03 May 2012 10:14:09 +0200
Received: from 121.50.20.41 ([121.50.20.41])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 03 May 2012 10:14:08 +0200
Received: from minchan by 121.50.20.41 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 03 May 2012 10:14:08 +0200
From: Minchan Kim <minchan@kernel.org>
Subject: Re: vmevent: question?
Date: Thu, 03 May 2012 17:13:59 +0900
Message-ID: <4FA23E47.6040303@kernel.org>
References: <4F9E39F1.5030600@kernel.org> <CAOJsxLE3A3b5HSrRm0NVCBmzv7AAs-RWEiZC1BL=se309+=WTA@mail.gmail.com> <4F9E44AD.8020701@kernel.org> <CAOJsxLGd_-ZSxpY2sL8XqyiYxpnmYDJJ+Hfx-zi1Ty=-1igcLA@mail.gmail.com> <4F9E4F0A.8030900@kernel.org> <alpine.LFD.2.02.1205031019410.3686@tux.localdomain> <4FA23A83.4040604@kernel.org> <CAOJsxLHxLbzp+nfc72pzzyAe8W5w-phbHhREdJ7Mg5P9JHeF5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
In-Reply-To: <CAOJsxLHxLbzp+nfc72pzzyAe8W5w-phbHhREdJ7Mg5P9JHeF5A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On 05/03/2012 05:07 PM, Pekka Enberg wrote:

> On Thu, May 3, 2012 at 10:57 AM, Minchan Kim <minchan@kernel.org> wrote:
>> Sorry for my poor explanation.
>> My point is when userspace get vmevent_event by reading fd, it could enumerate
>> several attribute all at once.
>> Then, one of attribute(call A) made by vmevent_match in kernel and other attributes(call B, C, D)
>> are just extra for convenience. Because there is time gap when kernel get attribute values, B,C,D could be stale.
>> Then, how can user determine which event is really triggered? A or B or C or D?
>> Which event really happens?
> 
> Right. Mark the matching values with something like
> VMEVENT_ATTR_STATE_CAPTURED should be sufficient?


Seems to be good and we have to notice to user by document
"Except VMEVENT_ATTR_STATE_CAPTURED, all attributes's value could be stale.
So, don't be deceived. Please ignore if you need"

First of all, let make CAPTURED state could be exact.

-----
> Q 2. Is it okay although value when vmevent_match check happens is different with
>     vmevent_sample_attr in vmevent_sample's for loop?
>     I think it's not good.
Yeah, that's just silly and needs fixing.
-----

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
