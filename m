Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29206C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 20:25:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3216A2082E
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 20:25:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TEMRditZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3216A2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BB916B0003; Thu,  5 Sep 2019 16:25:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66DC96B0005; Thu,  5 Sep 2019 16:25:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55A916B0007; Thu,  5 Sep 2019 16:25:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id 301AB6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:25:28 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C225E181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 20:25:27 +0000 (UTC)
X-FDA: 75901997094.19.door33_1282d8ffb9c5d
X-HE-Tag: door33_1282d8ffb9c5d
X-Filterd-Recvd-Size: 9713
Received: from mail-ua1-f46.google.com (mail-ua1-f46.google.com [209.85.222.46])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 20:25:27 +0000 (UTC)
Received: by mail-ua1-f46.google.com with SMTP id h23so1284989uao.10
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 13:25:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=d0h5gzva5JOXpyAq4Mm9NWyHUEqR2Uzdq9JFc8ciedQ=;
        b=TEMRditZ69Dg7u1c8c5lDWyHLaVJVRQ7T+MRwSHiisK1SttgMGs+lQunS04A7b6Q8I
         M0TpJHCJHUbua99b3v1NboQEz2BtlIdp0zFafkCDWw3Vh8tJ6M1IiC7VBsle5h4hzPlS
         pUO+R1mwGeo1D95SmrcSR/hveiKYJma6WEkJgrHg4buy6qeTmnXk5RSCZZmgBjZ8vNId
         yCoedq7D6iyz/eWitV0OvkwJLj3UanZAu9DTlwOwNnhKXH/0zvuV2AVHE7+RCdKs7vGQ
         BW6YOZPkH8u4ou7cBAPYeyajPsVMbp0NbNwGKCTBTZl5kHqF9u24rXd7TkwPmiH04yo3
         DkTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=d0h5gzva5JOXpyAq4Mm9NWyHUEqR2Uzdq9JFc8ciedQ=;
        b=jCHNUqk8IQcGB51/McGiJneRkWa0pZHOILlexsGROxUzYqQIgWwiO2ZbY5MIpwyGb+
         XiW0fVXzpzNGu1hX14CUq8Qewm4WmQc0eDtl8R8gcaMJsn2Mte7h6L6r2uWoVQ7HAukD
         fNT9Xw34hFBA4P+gGEBxgF+0TyVqDI11WSUM6A7OekJlj8UOP76O12rMgwLYebVVBTFU
         a9rpYG4SQwjpIqlxInbJ/wH8/8u2CLdDMfqne/JR6pH2MhR5rdoIDXwE8gTKvhBTBEot
         O6yYJ42N9aC6mKT4vJXl1yooVrQEerjOHGumcWgOv1x5Qrir+3WSwVKbIQ2PJIGTdT5B
         764g==
X-Gm-Message-State: APjAAAUA5Rcx1a1csF1WlLlhnoxxm6uRnp1ya0Vn2RL7T9+M0AJr6q/A
	WtRQr3burYgdu15+iQEyzhEEW/Sty/3LvNavYeaqXA==
X-Google-Smtp-Source: APXvYqz9jdUdln3/DCqAAYkXvqpDp1tfJi+vogMoLwqAQ+1btgzrqkzyOxCkT3HHG1VZf4fGGCpZHo/6fRGbhW8ajk0=
X-Received: by 2002:ab0:392:: with SMTP id 18mr2585498uau.85.1567715125946;
 Thu, 05 Sep 2019 13:25:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz> <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz> <20190904162808.GO240514@google.com>
 <20190905144310.GA14491@dhcp22.suse.cz> <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
 <20190905133507.783c6c61@oasis.local.home> <20190905174705.GA106117@google.com>
 <20190905175108.GB106117@google.com> <1567713403.16718.25.camel@kernel.org>
In-Reply-To: <1567713403.16718.25.camel@kernel.org>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 5 Sep 2019 13:24:49 -0700
Message-ID: <CAKOZuescyhpGWUrZT+WpOoQP-gQ-8YYTyzwzZzBTxaJiLhMHxw@mail.gmail.com>
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

