Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86277C3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 07:28:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20B4A22DBF
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 07:28:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="BRXYASXf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20B4A22DBF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 823E26B0003; Tue,  3 Sep 2019 03:28:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D42D6B0005; Tue,  3 Sep 2019 03:28:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C1EE6B0006; Tue,  3 Sep 2019 03:28:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0154.hostedemail.com [216.40.44.154])
	by kanga.kvack.org (Postfix) with ESMTP id 45E036B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 03:28:36 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C9F6F824CA3A
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 07:28:35 +0000 (UTC)
X-FDA: 75892781790.09.wound77_6819f60cfc94f
X-HE-Tag: wound77_6819f60cfc94f
X-Filterd-Recvd-Size: 7528
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 07:28:35 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id 100so15789573otn.2
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 00:28:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UdMoRPg0KlVqze0pTkNC9rfXaDd7uPSTe82szx43jMg=;
        b=BRXYASXfXrSYdvQ7cHvdL8g1FGYY5yc7fn4k3rf1HqK5cdyf7DVE1ZRs2ggL6FBlZY
         jhOxSfrYQhY9BD157Pi5jnSxIhZjG9EG4xisQBVknT3mt+l8TxsfMTbDpomdpXG0MF88
         /Ul9+UZc5rqz3oUInM3tk4DRzAXTmO9p25Eds=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=UdMoRPg0KlVqze0pTkNC9rfXaDd7uPSTe82szx43jMg=;
        b=J2iJYw8RoX9HBZVLTmiqQmXPOZzWtVf00l/2tDten3mkp+IceBhVnYH5Ws/+uzFvUq
         i9c/ydujxlUAV2lHKDP1/aHk/44M6RV2nN1MtiHbpscOsIzR5UbkvEbcf3EQgFl49fdq
         Yd0vbwJSIAN89OaisjAVJ/xyKsqfX5iRBk+AAm9Fjcn4OyRubjlU9hZI/TftLvgTQfx8
         TyFKAuxFjOQT6L9bgXwiqt49bpC36myWeEdMxLWEdS4tAa+O+Tnb6Jbs1hiK2ioCutWX
         n4JN6kiLWgcAP3dkse/J/0IR4BuqsphmgqXe4okfL0ALsVt6dZzxSYD/Pvkfzi802Qn3
         8PlQ==
X-Gm-Message-State: APjAAAWojAgIUt8SBOr4lNoRSCxx4g+PksGn9adoH7ZoIxeiGSHPcGon
	a9OTz2LRAAlOjfbzvd+ixEm0nxE0p7xzWmAsbIAJMA==
X-Google-Smtp-Source: APXvYqxNdE/m5cDoeoduzif078Rn/h+XzpbDyvLbalFH6g7b9CtJip46QdskaojSElyMHAM5lUrtBDY5YQw43Yn2gis=
X-Received: by 2002:a05:6830:1594:: with SMTP id i20mr1193992otr.188.1567495714412;
 Tue, 03 Sep 2019 00:28:34 -0700 (PDT)
MIME-Version: 1.0
References: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
 <20190826201425.17547-4-daniel.vetter@ffwll.ch> <20190827225002.GB30700@ziepe.ca>
 <CAKMK7uHKiLwXLHd1xThZVM1dH-oKrtpDZ=FxLBBwtY7XmJKgtA@mail.gmail.com>
 <20190828184330.GD933@ziepe.ca> <CAKMK7uFJESH1XHTCqYoDb4iMfThxnib3Uz=RUcd7h=SS-TJWbg@mail.gmail.com>
In-Reply-To: <CAKMK7uFJESH1XHTCqYoDb4iMfThxnib3Uz=RUcd7h=SS-TJWbg@mail.gmail.com>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Tue, 3 Sep 2019 09:28:23 +0200
Message-ID: <CAKMK7uET7GL-nmRd_wxkxu0KsiYiSZcGTsSstcUpqaT=mKTbmg@mail.gmail.com>
Subject: Re: [PATCH 3/5] kernel.h: Add non_block_start/end()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, Peter Zijlstra <peterz@infradead.org>, 
	Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, 
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

