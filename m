Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D75DC3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 17:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D04821726
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 17:15:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mFbJyYSE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D04821726
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A23716B0003; Wed,  4 Sep 2019 13:15:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D3936B0006; Wed,  4 Sep 2019 13:15:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E9AA6B0007; Wed,  4 Sep 2019 13:15:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id 70C896B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:15:49 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 13EDDAF79
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 17:15:49 +0000 (UTC)
X-FDA: 75897890418.28.edge12_32ba1c5254c52
X-HE-Tag: edge12_32ba1c5254c52
X-Filterd-Recvd-Size: 8683
Received: from mail-oi1-f196.google.com (mail-oi1-f196.google.com [209.85.167.196])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 17:15:48 +0000 (UTC)
Received: by mail-oi1-f196.google.com with SMTP id h4so13089086oih.8
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 10:15:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FAQRTDxQC4SPRQKTTERofos9dmCviMTgEz8OVaFMxxc=;
        b=mFbJyYSEQOBs+e0VnJh3fmV6xlaPaCMJrS7TMeb3mcenxtxsLm0NSJCrTgjoAerk3s
         BfeeN3onERIgGuI6j4XbsiBK18BtW5uUu9kgdd+09UEtyQstfvNnLMEN1bhdSr4pdde5
         +yz1t22gaFdZgAIiratWmnGwA93tf+6ctZp+OrJNOXnoycC3b2tEQayRALaILTDvtmSP
         uUxIL9b6Hatt2KXbbbwKwJcYeUNHlfFF9/xZ1gqwURnJH8zFwz++l0JJfFLBLLNMX/aa
         q7K9BPzEEUwsxr4/Hnq0DauCZi7Y/UF9d2RjHK+bsn20g7+pF897P1S5ifSluy9L3lg2
         i1lA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=FAQRTDxQC4SPRQKTTERofos9dmCviMTgEz8OVaFMxxc=;
        b=TCTGh8AJo7ugw6MimOW4cLhDb+jIHTMEL8T2i0HfIWGpFaPHNIBm9YyZ8AzC+4thqA
         7H5UL1WqsRSrWGH0k09V9TOKfF0c3c8tQlvzsgUdXa1y7X6oNqdoGyaSJxBIYbC++i88
         4BHZjtsCfhdfXMjWcFYOdGcTzAJBixwznOuxlWjsReKx24exwtxzN372LIw8srVw01eD
         MjScnbPr/mcGv32F6iG3ULxafrwsrtrS2Rw4NIrOzKsGIloxzv5qC9/pUBUCdsGtMBuU
         Qost8yfZRziGtFL95Iri5sebWwiwvuUOsmy+VFPu5Z1GrYNG1rhYHfQV3nUi6y/KpflU
         AxeA==
X-Gm-Message-State: APjAAAW4zmNYg2LwW1SAr0YAm2cdOhbJ7I/fN9K8wQlfJU9DR4RU4XSc
	ogfUbzciSeFfJMvQDu9H+zBqT87p/wIDiBW516v8jA==
X-Google-Smtp-Source: APXvYqyB80kWmhIMIST+2gHB55jzSfcEhGbXhCK53P4qKR1FwW4TEXcNkMBNCtFoMK41XvEPZ2JU6+kARlgT5Kkilck=
X-Received: by 2002:a05:6808:209:: with SMTP id l9mr4336282oie.174.1567617347280;
 Wed, 04 Sep 2019 10:15:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
 <CAKOZuesWV9yxbS9+T5+p1Ty1-=vFeYcHuO=6MgzTY8akMhbFbQ@mail.gmail.com>
 <20190904051549.GB256568@google.com> <CAKOZuet_M7nu5PYQj1iZErXV8hSZnjv4kMokVyumixVXibveoQ@mail.gmail.com>
 <20190904145941.GF240514@google.com>
In-Reply-To: <20190904145941.GF240514@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 4 Sep 2019 10:15:10 -0700
Message-ID: <CAKOZuevvgANuaZc9P09=+tcM5MasPPvpkVmWf8wucsnVpdY8mg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Suren Baghdasaryan <surenb@google.com>, LKML <linux-kernel@vger.kernel.org>, 
	Tim Murray <timmurray@google.com>, Carmen Jackson <carmenjackson@google.com>, 
	Mayank Gupta <mayankgupta@google.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	kernel-team <kernel-team@android.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, 
	linux-mm <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.cz>, 
	Ralph Campbell <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 4, 2019 at 7:59 AM Joel Fernandes <joel@joelfernandes.org> wrote:
