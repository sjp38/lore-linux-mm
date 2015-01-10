Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id C08C56B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 19:19:56 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id hq11so4161979vcb.9
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:19:56 -0800 (PST)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com. [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id h2si4630064vcf.79.2015.01.09.16.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 16:19:55 -0800 (PST)
Received: by mail-vc0-f182.google.com with SMTP id hq12so4121357vcb.13
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:19:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4Oqo7KoYD5Mx+jVpo1Yt3xSt+vKuTSgf=AMXsu-nRDtwQ@mail.gmail.com>
References: <CAA25o9Sf62u3mJtBp_swLL0RS2Zb=EjZtWERJqyrbBpk7-bP-A@mail.gmail.com>
	<20150108223024.da818218.akpm@linux-foundation.org>
	<CAA25o9SQfb3yO2D4ABeeYoZkurhxramAgckr9DVOG1=DwVF0qg@mail.gmail.com>
	<CAAmzW4Oqo7KoYD5Mx+jVpo1Yt3xSt+vKuTSgf=AMXsu-nRDtwQ@mail.gmail.com>
Date: Fri, 9 Jan 2015 16:19:55 -0800
Message-ID: <CAA25o9T=sif3COXWK58OsCJW5ZM-7WgsREq3CW1mfPPv+K_Dgg@mail.gmail.com>
Subject: Re: mm performance with zram
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Thank you!  I am using perf version 3.13.11.10, will look for newer versions.

On Fri, Jan 9, 2015 at 4:06 PM, Joonsoo Kim <js1304@gmail.com> wrote:
> 2015-01-10 1:45 GMT+09:00 Luigi Semenzato <semenzato@google.com>:
>> On Thu, Jan 8, 2015 at 10:30 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>>> On Thu, 8 Jan 2015 14:49:45 -0800 Luigi Semenzato <semenzato@google.com> wrote:
>>>
>>>> I am taking a closer look at the performance of the Linux MM in the
>>>> context of heavy zram usage.  The bottom line is that there is
>>>> surprisingly high overhead (35-40%) from MM code other than
>>>> compression/decompression routines.
>>>
>>> Those images hurt my eyes.
>>
>> Sorry about that.  I didn't find other ways of computing the
>> cumulative cost of functions (i.e. time spent in a function and all
>> its descendants, like in gprof).  I couldn't get perf to do that
>> either.  A flat profile shows most functions take a fracion of 1%, so
>> it's not useful.  If anybody knows a better way I'll be glad to use
>> it.
>
> Hello,
>
> Recent version of perf has an ability to compute cumulative cost of functions.
> And, it's a default configuration. :)
> If you change your perf to recent version, you can easily get the data.
>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
