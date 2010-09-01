Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CA59F6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 22:01:45 -0400 (EDT)
Received: by iwn33 with SMTP id 33so8749174iwn.14
        for <linux-mm@kvack.org>; Tue, 31 Aug 2010 19:01:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100901105232.974F.A69D9226@jp.fujitsu.com>
References: <20100901092430.9741.A69D9226@jp.fujitsu.com>
	<AANLkTikXfvEVXEyw_5_eJs2v-3J6Xhd=CT9X-0D+GMCA@mail.gmail.com>
	<20100901105232.974F.A69D9226@jp.fujitsu.com>
Date: Wed, 1 Sep 2010 11:01:43 +0900
Message-ID: <AANLkTinxHbeCUh80i515FPMpF-GY4S0kh9PHqUNtYP-m@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] vmscan: don't use return value trick when oom_killer_disabled
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 1, 2010 at 10:55 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
> Thank you for good commenting!
>
>
>> I don't like use oom_killer_disabled directly.
>> That's because we have wrapper inline functions to handle the
>> variable(ex, oom_killer_[disable/enable]).
>> It means we are reluctant to use the global variable directly.
>> So should we make new function as is_oom_killer_disable?
>>
>> I think NO.
>>
>> As I read your description, this problem is related to only hibernation.
>> Since hibernation freezes all processes(include kswapd), this problem
>> happens. Of course, now oom_killer_disabled is used by only
>> hibernation. But it can be used others in future(Off-topic : I don't
>> want it). Others can use it without freezing processes. Then kswapd
>> can set zone->all_unreclaimable and the problem can't happen.
>>
>> So I want to use sc->hibernation_mode which is already used
>> do_try_to_free_pages instead of oom_killer_disabled.
>
> Unfortunatelly, It's impossible. shrink_all_memory() turn on
> sc->hibernation_mode. but other hibernation caller merely call
> alloc_pages(). so we don't have any hint.
>
Ahh.. True. Sorry for that.
I will think some better method.
if I can't find it, I don't mind this patch. :)

Thanks.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
