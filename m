Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7F5226B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 02:11:20 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id 9so1610193iec.8
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 23:11:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <517726C8.4030207@linaro.org>
References: <516EE256.2070303@linaro.org>
	<5175FBEB.4020809@linaro.org>
	<CACT4Y+a+r8LqiiGfq3rTiwGbacLJ0P+tWVba+G5vVyrikkr+gw@mail.gmail.com>
	<517726C8.4030207@linaro.org>
Date: Wed, 24 Apr 2013 10:11:19 +0400
Message-ID: <CACT4Y+YBkgXKSYEHfBs4ayrhJbG68tzMG6i9_c3n+S=Z0+1QXA@mail.gmail.com>
Subject: Re: Summary of LSF-MM Volatile Ranges Discussion
From: Dmitry Vyukov <dvyukov@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Paul Turner <pjt@google.com>, Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Taras Glek <tglek@mozilla.com>, Mike Hommey <mh@glandium.org>, Kostya Serebryany <kcc@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Rik van Riel <riel@redhat.com>, glommer@parallels.com, mhocko@suse.de

On Wed, Apr 24, 2013 at 4:26 AM, John Stultz <john.stultz@linaro.org> wrote:
> On 04/22/2013 11:51 PM, Dmitry Vyukov wrote:
>>
>> Just want to make sure our case does not fall out of the discussion:
>> https://code.google.com/p/thread-sanitizer/wiki/VolatileRanges
>
>
> Yes, while I forgot to mention it in the summary, I did bring it up briefly,
> but I cannot claim to have done it justice.

Thanks!

> Personally, while I suspect we might be able to support your desired
> semantics (ie: mark once volatile, always zero-fill, no sigbus) via a mode
> flag
>
>
>> While reading your email, I remembered that we actually have some
>> pages mapped from a file inside the range. So it's like 70TB of ANON
>> mapping + few pages in the middle mapped from FILE. The file is mapped
>> with MAP_PRIVATE + PROT_READ, it's read-only and not shared.
>> But we want to mark the volatile range only once on startup, so
>> performance is not a serious concern (while the function in executed
>> in say no more than 10ms).
>> If the mixed ANON+FILE ranges becomes a serious problem, we are ready
>> to remove FILE mappings, because it's only an optimization. I.e. we
>> can make it pure ANON mapping.
>
> Well, in my mind, the MAP_PRIVATE mappings are semantically the same as
> anonymous memory with regards to volatility. So I hope this wouldn't be an
> issue.

Ah, I see, so you more concerned about SHARED rather than FILE. We do
NOT have any SHARED regions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
