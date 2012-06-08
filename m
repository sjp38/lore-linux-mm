Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 524276B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 22:32:24 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so801511qcs.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 19:32:23 -0700 (PDT)
Message-ID: <4FD16436.1010502@gmail.com>
Date: Thu, 07 Jun 2012 22:32:22 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] proc: add /proc/kpageorder interface
References: <201206011854.25795.b.zolnierkie@samsung.com> <201206041023.22937.b.zolnierkie@samsung.com> <4FCD0D0D.9050003@gmail.com> <201206061023.13237.b.zolnierkie@samsung.com>
In-Reply-To: <201206061023.13237.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

(6/6/12 4:23 AM), Bartlomiej Zolnierkiewicz wrote:
> On Monday 04 June 2012 21:31:25 KOSAKI Motohiro wrote:
>> (6/4/12 4:23 AM), Bartlomiej Zolnierkiewicz wrote:
>>> On Friday 01 June 2012 22:31:01 KOSAKI Motohiro wrote:
>>>> (6/1/12 12:54 PM), Bartlomiej Zolnierkiewicz wrote:
>>>>> From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
>>>>> Subject: [PATCH] proc: add /proc/kpageorder interface
>>>>>
>>>>> This makes page order information available to the user-space.
>>>>
>>>> No usecase new feature always should be NAKed.
>>>
>>> It is used to get page orders for Buddy pages and help to monitor
>>> free/used pages.  Sample usage will be posted for inclusion to
>>> Pagemap Demo tools (http://selenic.com/repo/pagemap/).
>>>
>>> The similar situation is with /proc/kpagetype..
>>
>> NAK then.
>>
>> First, your explanation didn't describe any usecase. "There is a similar feature"
>> is NOT a usecase.
>>
>> Second, /proc/kpagetype is one of mistaken feature. It was not designed deeply.
>> We have no reason to follow the mistake.
>
> Well, my usecase for /proc/kpagetype is to monitor/debug pageblock changes
> (i.e. to verify CMA and compaction operations).  It is not perfect since
> interface gives us only a snapshot of pageblocks state at some random time.
> However it is a straightforward method and requires only minimal changes
> to the existing code.
>
> Maybe there is a better way to do this which would give a more accurate
> data and capture every state change (maybe a one involving tracing?) but
> I don't know about it.  Do you know such better way to do it?

To export bare data structure and to export statistics are completely different.
When you need statistics, you should implement to mere stat. Data structure exporting
have significant two dawonsides. 1) they are often bring us security issue and 2)
they easily become a source of kernel enhancement blocker. because we can't break ABIs
forever.


>> Third, pagemap demo doesn't describe YOUR feature's usefull at all.
>
> pagemap demo doesn't include my patches for /proc/kpage[order,type] yet
> so it is not surprising at all (it doesn't even work with current kernels
> without my other patches).. ;)
>
>> Fourth, pagemap demo is NOT useful at all. It's just toy. Practically, kpagetype
>> is only used from pagetype tool.
>
> I don't quite follow it, what pagetype tool are you referring to (kpagetype
> is a new interface)?

pagetype show a _stastics_. then nobody uses pfn internal structure.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
