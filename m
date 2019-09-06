Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4291BC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 01:16:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BAA620820
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 01:16:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hmHN99A4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BAA620820
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 855DF6B0007; Thu,  5 Sep 2019 21:16:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 806A56B0008; Thu,  5 Sep 2019 21:16:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71C986B000A; Thu,  5 Sep 2019 21:16:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0067.hostedemail.com [216.40.44.67])
	by kanga.kvack.org (Postfix) with ESMTP id 50E206B0007
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:16:22 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E6785180AD801
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 01:16:21 +0000 (UTC)
X-FDA: 75902730162.11.sky73_549f2398e1015
X-HE-Tag: sky73_549f2398e1015
X-Filterd-Recvd-Size: 8545
Received: from mail-vs1-f67.google.com (mail-vs1-f67.google.com [209.85.217.67])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 01:16:21 +0000 (UTC)
Received: by mail-vs1-f67.google.com with SMTP id z14so2949922vsz.13
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 18:16:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=G/jjPUvkqLp7k2MNayLy8yxR2QJnGQkJPP4pKvRP8XY=;
        b=hmHN99A4aLokrPl4lZWpuHNAv5KcXkuR1PLZM3hGzvO6K+EL46baGousu8iKVvHw/U
         RJFOxJaMVEBUmH0UIaNTJqQ8Ltsp6iQCMqxNRDPuB9IuMGwTpbKw6h9KZCSXIHaM3lDj
         VRd6Mv4A//Jxll8nWOxOmsCGAkff7kwUyjwqWl0M2+xsPWgT1aEZEPMqG2c9GCjrpkH5
         z+G73lipkuj4pbpMFSLZQ2y5GXwVBY94FqeMPW0brat5LLjvpigbGSNu3AUb0TEX2+Q9
         KaNeBfTeEIGRdIlEU+pJnj1/x0A6u7ZCBOvfHl7FTl4Grtshwn4h5p/ZKvbdRAH05X0X
         rmhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=G/jjPUvkqLp7k2MNayLy8yxR2QJnGQkJPP4pKvRP8XY=;
        b=OwNWXFZsbRmtk3QuAFHF8ilfT8/JP2vFiGHs+/8LEQ1VjMokQe7xC+++x5/BctEru6
         VDEKujk2A7czpxlfWLLaBnRTjJ+7kLIrnlH1oVU45NKN38QlMqVZcLfRF/l9+mk1FL9u
         Zv2UmxVv0mIyW8ZG3aUwwGaL7ArkeRnHFjgQVeOYw+aWw6JDSPkMTdfKxtCXqFsMy/5G
         eStfHktPit50sPepJgvWyDOf3mLEUOG1VfOVFMAju4HfA6FSatYi8zldeGxB3Zw5XcH8
         lOWGKXs0B0h82ahDRWB9Yxd6YVzDOjDmV2QhRQ3l/KNza/K5ZmI6A8f5nPzbDSCbYfd2
         mwNQ==
X-Gm-Message-State: APjAAAWRl17UgBYqPL707GAQRiOrZqN2SJx0AhSjrCpef+/QjFbgzPr1
	8uTYpFW/5o5Ey3xsOGU5brbC+JttBvQ1n2B0tWWufQ==
X-Google-Smtp-Source: APXvYqzYnX89Xr/kb8QZtSv/BCXEqHmOOsdTFJDhTkcQdWuAQor0/lxU7xkYlX8I/lJ93uL2cXZdqF9tN62Y8dfC2k8=
X-Received: by 2002:a67:1043:: with SMTP id 64mr3783637vsq.114.1567732580314;
 Thu, 05 Sep 2019 18:16:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz> <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz> <20190904162808.GO240514@google.com>
 <20190905144310.GA14491@dhcp22.suse.cz> <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
 <20190905133507.783c6c61@oasis.local.home> <CAKOZueuQpHDnk-3GrLdXH_N_5Z7FRSJu+cwKhHNMUyKRqvkzjA@mail.gmail.com>
 <20190906005904.GC224720@google.com>
In-Reply-To: <20190906005904.GC224720@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 5 Sep 2019 18:15:43 -0700
Message-ID: <CAKOZuevJyfZRFz3M5myLy+XpS=mAxYCf+oQ2csxCHh7VO-OrKw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Suren Baghdasaryan <surenb@google.com>, 
	Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Tim Murray <timmurray@google.com>, Carmen Jackson <carmenjackson@google.com>, 
	Mayank Gupta <mayankgupta@google.com>, Minchan Kim <minchan@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, kernel-team <kernel-team@android.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>, 
	Jerome Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Matthew Wilcox <willy@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Tom Zanussi <zanussi@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 5, 2019 at 5:59 PM Joel Fernandes <joel@joelfernandes.org> wrote:
