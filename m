Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C977C43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 00:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 189AA207E0
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 00:59:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="wonuGwVV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 189AA207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 491FD6B0003; Thu,  5 Sep 2019 20:59:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 441F16B0006; Thu,  5 Sep 2019 20:59:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 359106B0007; Thu,  5 Sep 2019 20:59:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id 146A66B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 20:59:09 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id AC055180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 00:59:08 +0000 (UTC)
X-FDA: 75902686776.24.jelly06_4fc0009f0470c
X-HE-Tag: jelly06_4fc0009f0470c
X-Filterd-Recvd-Size: 7193
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 00:59:07 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id gn20so2239342plb.2
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 17:59:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TmV1LoZm0dueIxfpGTuco3s5i09fedqQ9LvJDU+DD/k=;
        b=wonuGwVVxxQX5ovy7PsPBul4VqqNeDjDgJgFjChMt5Z98RqN2M/WGL3JOHCCmm07Kt
         vE1Drt0ItxpPGb7Wt0GoncH4bfEtTL9oM28/hGMi23N/4+nYzKpof7lpKT4jLlQc0P7H
         6EoPsoCrNH4Ed4031JH2ZnYARGy89wZJYDCCo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=TmV1LoZm0dueIxfpGTuco3s5i09fedqQ9LvJDU+DD/k=;
        b=fAzrO35XqWJf4rlzah/31Ko82QKlgcoLyqaLFoRh4TdY8l/XTROUH8vdZBq8s35BrL
         AKPw7lsdrnWtP9kWMUxyU4Rswhj2te+cDbZqerTcjlj6G7hsObaTyja5VTtRbIcah9cQ
         3DiHezfoPa0PjLS8RqWuMq+R0sWX+RPuwepTBINkQuFYkFPdQxnoWZfU2miZujeywByM
         xmubQYAv4J9tahp1a0HNacVlgpppQ/eNxokUrfeNXFpg6cwtGHBolA6KPiyEJixXTSu0
         Z50BiLYVuUb/nRaDL7xjaV4lBsMZdFQMpUDaqKA4DKpJ1cL0QFIM35Zk+/irCdVbZ4G8
         YWsg==
X-Gm-Message-State: APjAAAWztsmR4QX6OOLmHuJgjLKTM4Y8B/aLSlBKRqLx+OhLSmcUHO+D
	9oSjdmSvPBm3El0mXUufgQgfvw==
X-Google-Smtp-Source: APXvYqzKnRKXTbSewo9g+sqatp0lpebbLQ+O5ZjVk6KyfUgoEx1mnZrToEnmEzWYMkrlV8PzqqfD7w==
X-Received: by 2002:a17:902:9698:: with SMTP id n24mr6800014plp.14.1567731546601;
        Thu, 05 Sep 2019 17:59:06 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id i14sm4188593pfo.50.2019.09.05.17.59.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 17:59:05 -0700 (PDT)
Date: Thu, 5 Sep 2019 20:59:04 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Daniel Colascione <dancol@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>,
	Carmen Jackson <carmenjackson@google.com>,
	Mayank Gupta <mayankgupta@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	kernel-team <kernel-team@android.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jerome Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>,
	Matthew Wilcox <willy@infradead.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>, Tom Zanussi <zanussi@kernel.org>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Message-ID: <20190906005904.GC224720@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz>
 <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz>
 <20190904162808.GO240514@google.com>
 <20190905144310.GA14491@dhcp22.suse.cz>
 <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
 <20190905133507.783c6c61@oasis.local.home>
 <CAKOZueuQpHDnk-3GrLdXH_N_5Z7FRSJu+cwKhHNMUyKRqvkzjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZueuQpHDnk-3GrLdXH_N_5Z7FRSJu+cwKhHNMUyKRqvkzjA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 10:50:27AM -0700, Daniel Colascione wrote:
> On Thu, Sep 5, 2019 at 10:35 AM Steven Rostedt <rostedt@goodmis.org> wrote:
> > On Thu, 5 Sep 2019 09:03:01 -0700
> > Suren Baghdasaryan <surenb@google.com> wrote:
> >
> > > On Thu, Sep 5, 2019 at 7:43 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > [Add Steven]
> > > >
> > > > On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> > > > > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > >
> > > > > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > > > [...]
> > > > > > > but also for reducing
> > > > > > > tracing noise. Flooding the traces makes it less useful for long traces and
> > > > > > > post-processing of traces. IOW, the overhead reduction is a bonus.
> > > > > >
> > > > > > This is not really anything special for this tracepoint though.
> > > > > > Basically any tracepoint in a hot path is in the same situation and I do
> > > > > > not see a point why each of them should really invent its own way to
> > > > > > throttle. Maybe there is some way to do that in the tracing subsystem
> > > > > > directly.
> > > > >
> > > > > I am not sure if there is a way to do this easily. Add to that, the fact that
> > > > > you still have to call into trace events. Why call into it at all, if you can
> > > > > filter in advance and have a sane filtering default?
> > > > >
> > > > > The bigger improvement with the threshold is the number of trace records are
> > > > > almost halved by using a threshold. The number of records went from 4.6K to
> > > > > 2.6K.
> > > >
> > > > Steven, would it be feasible to add a generic tracepoint throttling?
> > >
> > > I might misunderstand this but is the issue here actually throttling
> > > of the sheer number of trace records or tracing large enough changes
> > > to RSS that user might care about? Small changes happen all the time
> > > but we are likely not interested in those. Surely we could postprocess
> > > the traces to extract changes large enough to be interesting but why
> > > capture uninteresting information in the first place? IOW the
> > > throttling here should be based not on the time between traces but on
> > > the amount of change of the traced signal. Maybe a generic facility
> > > like that would be a good idea?
> >
> > You mean like add a trigger (or filter) that only traces if a field has
> > changed since the last time the trace was hit? Hmm, I think we could
> > possibly do that. Perhaps even now with histogram triggers?
> 
> I was thinking along the same lines. The histogram subsystem seems
> like a very good fit here. Histogram triggers already let users talk
> about specific fields of trace events, aggregate them in configurable
> ways, and (importantly, IMHO) create synthetic new trace events that
> the kernel emits under configurable conditions.

Hmm, I think this tracing feature will be a good idea. But in order not to
gate this patch, can we agree on keeping a temporary threshold for this
patch? Once such idea is implemented in trace subsystem, then we can remove
the temporary filter.

As Tim said, we don't want our traces flooded and this is a very useful
tracepoint as proven in our internal usage at Android. The threshold filter
is just few lines of code.

thanks,

 - Joel


