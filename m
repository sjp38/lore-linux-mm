Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E2D4A9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 21:37:59 -0400 (EDT)
Received: by wyf19 with SMTP id 19so1228448wyf.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 18:37:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTim067_+bycA-rJk6u595YucMmruqQ@mail.gmail.com>
References: <20110426085953.GA12389@darkstar>
	<BANLkTikkUq7rg4umYQ5yt9ve+q34Pf+=Ag@mail.gmail.com>
	<BANLkTin0wj3AhCtR5ZD=N_LUKjE1etBcFg@mail.gmail.com>
	<BANLkTim067_+bycA-rJk6u595YucMmruqQ@mail.gmail.com>
Date: Wed, 27 Apr 2011 09:37:57 +0800
Message-ID: <BANLkTi=8ySUPP6_GUL9CTFh98J1PH0a4=g@mail.gmail.com>
Subject: Re: [PATCH v2] virtio_balloon: disable oom killer when fill balloon
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>

On Wed, Apr 27, 2011 at 7:33 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Tue, Apr 26, 2011 at 6:39 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
>> On Tue, Apr 26, 2011 at 5:28 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
>>> Please resend this with [2/2] to linux-mm.
>>>
>>> On Tue, Apr 26, 2011 at 5:59 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
>>>> When memory pressure is high, virtio ballooning will probably cause oom killing.
>>>> Even if alloc_page with GFP_NORETRY itself does not directly trigger oom it
>>>> will make memory becoming low then memory alloc of other processes will trigger
>>>> oom killing. It is not desired behaviour.
>>>
>>> I can't understand why it is undesirable.
>>> Why do we have to handle it specially?
>>>
>>
>> Suppose user run some random memory hogging process while ballooning
>> it will be undesirable.
>
>
> In VM POV, kvm and random memory hogging processes are customers.
> If we handle ballooning specially with disable OOM, what happens other
> processes requires memory at same time? Should they wait for balloon
> driver to release memory?
>
> I don't know your point. Sorry.
> Could you explain your scenario in detail for justify your idea?

What you said make sense I understand what you said now. Lets ignore
my above argue and see what I'm actually doing.

I'm hacking with balloon driver to fit to short the vm migration time.

while migrating host tell guest to balloon as much memory as it can, then start
migrate, just skip the ballooned pages, after migration done tell
guest to release the memory.

In migration case oom is not I want to see and disable oom will be good.

> And as I previous said, we have to solve oom_killer_disabled issue in
> do_try_to_free_pages.
>
> Thanks, Dave.
> --
> Kind regards,
> Minchan Kim
>



-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
