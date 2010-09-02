Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A43A76B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 23:18:28 -0400 (EDT)
Received: by iwn33 with SMTP id 33so56714iwn.14
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 20:18:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100902115640.D071.A69D9226@jp.fujitsu.com>
References: <20100902091206.D053.A69D9226@jp.fujitsu.com>
	<AANLkTiknTqHw11xRXNP4X-0yN1=rWyCh3MJV=HjRiZQJ@mail.gmail.com>
	<20100902115640.D071.A69D9226@jp.fujitsu.com>
Date: Thu, 2 Sep 2010 12:18:27 +0900
Message-ID: <AANLkTi=DrT1QUTPoUOVBt-d+b-4N_JGDDzaxZqrujD7P@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] vmscan: don't use return value trick when oom_killer_disabled
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, "M. Vefa Bicakci" <bicave@superonline.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 2, 2010 at 12:05 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > I don't want to send risky patch to -stable.
>>
>> Still I don't want to use oom_killer_disabled magic.
>> But I don't want to prevent urgent stable patch due to my just nitpick.
>>
>> This is my last try(just quick patch, even I didn't tried compile test).
>
> Looks like conceptually correct. If you will test it and fix whitespace damage,
> I'll ack this one gladly.
>
> Thanks.
>

I will resend formal patch ASAP. Maybe tonight after out of office.
Thanks for quick reply.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
