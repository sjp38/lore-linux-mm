Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83F47C43140
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:12:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82F4C20825
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:12:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XTO/Z09y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82F4C20825
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC26D6B0005; Thu,  5 Sep 2019 18:12:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B72B56B0007; Thu,  5 Sep 2019 18:12:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A60E36B0008; Thu,  5 Sep 2019 18:12:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0039.hostedemail.com [216.40.44.39])
	by kanga.kvack.org (Postfix) with ESMTP id 8369E6B0005
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:12:43 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1B31D55F8E
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:12:43 +0000 (UTC)
X-FDA: 75902267406.02.alley61_51dbeaf502613
X-HE-Tag: alley61_51dbeaf502613
X-Filterd-Recvd-Size: 12211
Received: from mail-ua1-f67.google.com (mail-ua1-f67.google.com [209.85.222.67])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:12:42 +0000 (UTC)
Received: by mail-ua1-f67.google.com with SMTP id u18so1403030uap.2
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 15:12:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+AgA2RE87QBvjkxBfkFX/aBO14ME6PxLoNXmdIpAqGc=;
        b=XTO/Z09yZ+GceyBPVrP5uDDdoXWJGIqEQGbgilTL7WIBBGrMFB2cgpITJjvUEj4zzj
         45b3vliYjwrizEdcsMU0Oq1lOLCTud7+DJMuXXeei01hKNze+imQZqfA+nlObIMJzjU6
         OzGOo1EMjSM1jeP0pwJHTki4r7PM7gVvYwx0F3c7kklkHDVjb2GTWe4dkBgc6jxsGX4o
         YSyJ/+3jds9co9eUVVDPFjYGFhkP3AX6zekkqekMV/JKjoVc5R9n70+w5GMYapnF2vBO
         VcDSWOiVxEM4aiT5oCCdBAs0/bxTSop+OrOikf75MfJkro+wMxTeWaW+tkPEiZscC47f
         FWgg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=+AgA2RE87QBvjkxBfkFX/aBO14ME6PxLoNXmdIpAqGc=;
        b=ZZ8dPPntHQL54d9S2kz7ABGpbTGUxOhFynQmc8fUkRKjqGQkhRt6JiT9NEIYf+DkKA
         q73OwV/Os0DgvG3wHoALe+hkr19HZ4/Pxe3bZlJMEYAnP9U1ThdiiYO0SNxboUd8Wa2x
         u0Yisem7RHOntTchW36pXl70CvecNOc64uJ0SgELsy2Yn9FuwngZSQehr7HglFn3wMVN
         1+d8Xv3gEKVKgYLMXbEm/oaPtolhBLbhW+D9OfbnavSG6NeibxsbSB/hbIi+c/yrM97t
         2WlPBK80WPxo3MxIBiiwguA9tvE42JMzYZ8zxE4Lo9R4a8QdUe6iZThILaU/Ox5mdCVh
         uwNA==
X-Gm-Message-State: APjAAAWw2lb5mY8a7Bdn69ETekB42EpE1GxK1j8V7FYLPrjVPMv5xeIm
	ekPHLKSNURl+rcPcvXXGHNTyEVqSF30X/81LzuqrbQ==
X-Google-Smtp-Source: APXvYqwSofxfJYmi0XI4CwbyhSOv31Hhm30nFaOG36axP35t3H08DkhGPBO5HyBdHLkABRWlJM7wOq43GJppOMxxr9g=
X-Received: by 2002:ab0:392:: with SMTP id 18mr2846023uau.85.1567721561347;
 Thu, 05 Sep 2019 15:12:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz> <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz> <20190904162808.GO240514@google.com>
 <20190905144310.GA14491@dhcp22.suse.cz> <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
 <20190905133507.783c6c61@oasis.local.home> <20190905174705.GA106117@google.com>
 <20190905175108.GB106117@google.com> <1567713403.16718.25.camel@kernel.org>
 <CAKOZuescyhpGWUrZT+WpOoQP-gQ-8YYTyzwzZzBTxaJiLhMHxw@mail.gmail.com> <1567718076.16718.39.camel@kernel.org>