On Thu, Sep 5, 2019 at 12:56 PM Tom Zanussi <zanussi@kernel.org> wrote:
> On Thu, 2019-09-05 at 13:51 -0400, Joel Fernandes wrote:
> > On Thu, Sep 05, 2019 at 01:47:05PM -0400, Joel Fernandes wrote:
> > > On Thu, Sep 05, 2019 at 01:35:07PM -0400, Steven Rostedt wrote:
> > > >
> > > >
> > > > [ Added Tom ]
> > > >
> > > > On Thu, 5 Sep 2019 09:03:01 -0700
> > > > Suren Baghdasaryan <surenb@google.com> wrote:
> > > >
> > > > > On Thu, Sep 5, 2019 at 7:43 AM Michal Hocko <mhocko@kernel.org>
> > > > > wrote:
> > > > > >
> > > > > > [Add Steven]
> > > > > >
> > > > > > On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> > > > > > > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel
> > > > > > > .org> wrote:
> > > > > > > >
> > > > > > > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > > > > >
> > > > > > [...]
> > > > > > > > > but also for reducing
> > > > > > > > > tracing noise. Flooding the traces makes it less useful
> > > > > > > > > for long traces and
> > > > > > > > > post-processing of traces. IOW, the overhead reduction
> > > > > > > > > is a bonus.
> > > > > > > >
> > > > > > > > This is not really anything special for this tracepoint
> > > > > > > > though.
> > > > > > > > Basically any tracepoint in a hot path is in the same
> > > > > > > > situation and I do
> > > > > > > > not see a point why each of them should really invent its
> > > > > > > > own way to
> > > > > > > > throttle. Maybe there is some way to do that in the
> > > > > > > > tracing subsystem
> > > > > > > > directly.
> > > > > > >
> > > > > > > I am not sure if there is a way to do this easily. Add to
> > > > > > > that, the fact that
> > > > > > > you still have to call into trace events. Why call into it
> > > > > > > at all, if you can
> > > > > > > filter in advance and have a sane filtering default?
> > > > > > >
> > > > > > > The bigger improvement with the threshold is the number of
> > > > > > > trace records are
> > > > > > > almost halved by using a threshold. The number of records
> > > > > > > went from 4.6K to
> > > > > > > 2.6K.
> > > > > >
> > > > > > Steven, would it be feasible to add a generic tracepoint
> > > > > > throttling?
> > > > >
> > > > > I might misunderstand this but is the issue here actually
> > > > > throttling
> > > > > of the sheer number of trace records or tracing large enough
> > > > > changes
> > > > > to RSS that user might care about? Small changes happen all the
> > > > > time
> > > > > but we are likely not interested in those. Surely we could
> > > > > postprocess
> > > > > the traces to extract changes large enough to be interesting
> > > > > but why
> > > > > capture uninteresting information in the first place? IOW the
> > > > > throttling here should be based not on the time between traces
> > > > > but on
> > > > > the amount of change of the traced signal. Maybe a generic
> > > > > facility
> > > > > like that would be a good idea?
> > > >
> > > > You mean like add a trigger (or filter) that only traces if a
> > > > field has
> > > > changed since the last time the trace was hit? Hmm, I think we
> > > > could
> > > > possibly do that. Perhaps even now with histogram triggers?
> > >
> > >
> > > Hey Steve,
> > >
> > > Something like an analog to digitial coversion function where you
> > > lose the
> > > granularity of the signal depending on how much trace data:
> > > https://www.globalspec.com/ImageRepository/LearnMore/20142/9ee38d1a
> > > 85d37fa23f86a14d3a9776ff67b0ec0f3b.gif
> >
> > s/how much trace data/what the resolution is/
> >
> > > so like, if you had a counter incrementing with values after the
> > > increments
> > > as:  1,3,4,8,12,14,30 and say 5 is the threshold at which to emit a
> > > trace,
> > > then you would get 1,8,12,30.
> > >
> > > So I guess what is need is a way to reduce the quantiy of trace
> > > data this
> > > way. For this usecase, the user mostly cares about spikes in the
> > > counter
> > > changing that accurate values of the different points.
> >
> > s/that accurate/than accurate/
> >
> > I think Tim, Suren, Dan and Michal are all saying the same thing as
> > well.
> >
>
> There's not a way to do this using existing triggers (histogram
> triggers have an onchange() that fires on any change, but that doesn't
> help here), and I wouldn't expect there to be - these sound like very
> specific cases that would never have support in the simple trigger
> 'language'.

I don't see the filtering under discussion as some "very specific"
esoteric need. You need this general kind of mechanism any time you
want to monitor at low frequency a thing that changes at high
frequency. The general pattern isn't specific to RSS or even memory in
general. One might imagine, say, wanting to trace large changes in TCP
window sizes. Any time something in the kernel has a "level" and that
level changes at high frequency and we want to learn about big swings
in that level, the mechanism we're talking about becomes useful. I
don't think it should be out of bounds for the histogram mechanism,
which is *almost* there right now. We already have the ability to
accumulate values derived from ftrace events into tables keyed on
various fields in these events and things like onmax().

> On the other hand, I have been working on something that should give
> you the ability to do something like this, by writing a module that
> hooks into arbitrary trace events, accessing their fields, building up
> any needed state across events, and then generating synthetic events as
> needed:

You might as well say we shouldn't have tracepoints at all and that
people should just write modules that kprobe what they need. :-) You
can reject *any* kernel interface by suggesting that people write a
module to do that thing. (You could also probably do something with
eBPF.) But there's a lot of value to having an easy-to-use
general-purpose mechanism that doesn't make people break out the
kernel headers and a C compiler.

