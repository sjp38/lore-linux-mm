Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 833436B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 19:06:50 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id gq1so15619529obb.9
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:06:50 -0800 (PST)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id r4si6369074obk.41.2015.01.09.16.06.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 16:06:48 -0800 (PST)
Received: by mail-oi0-f52.google.com with SMTP id a3so14154240oib.11
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:06:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA25o9SQfb3yO2D4ABeeYoZkurhxramAgckr9DVOG1=DwVF0qg@mail.gmail.com>
References: <CAA25o9Sf62u3mJtBp_swLL0RS2Zb=EjZtWERJqyrbBpk7-bP-A@mail.gmail.com>
	<20150108223024.da818218.akpm@linux-foundation.org>
	<CAA25o9SQfb3yO2D4ABeeYoZkurhxramAgckr9DVOG1=DwVF0qg@mail.gmail.com>
Date: Sat, 10 Jan 2015 09:06:48 +0900
Message-ID: <CAAmzW4Oqo7KoYD5Mx+jVpo1Yt3xSt+vKuTSgf=AMXsu-nRDtwQ@mail.gmail.com>
Subject: Re: mm performance with zram
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

2015-01-10 1:45 GMT+09:00 Luigi Semenzato <semenzato@google.com>:
> On Thu, Jan 8, 2015 at 10:30 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Thu, 8 Jan 2015 14:49:45 -0800 Luigi Semenzato <semenzato@google.com> wrote:
>>
>>> I am taking a closer look at the performance of the Linux MM in the
>>> context of heavy zram usage.  The bottom line is that there is
>>> surprisingly high overhead (35-40%) from MM code other than
>>> compression/decompression routines.
>>
>> Those images hurt my eyes.
>
> Sorry about that.  I didn't find other ways of computing the
> cumulative cost of functions (i.e. time spent in a function and all
> its descendants, like in gprof).  I couldn't get perf to do that
> either.  A flat profile shows most functions take a fracion of 1%, so
> it's not useful.  If anybody knows a better way I'll be glad to use
> it.

Hello,

Recent version of perf has an ability to compute cumulative cost of functions.
And, it's a default configuration. :)
If you change your perf to recent version, you can easily get the data.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