In-Reply-To: <1567718076.16718.39.camel@kernel.org>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 5 Sep 2019 15:12:04 -0700
Message-ID: <CAKOZuetfzp0FsB0cBd8mqQHQ=5t_fX-vCcBvYL71MPxtF6erTA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: Tom Zanussi <zanussi@kernel.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, Steven Rostedt <rostedt@goodmis.org>, 
	Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Tim Murray <timmurray@google.com>, 
	Carmen Jackson <carmenjackson@google.com>, Mayank Gupta <mayankgupta@google.com>, 
	Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	kernel-team <kernel-team@android.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, 
	linux-mm <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, 
	Ralph Campbell <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 5, 2019 at 2:14 PM Tom Zanussi <zanussi@kernel.org> wrote:
>
> On Thu, 2019-09-05 at 13:24 -0700, Daniel Colascione wrote:
> > On Thu, Sep 5, 2019 at 12:56 PM Tom Zanussi <zanussi@kernel.org>
> > wrote:
> > > On Thu, 2019-09-05 at 13:51 -0400, Joel Fernandes wrote:
> > > > On Thu, Sep 05, 2019 at 01:47:05PM -0400, Joel Fernandes wrote:
> > > > > On Thu, Sep 05, 2019 at 01:35:07PM -0400, Steven Rostedt wrote:
> > > > > >
> > > > > >
> > > > > > [ Added Tom ]
> > > > > >
> > > > > > On Thu, 5 Sep 2019 09:03:01 -0700
> > > > > > Suren Baghdasaryan <surenb@google.com> wrote:
> > > > > >
> > > > > > > On Thu, Sep 5, 2019 at 7:43 AM Michal Hocko <mhocko@kernel.
> > > > > > > org>
> > > > > > > wrote:
> > > > > > > >
> > > > > > > > [Add Steven]
> > > > > > > >
> > > > > > > > On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> > > > > > > > > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@ke
> > > > > > > > > rnel
> > > > > > > > > .org> wrote:
> > > > > > > > > >
> > > > > > > > > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > > > > > > >
> > > > > > > > [...]
> > > > > > > > > > > but also for reducing
> > > > > > > > > > > tracing noise. Flooding the traces makes it less
> > > > > > > > > > > useful
> > > > > > > > > > > for long traces and
> > > > > > > > > > > post-processing of traces. IOW, the overhead
> > > > > > > > > > > reduction
> > > > > > > > > > > is a bonus.
> > > > > > > > > >
> > > > > > > > > > This is not really anything special for this
> > > > > > > > > > tracepoint
> > > > > > > > > > though.
> > > > > > > > > > Basically any tracepoint in a hot path is in the same
> > > > > > > > > > situation and I do
> > > > > > > > > > not see a point why each of them should really invent
> > > > > > > > > > its
> > > > > > > > > > own way to
> > > > > > > > > > throttle. Maybe there is some way to do that in the
> > > > > > > > > > tracing subsystem
> > > > > > > > > > directly.
> > > > > > > > >
> > > > > > > > > I am not sure if there is a way to do this easily. Add
> > > > > > > > > to
> > > > > > > > > that, the fact that
> > > > > > > > > you still have to call into trace events. Why call into
> > > > > > > > > it
> > > > > > > > > at all, if you can
> > > > > > > > > filter in advance and have a sane filtering default?
> > > > > > > > >
> > > > > > > > > The bigger improvement with the threshold is the number
> > > > > > > > > of
> > > > > > > > > trace records are
> > > > > > > > > almost halved by using a threshold. The number of
> > > > > > > > > records
> > > > > > > > > went from 4.6K to
> > > > > > > > > 2.6K.
> > > > > > > >
> > > > > > > > Steven, would it be feasible to add a generic tracepoint
> > > > > > > > throttling?
> > > > > > >
> > > > > > > I might misunderstand this but is the issue here actually
> > > > > > > throttling
> > > > > > > of the sheer number of trace records or tracing large
> > > > > > > enough
> > > > > > > changes
> > > > > > > to RSS that user might care about? Small changes happen all
> > > > > > > the
> > > > > > > time
> > > > > > > but we are likely not interested in those. Surely we could
> > > > > > > postprocess
> > > > > > > the traces to extract changes large enough to be
> > > > > > > interesting
> > > > > > > but why
> > > > > > > capture uninteresting information in the first place? IOW
> > > > > > > the
> > > > > > > throttling here should be based not on the time between
> > > > > > > traces
> > > > > > > but on
> > > > > > > the amount of change of the traced signal. Maybe a generic
> > > > > > > facility
> > > > > > > like that would be a good idea?
> > > > > >
> > > > > > You mean like add a trigger (or filter) that only traces if a
> > > > > > field has
> > > > > > changed since the last time the trace was hit? Hmm, I think
> > > > > > we
> > > > > > could
> > > > > > possibly do that. Perhaps even now with histogram triggers?
> > > > >
> > > > >
> > > > > Hey Steve,
> > > > >
> > > > > Something like an analog to digitial coversion function where
> > > > > you
> > > > > lose the
> > > > > granularity of the signal depending on how much trace data:
> > > > > https://www.globalspec.com/ImageRepository/LearnMore/20142/9ee3
> > > > > 8d1a
> > > > > 85d37fa23f86a14d3a9776ff67b0ec0f3b.gif
> > > >
> > > > s/how much trace data/what the resolution is/
> > > >
> > > > > so like, if you had a counter incrementing with values after
> > > > > the
> > > > > increments
> > > > > as:  1,3,4,8,12,14,30 and say 5 is the threshold at which to
> > > > > emit a
> > > > > trace,
> > > > > then you would get 1,8,12,30.
> > > > >
> > > > > So I guess what is need is a way to reduce the quantiy of trace
> > > > > data this
> > > > > way. For this usecase, the user mostly cares about spikes in
> > > > > the
> > > > > counter
> > > > > changing that accurate values of the different points.
> > > >
> > > > s/that accurate/than accurate/
> > > >
> > > > I think Tim, Suren, Dan and Michal are all saying the same thing
> > > > as
> > > > well.
> > > >
> > >
> > > There's not a way to do this using existing triggers (histogram
> > > triggers have an onchange() that fires on any change, but that
> > > doesn't
> > > help here), and I wouldn't expect there to be - these sound like
> > > very
> > > specific cases that would never have support in the simple trigger
> > > 'language'.
> >
> > I don't see the filtering under discussion as some "very specific"
> > esoteric need. You need this general kind of mechanism any time you
> > want to monitor at low frequency a thing that changes at high
> > frequency. The general pattern isn't specific to RSS or even memory
> > in
> > general. One might imagine, say, wanting to trace large changes in
> > TCP
> > window sizes. Any time something in the kernel has a "level" and that
> > level changes at high frequency and we want to learn about big swings
> > in that level, the mechanism we're talking about becomes useful. I
> > don't think it should be out of bounds for the histogram mechanism,
> > which is *almost* there right now. We already have the ability to
> > accumulate values derived from ftrace events into tables keyed on
> > various fields in these events and things like onmax().
> >
>
> OK, so with the histograms we already have onchange(), which triggers
> on any change.
>
> Would it be sufficient to just add a 'threshold' param to that i.e.
> onchange(x) means trigger whenever the difference between the new value
> and the previous value is >= x?

