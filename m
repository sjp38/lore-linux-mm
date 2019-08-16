Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14E85C3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 14:11:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C177A21721
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 14:11:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="iKfxKoMv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C177A21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42A626B0005; Fri, 16 Aug 2019 10:11:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B39F6B0006; Fri, 16 Aug 2019 10:11:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2547A6B0007; Fri, 16 Aug 2019 10:11:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0006.hostedemail.com [216.40.44.6])
	by kanga.kvack.org (Postfix) with ESMTP id F20056B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:11:48 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9D486180AD7C1
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:11:48 +0000 (UTC)
X-FDA: 75828479496.17.linen97_670d8fd69b947
X-HE-Tag: linen97_670d8fd69b947
X-Filterd-Recvd-Size: 6647
Received: from mail-oi1-f194.google.com (mail-oi1-f194.google.com [209.85.167.194])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:11:48 +0000 (UTC)
Received: by mail-oi1-f194.google.com with SMTP id p124so4884259oig.5
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 07:11:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Yssxgr/R6OQdplSnDNsdTRBQMibjMIg4+OgGLQyMPwk=;
        b=iKfxKoMvF7fYuHqtxhMdeLtiTE/pTTZEGguyp0+hucFHluJ5kX2VIkLSCTNrBBI4hS
         m75gSd95L78hr4hdAIJz7abvXf9heA1zVnFk/Tff1ZGBb79t7v6ncV9jdxtpQZTpEg9o
         H6oav0M6pZU1zPqylhHo7uj1Ld1HrZ7uYQ70Q=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Yssxgr/R6OQdplSnDNsdTRBQMibjMIg4+OgGLQyMPwk=;
        b=ozGiHyEq70jwDvB6kNg62xGHZPrv1wyz9FYr3kfiQQ+PuXIVuxKk17D3c6mdR7FCI3
         pNGR2D5V6e58uWZN9JItkywjWcnTkOKq85YCHl5Lz9VC8M182IxR8wkBjg+mCHRdgNWH
         umGDcVVeC+x4m2rghVnL6AUE+N4dYeLBVW8eeBp9DwkN082JeezrhYzEWnA1RCa/z1YW
         r2pXfqq31xk7iQPJrwUIIFB262LBRJ59qamryhK/Vul7aVYAAkKajaqz4N0m2ziLjLAY
         1SRltBi4m7PPbl06mjASkvF1BSSzK7DpqZtKrukhhvqVga7phpFesdRdftU/IgFNlKpQ
         ovzw==
X-Gm-Message-State: APjAAAWnrCtpohRhOr+1Kh5KgdnQ8r6gZro8EoDbUCME87hFchVrIUnL
	W1cNomQueQ+yonvWNiWqq9qL5s95kgFbcYTpDY/Erw==
X-Google-Smtp-Source: APXvYqx2XgL7KeHyryZ4+8xqmn4BItCVHB9tDtZdlS5rAComTkGY2660h6IEE51SBGH2skdFu1E3ye0pzcKw0PqZrbI=
X-Received: by 2002:aca:1a0b:: with SMTP id a11mr5297448oia.128.1565964706931;
 Fri, 16 Aug 2019 07:11:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190815174207.GR9477@dhcp22.suse.cz> <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz> <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz> <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
 <20190815202721.GV21596@ziepe.ca> <CAKMK7uER0u1TqeJBXarKakphnyZTHOmedOfXXqLGVDE2mE-mAQ@mail.gmail.com>
 <20190816010036.GA9915@ziepe.ca> <CAKMK7uH0oa10LoCiEbj1NqAfWitbdOa-jQm9hM=iNL-=8gH9nw@mail.gmail.com>
 <20190816121243.GB5398@ziepe.ca>
In-Reply-To: <20190816121243.GB5398@ziepe.ca>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Fri, 16 Aug 2019 16:11:34 +0200
Message-ID: <CAKMK7uHk03OD+N-anPf-ADPzvQJ_NbQXFh5WsVUo-Ewv9vcOAw@mail.gmail.com>
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

On Fri, Aug 16, 2019 at 2:12 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Fri, Aug 16, 2019 at 08:20:55AM +0200, Daniel Vetter wrote:
> > On Fri, Aug 16, 2019 at 3:00 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > On Thu, Aug 15, 2019 at 10:49:31PM +0200, Daniel Vetter wrote:
> > > > On Thu, Aug 15, 2019 at 10:27 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > > > On Thu, Aug 15, 2019 at 10:16:43PM +0200, Daniel Vetter wrote:
> > > > > > So if someone can explain to me how that works with lockdep I can of
> > > > > > course implement it. But afaics that doesn't exist (I tried to explain
> > > > > > that somewhere else already), and I'm no really looking forward to
> > > > > > hacking also on lockdep for this little series.
> > > > >
> > > > > Hmm, kind of looks like it is done by calling preempt_disable()
> > > >
> > > > Yup. That was v1, then came the suggestion that disabling preemption
> > > > is maybe not the best thing (the oom reaper could still run for a long
> > > > time comparatively, if it's cleaning out gigabytes of process memory
> > > > or what not, hence this dedicated debug infrastructure).
> > >
> > > Oh, I'm coming in late, sorry
> > >
> > > Anyhow, I was thinking since we agreed this can trigger on some
> > > CONFIG_DEBUG flag, something like
> > >
> > >     /* This is a sleepable region, but use preempt_disable to get debugging
> > >      * for calls that are not allowed to block for OOM [.. insert
> > >      * Michal's explanation.. ] */
> > >     if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !mmu_notifier_range_blockable(range))
> > >         preempt_disable();
> > >     ops->invalidate_range_start();
> >
> > I think we also discussed that, and some expressed concerns it would
> > change behaviour/timing too much for testing. Since this does does
> > disable preemption for real, not just for might_sleep.
>
> I don't follow, this is a debug kernel, it will have widly different
> timing.
>
> Further the point of this debugging on atomic_sleep is to be as
> timing-independent as possible since functions with rare sleeps should
> be guarded by might_sleep() in their common paths.
>
> I guess I don't get the push to have some low overhead debugging for
> this? Is there something special you are looking for?

Don't ask me, I'm just trying to get _some_ debugging for this in. I
don't care one bit how much overhead it has because in our CI our
debug build has lockdep and everything and it crawls anyway. I started
out with the preempt_disable/enable thing like you suggested, and a
few rounds later we're here. We can go back to v1 on this one, but I'd
prefer to not do the lap too often.

Also, aside from this patch (which is prep for the next) and some
simple reordering conflicts they're all independent. So if there's no
way to paint this bikeshed here (technicolor perhaps?) then I'd like
to get at least the others considered.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

