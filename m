Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id CF0326B005D
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 15:31:29 -0400 (EDT)
Received: by qabg27 with SMTP id g27so1956959qab.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 12:31:28 -0700 (PDT)
Message-ID: <4FCD0D0D.9050003@gmail.com>
Date: Mon, 04 Jun 2012 15:31:25 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] proc: add /proc/kpageorder interface
References: <201206011854.25795.b.zolnierkie@samsung.com> <4FC92685.9070604@gmail.com> <201206041023.22937.b.zolnierkie@samsung.com>
In-Reply-To: <201206041023.22937.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

(6/4/12 4:23 AM), Bartlomiej Zolnierkiewicz wrote:
> On Friday 01 June 2012 22:31:01 KOSAKI Motohiro wrote:
>> (6/1/12 12:54 PM), Bartlomiej Zolnierkiewicz wrote:
>>> From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
>>> Subject: [PATCH] proc: add /proc/kpageorder interface
>>>
>>> This makes page order information available to the user-space.
>>
>> No usecase new feature always should be NAKed.
>
> It is used to get page orders for Buddy pages and help to monitor
> free/used pages.  Sample usage will be posted for inclusion to
> Pagemap Demo tools (http://selenic.com/repo/pagemap/).
>
> The similar situation is with /proc/kpagetype..

NAK then.

First, your explanation didn't describe any usecase. "There is a similar feature"
is NOT a usecase.

Second, /proc/kpagetype is one of mistaken feature. It was not designed deeply.
We have no reason to follow the mistake.

Third, pagemap demo doesn't describe YOUR feature's usefull at all.

Fourth, pagemap demo is NOT useful at all. It's just toy. Practically, kpagetype
is only used from pagetype tool.

Firnally, you have to learn what "usecase" mean.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