>
> On Tue, Sep 03, 2019 at 10:42:53PM -0700, Daniel Colascione wrote:
> > On Tue, Sep 3, 2019 at 10:15 PM Joel Fernandes <joel@joelfernandes.org> wrote:
> > >
> > > On Tue, Sep 03, 2019 at 09:51:20PM -0700, Daniel Colascione wrote:
> > > > On Tue, Sep 3, 2019 at 9:45 PM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > >
> > > > > On Tue, Sep 3, 2019 at 1:09 PM Joel Fernandes (Google)
> > > > > <joel@joelfernandes.org> wrote:
> > > > > >
> > > > > > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > > > > > memory hogs. Several Android teams have been using this patch in various
> > > > > > kernel trees for half a year now. Many reported to me it is really
> > > > > > useful so I'm posting it upstream.
> > > >
> > > > It's also worth being able to turn off the per-task memory counter
> > > > caching, otherwise you'll have two levels of batching before the
> > > > counter gets updated, IIUC.
> > >
> > > I prefer to keep split RSS accounting turned on if it is available.
> >
> > Why? AFAIK, nobody's produced numbers showing that split accounting
> > has a real benefit.
>
> I am not too sure. Have you checked the original patches that added this
> stuff though? It seems to me the main win would be on big systems that have
> to pay for atomic updates.

I looked into this issue the last time I mentioned split mm
accounting. See [1]. It's my sense that the original change was
inadequately justified; Michal Hocko seems to agree. I've tried
disabling split rss accounting locally on a variety of systems ---
Android, laptop, desktop --- and failed to notice any difference. It's
possible that some difference appears at a scale beyond that to which
I have access, but if the benefit of split rss accounting is limited
to these cases, split rss accounting shouldn't be on by default, since
it comes at a cost in consistency.

[1] https://lore.kernel.org/linux-mm/20180227100234.GF15357@dhcp22.suse.cz/

> > > I think
> > > discussing split RSS accounting is a bit out of scope of this patch as well.
> >
> > It's in-scope, because with split RSS accounting, allocated memory can
> > stay accumulated in task structs for an indefinite time without being
> > flushed to the mm. As a result, if you take the stream of virtual
> > memory management system calls that  program makes on one hand, and VM
> > counter values on the other, the two don't add up. For various kinds
> > of robustness (trace self-checking, say) it's important that various
> > sources of data add up.
> >
> > If we're adding a configuration knob that controls how often VM
> > counters get reflected in system trace points, we should also have a
> > knob to control delayed VM counter operations. The whole point is for
> > users to be able to specify how precisely they want VM counter changes
> > reported to analysis tools.
>
> We're not adding more configuration knobs.

This position doesn't seem to be the thread consensus yet.

> > > Any improvements on that front can be a follow-up.
> > >
> > > Curious, has split RSS accounting shown you any issue with this patch?
> >
> > Split accounting has been a source of confusion for a while now: it
> > causes that numbers-don't-add-up problem even when sampling from
> > procfs instead of reading memory tracepoint data.
>
> I think you can just disable split RSS accounting if it does not work well
> for your configuration.

There's no build-time configuration for split RSS accounting. It's not
reasonable to expect people to carry patches just to get their memory
usage numbers to add up.

> Also AFAIU, every TASK_RSS_EVENTS_THRESH the page fault code does sync the
> counters. So it does not indefinitely lurk.

If a thread incurs TASK_RSS_EVENTS_THRESH - 1 page faults and then
sleeps for a week, all memory counters observable from userspace will
be wrong for a week. Multiply this potential error by the number of
threads on a typical system and you have to conclude that split RSS
accounting produces a lot of potential uncertainty. What are we
getting in exchange for this uncertainty?

> The tracepoint's main intended
> use is to detect spikes which provides ample opportunity to sync the cache.

The intended use is measuring memory levels of various processes over
time, not just detecting "spikes". In order to make sense of the
resulting data series, we need to be able to place error bars on it.
The presence of split RSS accounting makes those error bars much
larger than they have to be.

> You could reduce TASK_RSS_EVENTS_THRESH in your kernel, or even just disable
> split RSS accounting if that suits you better. That would solve all the
> issues you raised, not just any potential ones that you raised here for this
> tracepoint.

I think we should just delete the split RSS accounting code unless
someone can demonstrate that it's a measurable win on a typical
system. The first priority of any system should be correctness.
Consistency is a kind of correctness. Departures from correctness
coming only from quantitatively-justifiable need.

