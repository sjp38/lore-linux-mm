Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id A571E6B0096
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 12:41:23 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so873414eek.30
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 09:41:23 -0700 (PDT)
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
        by mx.google.com with ESMTPS id u49si36014774eef.352.2014.04.17.09.41.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Apr 2014 09:41:22 -0700 (PDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so848233eek.25
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 09:41:21 -0700 (PDT)
Message-ID: <5350042F.4040904@colorfullife.com>
Date: Thu, 17 Apr 2014 18:41:19 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org> <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net> <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com> <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com> <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com> <20140401142947.927642a408d84df27d581e36@linux-foundation.org> <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com> <20140401144801.603c288674ab8f417b42a043@linux-foundation.org> <1396389751.25314.26.camel@buesod1.americas.hpqcorp.net> <20140401150843.13da3743554ad541629c936d@linux-foundation.org> <534AD1EE.3050705@colorfullife.com> <20140416154631.6d0173498c60619d454ae651@linux-foundation.org> <CAHO5Pa2zguBEpg-S0Zx26qEStF5ZyvrnbU8-sQZfNJEZRMQPqg@mail.gmail.com>
In-Reply-To: <CAHO5Pa2zguBEpg-S0Zx26qEStF5ZyvrnbU8-sQZfNJEZRMQPqg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/17/2014 12:41 PM, Michael Kerrisk wrote:
> On Thu, Apr 17, 2014 at 12:46 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Sun, 13 Apr 2014 20:05:34 +0200 Manfred Spraul <manfred@colorfullife.com> wrote:
>>
>>> Hi Andrew,
>>>
>>> On 04/02/2014 12:08 AM, Andrew Morton wrote:
>>>> Well, I'm assuming 64GB==infinity. It *was* infinity in the RHEL5
>>>> timeframe, but infinity has since become larger so pickanumber.
>>> I think infinity is the right solution:
>>> The only common case where infinity is wrong would be Android - and
>>> Android disables sysv shm entirely.
>>>
>>> There are two patches:
>>> http://marc.info/?l=linux-kernel&m=139730332306185&q=raw
>>> http://marc.info/?l=linux-kernel&m=139727299800644&q=raw
>>>
>>> Could you apply one of them?
>>> I wrote the first one, thus I'm biased which one is better.
>> I like your patch because applying it might encourage you to send more
>> kernel patches - I miss the old days ;)
>>
>> But I do worry about disrupting existing systems so I like Davidlohr's
>> idea of making the change a no-op for people who are currently
>> explicitly setting shmmax and shmall.
> Agreed. It's hard to imagine situations where people might care
> nowadays, but there's no limits to people's insane inventiveness. Some
> people really might want to set an upper limit.
I don't understand that: neither patch has any impact after an explicit 
sysctl that overwrites shmmax.

>> In an ideal world, system administrators would review this change,
> And in the ideal world, patches such as this would CC
> linux-api@vger.kernel.org, as described in
> Documentation/SubmitChecklist, so that users who care about getting
> advance warning on API changes could be alerted and might even review
> and comment...
Good point.
Davidlohr: Your patch has an impact on shmctl(,IPC_INFO,).
Could you add that for v3?

I'll try to make a v2 (with your update to the uapi header file) tomorrow.

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
