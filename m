Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B038C41514
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 13:43:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79F7522CE3
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 13:43:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="gyrMKzTu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79F7522CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 254CA6B0494; Fri, 23 Aug 2019 09:43:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 205E36B0495; Fri, 23 Aug 2019 09:43:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F42A6B0496; Fri, 23 Aug 2019 09:43:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0155.hostedemail.com [216.40.44.155])
	by kanga.kvack.org (Postfix) with ESMTP id E3EA66B0494
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 09:43:00 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9665C824CA3B
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 13:43:00 +0000 (UTC)
X-FDA: 75853808520.25.fork81_7182b8ed4733c
X-HE-Tag: fork81_7182b8ed4733c
X-Filterd-Recvd-Size: 5385
Received: from mail-oi1-f194.google.com (mail-oi1-f194.google.com [209.85.167.194])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 13:42:59 +0000 (UTC)
Received: by mail-oi1-f194.google.com with SMTP id t24so6982936oij.13
        for <linux-mm@kvack.org>; Fri, 23 Aug 2019 06:42:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Jw7xTqZljvWDt+gH2lHnnIUkh+OWb2dqWCVggLcTb1s=;
        b=gyrMKzTuaWrnNIRBDm50i6quBqIz1bhUm1Gm6/8s2kaFviG+TeyKizbVwp8QsZDsg9
         cB0yBjxUh49n7gzOZcU+eGE8vbuKolbVIShRQc6ouMetE6nFGOVR3MppH+/tnYO3Zrlc
         UH0SHALg7tcmzdDG2FTfNdvvTV0I/BMmNjbSw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Jw7xTqZljvWDt+gH2lHnnIUkh+OWb2dqWCVggLcTb1s=;
        b=JGzjEogT2RGU3d1jaRCv1mf4JAGnn/unUm5g1BdF49qki32ywo5Uh1E2BAcczqwASO
         rKNonK32nK0nSCia3JOBEgGvciIU5Del8Br5ntlibN8av150EE6JQi6MKiwED82aIXXy
         brfHsW6kmXuojijAaxDOYrTVg3PodRrxpUqiqWNK22F6P0KxAA6JQIXMDjjW/Ai6XSel
         Y1k0Pwf7taSOC4ApzM2XgBTC6MrdukuCguEq8erD1R3iWJyQ+7NC+nLbhevrx9PopJo4
         9AAqhbd4nNrcdyN6YWCMtEoHoIXozOfF/iObQC0ERsfMJU+detnDAVgyIvBrCF7OrEFD
         gNog==
X-Gm-Message-State: APjAAAXfpfJv1bElu90IiVbqG/xbkxfXpdd/OkZPErT+2G9boyb2BK+/
	MuxoTSAoFX1iqK8wAQGn8avB6K+f46nYgflFA+4Z7A==
X-Google-Smtp-Source: APXvYqw+eNygtffssBOBe6S8vbVTEOL5pWoEIu5RbBvwqcrgjAiCt8BJn2VrxejfsbAbB+/zEvTuexyQmTMFvMUOjmE=
X-Received: by 2002:aca:da08:: with SMTP id r8mr3001623oig.101.1566567779012;
 Fri, 23 Aug 2019 06:42:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-4-daniel.vetter@ffwll.ch> <20190820202440.GH11147@phenom.ffwll.local>
 <20190822161428.c9e4479207386d34745ea111@linux-foundation.org>
 <CAKMK7uGw_7uD=wH3bcR9xXSxAcAuYTLOZt3ue4TEvst1D0KzLQ@mail.gmail.com> <20190823121234.GB12968@ziepe.ca>
In-Reply-To: <20190823121234.GB12968@ziepe.ca>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Fri, 23 Aug 2019 15:42:47 +0200
Message-ID: <CAKMK7uHzSkd2j4MvSMoHhCaSE0BT0zMo9osF4FUBYwNZrVfYDA@mail.gmail.com>
Subject: Re: [PATCH 3/4] kernel.h: Add non_block_start/end()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, DRI Development <dri-devel@lists.freedesktop.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Peter Zijlstra <peterz@infradead.org>, 
	Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Wei Wang <wvw@google.com>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Jann Horn <jannh@google.com>, Feng Tang <feng.tang@intel.com>, 
	Kees Cook <keescook@chromium.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Daniel Vetter <daniel.vetter@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 2:12 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Fri, Aug 23, 2019 at 10:34:01AM +0200, Daniel Vetter wrote:
> > On Fri, Aug 23, 2019 at 1:14 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > On Tue, 20 Aug 2019 22:24:40 +0200 Daniel Vetter <daniel@ffwll.ch> wrote:
> > >
> > > > Hi Peter,
> > > >
> > > > Iirc you've been involved at least somewhat in discussing this. -mm folks
> > > > are a bit undecided whether these new non_block semantics are a good idea.
> > > > Michal Hocko still is in support, but Andrew Morton and Jason Gunthorpe
> > > > are less enthusiastic. Jason said he's ok with merging the hmm side of
> > > > this if scheduler folks ack. If not, then I'll respin with the
> > > > preempt_disable/enable instead like in v1.
> > >
> > > I became mollified once Michel explained the rationale.  I think it's
> > > OK.  It's very specific to the oom reaper and hopefully won't be used
> > > more widely(?).
> >
> > Yeah, no plans for that from me. And I hope the comment above them now
> > explains why they exist, so people think twice before using it in
> > random places.
>
> I still haven't heard a satisfactory answer why a whole new scheme is
> needed and a simple:
>
>    if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP))
>         preempt_disable()
>
> isn't sufficient to catch the problematic cases during debugging??
> IMHO the fact preempt is changed by the above when debugging is not
> material here. I think that information should be included in the
> commit message at least.
>
> But if sched people are happy then lets go ahead. Can you send a v2
> with the check encompassing the invalidate_range_end?

Yes I will resend with this patch plus the next, amended as we
discussed, plus the might_sleep annotations. I'm assuming the lockdep
one will land, so not going to resend that.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

