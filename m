Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 023F16B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 04:01:40 -0400 (EDT)
Received: by iajr24 with SMTP id r24so5683038iaj.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 01:01:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F9E44AD.8020701@kernel.org>
References: <4F9E39F1.5030600@kernel.org>
	<CAOJsxLE3A3b5HSrRm0NVCBmzv7AAs-RWEiZC1BL=se309+=WTA@mail.gmail.com>
	<4F9E44AD.8020701@kernel.org>
Date: Mon, 30 Apr 2012 11:01:40 +0300
Message-ID: <CAOJsxLGd_-ZSxpY2sL8XqyiYxpnmYDJJ+Hfx-zi1Ty=-1igcLA@mail.gmail.com>
Subject: Re: vmevent: question?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <anton.vorontsov@linaro.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

Hi Minchan,

On Mon, Apr 30, 2012 at 10:52 AM, Minchan Kim <minchan@kernel.org> wrote:
>> It makes the userspace side simpler for "lowmem notification" use
>> case. I'm open to changing the ABI if it doesn't make the userspace
>> side too complex.
>
> Yes. I understand your point but if we still consider all of values,
> we don't have any way to capture exact values except triggered event value.
> I mean there is no lock to keep consistency.
> If stale data is okay, no problem but IMHO, it could make user very confusing.
> So let's return value for first matched event if various event match.
> Of course, let's write down it in ABI.
> If there is other idea for reporting all of item with consistent, I'm okay.

What kind of consistency guarantees do you mean? The data sent to
userspace is always a snapshot of the state and therefore can be stale
by the time it reaches userspace.

If your code needs stricter consistency guarantees, you probably want
to do it in the kernel.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
