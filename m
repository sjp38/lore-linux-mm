Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4409C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:51:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71B7020828
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:51:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WHn/mLxT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71B7020828
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C86556B0007; Thu,  5 Sep 2019 13:51:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C38106B0008; Thu,  5 Sep 2019 13:51:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4CC76B000A; Thu,  5 Sep 2019 13:51:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8E92F6B0007
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:51:05 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 398722C7C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:51:05 +0000 (UTC)
X-FDA: 75901608090.07.fork69_7ddab4c99241e
X-HE-Tag: fork69_7ddab4c99241e
X-Filterd-Recvd-Size: 6268
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:51:04 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id 67so3083473oto.3
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 10:51:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=s9Pb/MqseZ7RlVVs3CNYNbMIo2YR/MhIel99V5tLuCc=;
        b=WHn/mLxT0ucnyH4gwmp/qpzJbEfaFthNeKdoZwnD/B6/MVQRQqb4wZywL53jq1qIaV
         gb+TdKsinHPlj+LQlhJoWRU/D7IK2UvLu1uZIbpc98h3j/SLg1FkucCLBSn6QE6a4xv4
         8A5stXVWsUc3IDcyzSxMHbj/jVhShunx3l22pRcWTxEOi/t6ar1ofl0voxcoIdRfl5r0
         JMwCWrcjsdNR+EnBKm+WG+n9gRil9h1uAYDHR5V3SPQZC5up027FI9BVXsnmIJn/wGLH
         a5ELOGPKH2gOOayWt8fPr7sEKLjPvuIF8jdNUuBz8MhE7vzVl2frNjh13WOdqLyRGTLI
         PW/A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=s9Pb/MqseZ7RlVVs3CNYNbMIo2YR/MhIel99V5tLuCc=;
        b=Ug9mzyRUKaJ0WFuGBhPnDVgXIUYrPEE0K2j3h+NnNFiioaKs3ma1oHpWYKSxfXfY8D
         iQZrtIuxhcy3695VirZy6N3y0WG5yPF51ttvR7M2z5s0PBcbLCSzI5j9JLRovNVbQxg6
         9+DoSJPZ4wuUVvyPvGAQpiEgSSxrzZO9Cm6j5O0K8ziXSxwgrf2eSdHGdV8QOsIi1eRK
         IQIX1l8i4ruyZ8S11m6f15J35476+JeYv3VQDuxSa08p+d108EKsaZKZynKRJc0eZzrF
         MkFcqiuGTZ4p9EqFdn/DHzzqu9507EyMOPCJmb7VQzNyr4t4tv8yoO9UzfjxE9m0qkzm
         f8bw==
X-Gm-Message-State: APjAAAXTB4LfnbK2wavwmPvvfB3Ez+XGsHrmYgAa5+n9csNny+ycTwzV
	xY6dh9G6Yloc0th01mbNpRmn3WQpBIqe33k2D5Y7CQ==
X-Google-Smtp-Source: APXvYqx+O95sXPOaTHKmmrEZVVL5eS8xtFX8KqFEqk0X7AW7J5pOo+WfqsgcGe3pEdAmKOQmEsoGk9XDlW0GP0jc0wc=
X-Received: by 2002:a9d:6189:: with SMTP id g9mr3419331otk.348.1567705863632;
 Thu, 05 Sep 2019 10:51:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz> <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz> <20190904162808.GO240514@google.com>
 <20190905144310.GA14491@dhcp22.suse.cz> <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
 <20190905133507.783c6c61@oasis.local.home>
In-Reply-To: <20190905133507.783c6c61@oasis.local.home>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 5 Sep 2019 10:50:27 -0700
Message-ID: <CAKOZueuQpHDnk-3GrLdXH_N_5Z7FRSJu+cwKhHNMUyKRqvkzjA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Joel Fernandes <joel@joelfernandes.org>, LKML <linux-kernel@vger.kernel.org>, 
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

On Thu, Sep 5, 2019 at 10:35 AM Steven Rostedt <rostedt@goodmis.org> wrote:
> On Thu, 5 Sep 2019 09:03:01 -0700
> Suren Baghdasaryan <surenb@google.com> wrote:
>
> > On Thu, Sep 5, 2019 at 7:43 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > [Add Steven]
> > >
> > > On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> > > > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > > [...]
> > > > > > but also for reducing
> > > > > > tracing noise. Flooding the traces makes it less useful for long traces and
> > > > > > post-processing of traces. IOW, the overhead reduction is a bonus.
> > > > >
> > > > > This is not really anything special for this tracepoint though.
> > > > > Basically any tracepoint in a hot path is in the same situation and I do
> > > > > not see a point why each of them should really invent its own way to
> > > > > throttle. Maybe there is some way to do that in the tracing subsystem
> > > > > directly.
> > > >
> > > > I am not sure if there is a way to do this easily. Add to that, the fact that
> > > > you still have to call into trace events. Why call into it at all, if you can
> > > > filter in advance and have a sane filtering default?
> > > >
> > > > The bigger improvement with the threshold is the number of trace records are
> > > > almost halved by using a threshold. The number of records went from 4.6K to
> > > > 2.6K.
> > >
> > > Steven, would it be feasible to add a generic tracepoint throttling?
> >
> > I might misunderstand this but is the issue here actually throttling
> > of the sheer number of trace records or tracing large enough changes
> > to RSS that user might care about? Small changes happen all the time
> > but we are likely not interested in those. Surely we could postprocess
> > the traces to extract changes large enough to be interesting but why
> > capture uninteresting information in the first place? IOW the
> > throttling here should be based not on the time between traces but on
> > the amount of change of the traced signal. Maybe a generic facility
> > like that would be a good idea?
>
> You mean like add a trigger (or filter) that only traces if a field has
> changed since the last time the trace was hit? Hmm, I think we could
> possibly do that. Perhaps even now with histogram triggers?

I was thinking along the same lines. The histogram subsystem seems
like a very good fit here. Histogram triggers already let users talk
about specific fields of trace events, aggregate them in configurable
ways, and (importantly, IMHO) create synthetic new trace events that
the kernel emits under configurable conditions.

