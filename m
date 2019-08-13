Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A649C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 19:24:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 526FD2054F
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 19:24:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KE3GYgXj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 526FD2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D085A6B0005; Tue, 13 Aug 2019 15:24:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB8D56B0006; Tue, 13 Aug 2019 15:24:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD00A6B0007; Tue, 13 Aug 2019 15:24:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0146.hostedemail.com [216.40.44.146])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFC16B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:24:20 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 11D1D180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 19:24:20 +0000 (UTC)
X-FDA: 75818380680.02.guide17_25c2e49684340
X-HE-Tag: guide17_25c2e49684340
X-Filterd-Recvd-Size: 5944
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 19:24:19 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id r20so26837297ota.5
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:24:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0BGADOSDNi0yEXJGYbIS7Es/7+y3WA9cMlUX5F4uA3I=;
        b=KE3GYgXjoB+OjzuGsPmiAcRayJ6zju7RPzcdKGrMzVlkey77jjZxtEP2mh1WWv9sLH
         ZLMlMjxt2wR2TGRUwQxDhztynGX3APXiJD1kSQjb2/KavbrOWht5m8t0cWuEoje6TxE7
         44Huamiy10vZn8q+9xjaKC0GYqpD8w7HhTLT6L5zQu/2cugN4hbedB1kO+xS+TyMxLOv
         bwl6kKSAXjiNinqMNDx86QfPebu18GpyViD0CXVdg4XK64TwicdGeuABSziFnP9+zdHz
         u9cFnhGSRhgcXXGSo5Rlog586C+LQL8pZqnYwNVWTh3UrfdUpF3AseKSqw2mZ/pN7lus
         rNRA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=0BGADOSDNi0yEXJGYbIS7Es/7+y3WA9cMlUX5F4uA3I=;
        b=sEnxB4PA0WtYtlcvjuUB2W7b4e3ALVVTRyc9SZzfu55bWpW+thEFocFFsim/XlKDIp
         +ryhRazsAQiEn9ZcqTXKmr1P2WSbTYl/vOvbeMs+iMaZbvPLfzh/dMj0J7JdrOMavtVS
         7mpA7UgVZBNUJGBMrcFsRfYlAQiyfyre6bVcKlEMdVDMemMmW9BR6ARdz+hiU1Txwcjp
         ptf22zCiHoFadE/Ixc8v9WVDUYpMOad2llQglyreQ3orrPp1VTo7RdgQHszVNKlUSst/
         IF9Rx7Fowc7E+FAC+L/1Ibmhaw82xCZHSPXNft/cDG0ZUd6VAcPKvBfZiga804parRAy
         20WQ==
X-Gm-Message-State: APjAAAUN19LEM0GU8RNy1fTqUsYewtdruDYAcq+bXoyACn7mR2+T6GMj
	RGcbGkyXMtrE3bNEHnNruqou7vXRcnB+4UANdI8=
X-Google-Smtp-Source: APXvYqyNWl6EB6hqtWOLBAyHMMulekRu0qD9+ndzTr07RTNTOCPXCYzvAypulGqjwsebgf4b+owsuwKVp8jgDKJPlE8=
X-Received: by 2002:a6b:f406:: with SMTP id i6mr6656iog.110.1565724258526;
 Tue, 13 Aug 2019 12:24:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <20190807171559.182301-2-joel@joelfernandes.org> <20190813150450.GN17933@dhcp22.suse.cz>
 <20190813153659.GD14622@google.com>
In-Reply-To: <20190813153659.GD14622@google.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 13 Aug 2019 22:24:06 +0300
Message-ID: <CALYGNiOj4pxZAMvM_3fJZ0xJ0E5-FfSRQbGdxb4eFC37USCYvA@mail.gmail.com>
Subject: Re: [PATCH v5 2/6] mm/page_idle: Add support for handling swapped
 PG_Idle pages
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Michal Hocko <mhocko@kernel.org>, 
	=?UTF-8?B?0JrQvtC90YHRgtCw0L3RgtC40L0g0KXQu9C10LHQvdC40LrQvtCy?= <khlebnikov@yandex-team.ru>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, 
	Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Christian Hansen <chansen3@cisco.com>, dancol@google.com, 
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, 
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, kernel-team@android.com, 
	Linux API <linux-api@vger.kernel.org>, linux-doc@vger.kernel.org, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, 
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com, paulmck@linux.ibm.com, 
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com, 
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 6:37 PM Joel Fernandes <joel@joelfernandes.org> wrote:
>
> On Tue, Aug 13, 2019 at 05:04:50PM +0200, Michal Hocko wrote:
> > On Wed 07-08-19 13:15:55, Joel Fernandes (Google) wrote:
> > > Idle page tracking currently does not work well in the following
> > > scenario:
> > >  1. mark page-A idle which was present at that time.
> > >  2. run workload
> > >  3. page-A is not touched by workload
> > >  4. *sudden* memory pressure happen so finally page A is finally swapped out
> > >  5. now see the page A - it appears as if it was accessed (pte unmapped
> > >     so idle bit not set in output) - but it's incorrect.
> > >
> > > To fix this, we store the idle information into a new idle bit of the
> > > swap PTE during swapping of anonymous pages.
> > >
> > > Also in the future, madvise extensions will allow a system process
> > > manager (like Android's ActivityManager) to swap pages out of a process
> > > that it knows will be cold. To an external process like a heap profiler
> > > that is doing idle tracking on another process, this procedure will
> > > interfere with the idle page tracking similar to the above steps.
> >
> > This could be solved by checking the !present/swapped out pages
> > right? Whoever decided to put the page out to the swap just made it
> > idle effectively.  So the monitor can make some educated guess for
> > tracking. If that is fundamentally not possible then please describe
> > why.
>
> But the monitoring process (profiler) does not have control over the 'whoever
> made it effectively idle' process.
>
> As you said it will be a guess, it will not be accurate.

Yep. Without saving idle bit in swap entry (and presuming that all swap is idle)
profiler could miss access. This patch adds accurate tracking almost for free.
After that profiler could work with any pace without races.

>
> I am curious what is your concern with using a bit in the swap PTE?
>
> (Adding Konstantin as well since we may be interested in this, since we also
> suggested this idea).
>
> thanks,
>
>  - Joel
>
>

