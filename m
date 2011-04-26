Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6FF3D9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 19:33:47 -0400 (EDT)
Received: by vxk20 with SMTP id 20so1284559vxk.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:33:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTin0wj3AhCtR5ZD=N_LUKjE1etBcFg@mail.gmail.com>
References: <20110426085953.GA12389@darkstar>
	<BANLkTikkUq7rg4umYQ5yt9ve+q34Pf+=Ag@mail.gmail.com>
	<BANLkTin0wj3AhCtR5ZD=N_LUKjE1etBcFg@mail.gmail.com>
Date: Wed, 27 Apr 2011 08:33:46 +0900
Message-ID: <BANLkTim067_+bycA-rJk6u595YucMmruqQ@mail.gmail.com>
Subject: Re: [PATCH v2] virtio_balloon: disable oom killer when fill balloon
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>

On Tue, Apr 26, 2011 at 6:39 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
> On Tue, Apr 26, 2011 at 5:28 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
>> Please resend this with [2/2] to linux-mm.
>>
>> On Tue, Apr 26, 2011 at 5:59 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
>>> When memory pressure is high, virtio ballooning will probably cause oom killing.
>>> Even if alloc_page with GFP_NORETRY itself does not directly trigger oom it
>>> will make memory becoming low then memory alloc of other processes will trigger
>>> oom killing. It is not desired behaviour.
>>
>> I can't understand why it is undesirable.
>> Why do we have to handle it specially?
>>
>
> Suppose user run some random memory hogging process while ballooning
> it will be undesirable.


In VM POV, kvm and random memory hogging processes are customers.
If we handle ballooning specially with disable OOM, what happens other
processes requires memory at same time? Should they wait for balloon
driver to release memory?

I don't know your point. Sorry.
Could you explain your scenario in detail for justify your idea?
And as I previous said, we have to solve oom_killer_disabled issue in
do_try_to_free_pages.

Thanks, Dave.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