On Wed, Aug 28, 2019 at 8:56 PM Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
> On Wed, Aug 28, 2019 at 8:43 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > On Wed, Aug 28, 2019 at 08:33:13PM +0200, Daniel Vetter wrote:
> > > On Wed, Aug 28, 2019 at 12:50 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > >
> > > > > diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> > > > > index 4fa360a13c1e..82f84cfe372f 100644
> > > > > +++ b/include/linux/kernel.h
> > > > > @@ -217,7 +217,9 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
> > > > >   * might_sleep - annotation for functions that can sleep
> > > > >   *
> > > > >   * this macro will print a stack trace if it is executed in an atomic
> > > > > - * context (spinlock, irq-handler, ...).
> > > > > + * context (spinlock, irq-handler, ...). Additional sections where blocking is
> > > > > + * not allowed can be annotated with non_block_start() and non_block_end()
> > > > > + * pairs.
> > > > >   *
> > > > >   * This is a useful debugging help to be able to catch problems early and not
> > > > >   * be bitten later when the calling function happens to sleep when it is not
> > > > > @@ -233,6 +235,25 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
> > > > >  # define cant_sleep() \
> > > > >       do { __cant_sleep(__FILE__, __LINE__, 0); } while (0)
> > > > >  # define sched_annotate_sleep()      (current->task_state_change = 0)
> > > > > +/**
> > > > > + * non_block_start - annotate the start of section where sleeping is prohibited
> > > > > + *
> > > > > + * This is on behalf of the oom reaper, specifically when it is calling the mmu
> > > > > + * notifiers. The problem is that if the notifier were to block on, for example,
> > > > > + * mutex_lock() and if the process which holds that mutex were to perform a
> > > > > + * sleeping memory allocation, the oom reaper is now blocked on completion of
> > > > > + * that memory allocation. Other blocking calls like wait_event() pose similar
> > > > > + * issues.
> > > > > + */
> > > > > +# define non_block_start() \
> > > > > +     do { current->non_block_count++; } while (0)
> > > > > +/**
> > > > > + * non_block_end - annotate the end of section where sleeping is prohibited
> > > > > + *
> > > > > + * Closes a section opened by non_block_start().
> > > > > + */
> > > > > +# define non_block_end() \
> > > > > +     do { WARN_ON(current->non_block_count-- == 0); } while (0)
> > > >
> > > > check-patch does not like these, and I agree
> > > >
> > > > #101: FILE: include/linux/kernel.h:248:
> > > > +# define non_block_start() \
> > > > +       do { current->non_block_count++; } while (0)
> > > >
> > > > /tmp/tmp1spfxufy/0006-kernel-h-Add-non_block_start-end-.patch:108: WARNING: Single statement macros should not use a do {} while (0) loop
> > > > #108: FILE: include/linux/kernel.h:255:
> > > > +# define non_block_end() \
> > > > +       do { WARN_ON(current->non_block_count-- == 0); } while (0)
> > > >
> > > > Please use a static inline?
> > >
> > > We need get_current() plus the task_struct, so this gets real messy
> > > real fast. Not even sure which header this would fit in, or whether
> > > I'd need to create a new one. You're insisting on this or respinning
> > > with the do { } while (0) dropped ok.
> >
> > My prefernce is always a static inline, but if the headers are so
> > twisty we need to use #define to solve a missing include, then I
> > wouldn't insist on it.
>
> Cleanest would be a new header I guess, together with might_sleep().
> But moving that is a bit much I think, there's almost 500 callers of
> that one from a quick git grep
>
> > If dropping do while is the only change then I can edit it in..
> > I think we have the acks now
>
> Yeah sounds simplest, thanks.

Hi Jason,

Do you expect me to resend now, or do you plan to do the patchwork
appeasement when applying? I've seen you merged the other patches
(thanks!), but not these two here.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