By previous value, do you mean previously-reported value or the
previously-set value? If the former, that's good, but we may be able
to do better (see below). If the latter, I don't think that's quite
right, because then we could miss an arbitrarily-large change in
"level" so long as it occurred in sufficiently small steps.

Basically, what I have in mind is this:

1) attach a trigger a tracepoint that contains some
absolutely-specified "level" (say, task private RSS),

2) in the trigger, find the absolute value of the difference between
the new "level" (some field in that tracepoint) and the last "level"
we have for the combination of that value and configurable
partitioning criteria (e.g., pid, uid, cpu, NUMA node) yielding an
absdelta,

3) accumulate absdelta values in some table partitioned on the same
fields as in #2, and

4) after updating accumulated absdelta, evaluate a filter expression,
and if the filter expression evaluates to true, emit a tracepoint
saying "the new value of $LEVEL for $PARTITION is $VALUE" and reset
the accumulated absdelta to zero.

I think this mechanism would give us what we wanted in a general and
powerful way, and we can dial the granularity up or down however want.
The reason I want to accumulate absdelta values instead of just firing
when the previously-reported value differs sufficiently from the
last-set value is so we can tell whether a counter is fluctuating a
lot without its value actually changing. The trigger expression could
then allow any combination of conditions, e.g., "fire a tracepoint
when the accumulated change is greater than 2MB _OR_ a single change
is greater than 1MB _OR_ when we've gone 10 changes of this level
value without reporting the level's new value".

Let me know if this description doesn't make sense.

