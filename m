Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A7CAA6B006E
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 17:29:50 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so10122179pdb.14
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 14:29:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bs8si11935349pad.340.2014.04.01.14.29.48
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 14:29:49 -0700 (PDT)
Date: Tue, 1 Apr 2014 14:29:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Message-Id: <20140401142947.927642a408d84df27d581e36@linux-foundation.org>
In-Reply-To: <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	<20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
	<1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	<20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	<1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
	<20140331170546.3b3e72f0.akpm@linux-foundation.org>
	<1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
	<CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
	<1396377083.25314.17.camel@buesod1.americas.hpqcorp.net>
	<CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
	<1396386062.25314.24.camel@buesod1.americas.hpqcorp.net>
	<CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 1 Apr 2014 17:12:50 -0400 KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> On Tue, Apr 1, 2014 at 5:01 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > On Tue, 2014-04-01 at 15:51 -0400, KOSAKI Motohiro wrote:
> >> >> So, I personally like 0 byte per default.
> >> >
> >> > If by this you mean 0 bytes == unlimited, then I agree. It's less harsh
> >> > then removing it entirely. So instead of removing the limit we can just
> >> > set it by default to 0, and in newseg() if shm_ctlmax == 0 then we don't
> >> > return EINVAL if the passed size is great (obviously), otherwise, if the
> >> > user _explicitly_ set it via sysctl then we respect that. Andrew, do you
> >> > agree with this? If so I'll send a patch.
> >>
> >> Yes, my 0 bytes mean unlimited. I totally agree we shouldn't remove the knob
> >> entirely.
> >
> > Hmmm so 0 won't really work because it could be weirdly used to disable
> > shm altogether... we cannot go to some negative value either since we're
> > dealing with unsigned, and cutting the range in half could also hurt
> > users that set the limit above that. So I was thinking of simply setting
> > SHMMAX to ULONG_MAX and be done with it. Users can then set it manually
> > if they want a smaller value.
> >
> > Makes sense?
> 
> I don't think people use 0 for disabling. but ULONG_MAX make sense to me too.

Distros could have set it to [U]LONG_MAX in initscripts ten years ago
- less phone calls, happier customers.  And they could do so today.

But they haven't.   What are the risks of doing this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
