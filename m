Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BC35C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:21:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1CE8206C1
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:21:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="UVlNUshc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1CE8206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58C6C6B0003; Fri, 16 Aug 2019 02:21:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 516276B0006; Fri, 16 Aug 2019 02:21:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DC7F6B0007; Fri, 16 Aug 2019 02:21:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0241.hostedemail.com [216.40.44.241])
	by kanga.kvack.org (Postfix) with ESMTP id 17ED76B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:21:10 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 900028248AA7
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:21:09 +0000 (UTC)
X-FDA: 75827293458.25.frame48_443ec78f8d408
X-HE-Tag: frame48_443ec78f8d408
X-Filterd-Recvd-Size: 6125
Received: from mail-oi1-f195.google.com (mail-oi1-f195.google.com [209.85.167.195])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:21:08 +0000 (UTC)
Received: by mail-oi1-f195.google.com with SMTP id b25so30755oib.4
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 23:21:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bnzSBHY/JdeQAgbtdAEAW270/fKb4r8flWE61wbC5Lo=;
        b=UVlNUshcEIlU+yobZlz2y42/ujMlRlo+ct+0p80oBP1RIOLjVgza5yLAH9kiWJ0ywH
         rn5w4IcTB48oHSkKlTlUwiOfhTg79xGXAcMQPEun+qGn+KaPE/v6hTzroIHT9rozR67E
         6n0mNYDqP9fJbFBUtd9FG2uXYDGCCqC+daSJ0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=bnzSBHY/JdeQAgbtdAEAW270/fKb4r8flWE61wbC5Lo=;
        b=Ibd6afIwA22p1zB2bxjYYUr3NNsQLFCErZFS504vwhCB5CRM07f1VqT98/pVWRUNNB
         noD2qPnOTpwqQy34zVq94ASpoZPghDlzpV8/xDwkvUI8aL9oRT4+D71BoOslLsVgq7V7
         1a7aeno9SD2kVBx5LRnfKem9Ns9IBDvCE3/JLU+pzSIS1eGzafr/QEO/nP73I+BJx4mK
         oCR7SmO8OCBbc3osMZig/OwXBjTekFWDfZj3xQJzmcL15LefBfJ8k7eXl63sridS3RcB
         yxEIv3r4kaGbJ8Cu/u9lG0IMkwMi4RQ8dlBP8uxPZ5BTxwXKISFxpR17V2RPIpleDXFU
         PSpA==
X-Gm-Message-State: APjAAAXliNLSkVpqoN/pvZpeag671XJ2oZpi4ghbY6IdEfBYIKP9digA
	5ghyVqeUYulD6r0M2OXWWvqbCAbCN6QNniZETl40aQ==
X-Google-Smtp-Source: APXvYqzph7HTCPvGlJkLaGSjiEYiCfosASP1QBmSLU+nI/ANvScaJ5s0IeM0Q21xXCjaiRcxA2KwuJ63i1nnQocpq20=
X-Received: by 2002:aca:1a0b:: with SMTP id a11mr4149187oia.128.1565936467928;
 Thu, 15 Aug 2019 23:21:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190815155950.GN9477@dhcp22.suse.cz> <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz> <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz> <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz> <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
 <20190815202721.GV21596@ziepe.ca> <CAKMK7uER0u1TqeJBXarKakphnyZTHOmedOfXXqLGVDE2mE-mAQ@mail.gmail.com>
 <20190816010036.GA9915@ziepe.ca>
In-Reply-To: <20190816010036.GA9915@ziepe.ca>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Fri, 16 Aug 2019 08:20:55 +0200
Message-ID: <CAKMK7uH0oa10LoCiEbj1NqAfWitbdOa-jQm9hM=iNL-=8gH9nw@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Michal Hocko <mhocko@kernel.org>, Feng Tang <feng.tang@intel.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Kees Cook <keescook@chromium.org>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Peter Zijlstra <peterz@infradead.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Jann Horn <jannh@google.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, 
	David Rientjes <rientjes@google.com>, Wei Wang <wvw@google.com>, 
	Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 3:00 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> On Thu, Aug 15, 2019 at 10:49:31PM +0200, Daniel Vetter wrote:
> > On Thu, Aug 15, 2019 at 10:27 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > On Thu, Aug 15, 2019 at 10:16:43PM +0200, Daniel Vetter wrote:
> > > > So if someone can explain to me how that works with lockdep I can of
> > > > course implement it. But afaics that doesn't exist (I tried to explain
> > > > that somewhere else already), and I'm no really looking forward to
> > > > hacking also on lockdep for this little series.
> > >
> > > Hmm, kind of looks like it is done by calling preempt_disable()
> >
> > Yup. That was v1, then came the suggestion that disabling preemption
> > is maybe not the best thing (the oom reaper could still run for a long
> > time comparatively, if it's cleaning out gigabytes of process memory
> > or what not, hence this dedicated debug infrastructure).
>
> Oh, I'm coming in late, sorry
>
> Anyhow, I was thinking since we agreed this can trigger on some
> CONFIG_DEBUG flag, something like
>
>     /* This is a sleepable region, but use preempt_disable to get debugging
>      * for calls that are not allowed to block for OOM [.. insert
>      * Michal's explanation.. ] */
>     if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !mmu_notifier_range_blockable(range))
>         preempt_disable();
>     ops->invalidate_range_start();

I think we also discussed that, and some expressed concerns it would
change behaviour/timing too much for testing. Since this does does
disable preemption for real, not just for might_sleep.

> And I have also been idly mulling doing something like
>
>    if (IS_ENABLED(CONFIG_DEBUG_NOTIFIERS) &&
>        rand &&
>        mmu_notifier_range_blockable(range)) {
>      range->flags = 0
>      if (!ops->invalidate_range_start(range))
>         continue
>
>      // Failed, try again as blockable
>      range->flags = MMU_NOTIFIER_RANGE_BLOCKABLE
>    }
>    ops->invalidate_range_start(range);
>
> Which would give coverage for this corner case without forcing OOM.

Hm, this sounds like a neat idea to slap on top. The rand is going to
be a bit tricky though, but I guess for this we could stuff another
counter into task_struct and just e.g. do this every 1000th or so
invalidate (well need to pick a prime so we cycle through notifiers in
case there's multiple). I like.

Michal, thoughts?
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

