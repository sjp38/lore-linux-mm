Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id CBC176B0062
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 17:13:11 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id gq1so11807125obb.32
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 14:13:11 -0700 (PDT)
Received: from mail-oa0-x235.google.com (mail-oa0-x235.google.com [2607:f8b0:4003:c02::235])
        by mx.google.com with ESMTPS id a1si12978695oed.71.2014.04.01.14.13.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 14:13:11 -0700 (PDT)
Received: by mail-oa0-f53.google.com with SMTP id j17so11711426oag.26
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 14:13:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
 <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net> <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org>
 <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net> <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
 <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
 <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 1 Apr 2014 17:12:50 -0400
Message-ID: <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Apr 1, 2014 at 5:01 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> On Tue, 2014-04-01 at 15:51 -0400, KOSAKI Motohiro wrote:
>> >> So, I personally like 0 byte per default.
>> >
>> > If by this you mean 0 bytes == unlimited, then I agree. It's less harsh
>> > then removing it entirely. So instead of removing the limit we can just
>> > set it by default to 0, and in newseg() if shm_ctlmax == 0 then we don't
>> > return EINVAL if the passed size is great (obviously), otherwise, if the
>> > user _explicitly_ set it via sysctl then we respect that. Andrew, do you
>> > agree with this? If so I'll send a patch.
>>
>> Yes, my 0 bytes mean unlimited. I totally agree we shouldn't remove the knob
>> entirely.
>
> Hmmm so 0 won't really work because it could be weirdly used to disable
> shm altogether... we cannot go to some negative value either since we're
> dealing with unsigned, and cutting the range in half could also hurt
> users that set the limit above that. So I was thinking of simply setting
> SHMMAX to ULONG_MAX and be done with it. Users can then set it manually
> if they want a smaller value.
>
> Makes sense?

I don't think people use 0 for disabling. but ULONG_MAX make sense to me too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
