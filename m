Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 382D46B008C
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 19:56:41 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id uy5so11899122obc.6
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 16:56:40 -0700 (PDT)
Received: from mail-oa0-x22d.google.com (mail-oa0-x22d.google.com [2607:f8b0:4003:c02::22d])
        by mx.google.com with ESMTPS id we10si91275obc.111.2014.04.01.16.56.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 16:56:39 -0700 (PDT)
Received: by mail-oa0-f45.google.com with SMTP id eb12so12116755oac.18
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 16:56:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
 <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net> <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org>
 <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net> <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
 <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
 <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
 <20140401142947.927642a408d84df27d581e36@linux-foundation.org>
 <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com>
 <20140401144801.603c288674ab8f417b42a043@linux-foundation.org>
 <CAHGf_=r5AUu6yvJgOzwYDghBo6iT2q+nNumpvqwer+igcfChrA@mail.gmail.com> <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 1 Apr 2014 19:56:18 -0400
Message-ID: <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>> > Ah-hah, that's interesting info.
>> >
>> > Let's make the default 64GB?
>>
>> 64GB is infinity at that time, but it no longer near infinity today. I like
>> very large or total memory proportional number.
>
> So I still like 0 for unlimited. Nice, clean and much easier to look at
> than ULONG_MAX. And since we cannot disable shm through SHMMIN, I really
> don't see any disadvantages, as opposed to some other arbitrary value.
> Furthermore it wouldn't break userspace: any existing sysctl would
> continue to work, and if not set, the user never has to worry about this
> tunable again.
>
> Please let me know if you all agree with this...

Surething. Why not. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