> On Thu, Sep 05, 2019 at 10:50:27AM -0700, Daniel Colascione wrote:
> > On Thu, Sep 5, 2019 at 10:35 AM Steven Rostedt <rostedt@goodmis.org> wrote:
> > > On Thu, 5 Sep 2019 09:03:01 -0700
> > > Suren Baghdasaryan <surenb@google.com> wrote:
> > >
> > > > On Thu, Sep 5, 2019 at 7:43 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > [Add Steven]
> > > > >
> > > > > On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> > > > > > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > > >
> > > > > > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > > > > [...]
> > > > > > > > but also for reducing
> > > > > > > > tracing noise. Flooding the traces makes it less useful for long traces and
> > > > > > > > post-processing of traces. IOW, the overhead reduction is a bonus.
> > > > > > >
> > > > > > > This is not really anything special for this tracepoint though.
> > > > > > > Basically any tracepoint in a hot path is in the same situation and I do
> > > > > > > not see a point why each of them should really invent its own way to
> > > > > > > throttle. Maybe there is some way to do that in the tracing subsystem
> > > > > > > directly.
> > > > > >
> > > > > > I am not sure if there is a way to do this easily. Add to that, the fact that
> > > > > > you still have to call into trace events. Why call into it at all, if you can
> > > > > > filter in advance and have a sane filtering default?
> > > > > >
> > > > > > The bigger improvement with the threshold is the number of trace records are
> > > > > > almost halved by using a threshold. The number of records went from 4.6K to
> > > > > > 2.6K.
> > > > >
> > > > > Steven, would it be feasible to add a generic tracepoint throttling?
> > > >
> > > > I might misunderstand this but is the issue here actually throttling
> > > > of the sheer number of trace records or tracing large enough changes
> > > > to RSS that user might care about? Small changes happen all the time
> > > > but we are likely not interested in those. Surely we could postprocess
> > > > the traces to extract changes large enough to be interesting but why
> > > > capture uninteresting information in the first place? IOW the
> > > > throttling here should be based not on the time between traces but on
> > > > the amount of change of the traced signal. Maybe a generic facility
> > > > like that would be a good idea?
> > >
> > > You mean like add a trigger (or filter) that only traces if a field has
> > > changed since the last time the trace was hit? Hmm, I think we could
> > > possibly do that. Perhaps even now with histogram triggers?
> >
> > I was thinking along the same lines. The histogram subsystem seems
> > like a very good fit here. Histogram triggers already let users talk
> > about specific fields of trace events, aggregate them in configurable
> > ways, and (importantly, IMHO) create synthetic new trace events that
> > the kernel emits under configurable conditions.
>
> Hmm, I think this tracing feature will be a good idea. But in order not to
> gate this patch, can we agree on keeping a temporary threshold for this
> patch? Once such idea is implemented in trace subsystem, then we can remove
> the temporary filter.
>
> As Tim said, we don't want our traces flooded and this is a very useful
> tracepoint as proven in our internal usage at Android. The threshold filter
> is just few lines of code.

I'm not sure the threshold filtering code you've added does the right
thing: we don't keep state, so if a counter constantly flips between
one "side" of the TRACE_MM_COUNTER_THRESHOLD and the other, we'll emit
ftrace events at high frequency. More generally, this filtering
couples the rate of counter logging to the *value* of the counter ---
that is, we log ftrace events at different times depending on how much
memory we happen to have used --- and that's not ideal from a
predictability POV.

All things being equal, I'd prefer that we get things upstream as fast
as possible. But in this case, I'd rather wait for a general-purpose
filtering facility (whether that facility is based on histogram, eBPF,
or something else) rather than hardcode one particular fixed filtering
strategy (which might be suboptimal) for one particular kind of event.
Is there some special urgency here?

How about we instead add non-filtered tracepoints for the mm counters?
These tracepoints will still be free when turned off.

Having added the basic tracepoints, we can discuss separately how to
do the rate limiting. Maybe instead of providing direct support for
the algorithm that I described above, we can just use a BPF program as
a yes/no predicate for whether to log to ftrace. That'd get us to the
same place as this patch, but more flexibly, right?

