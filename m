Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB2BFC43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:51:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF1222067B
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:51:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="p0LQqRPk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF1222067B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5837C6B0008; Thu,  5 Sep 2019 13:51:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55A866B000A; Thu,  5 Sep 2019 13:51:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46E746B000D; Thu,  5 Sep 2019 13:51:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id 240A56B0008
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:51:12 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A01042C6D
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:51:11 +0000 (UTC)
X-FDA: 75901608342.24.hot41_7ebdf50960820
X-HE-Tag: hot41_7ebdf50960820
X-Filterd-Recvd-Size: 7235
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:51:10 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id u17so1809369pgi.6
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 10:51:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=P5n5bs8SI52J5LlQpVwDbgDPxQsgUcewkC0J/JmCtuM=;
        b=p0LQqRPk+syQEYPmEik8s9anX9KtdGXOPNbz8uc3tn9PQs0q6ECcQZrq4P2XTdeUbX
         bTmGTz6Eur+1Rne7p/RWiVML6AY342jbOka5xCy+wuPK6QTL7HB8xFTNpMjInVqhE2kX
         rU4pd2mHkWqYwOLDd1sAHzLieLXn1ibhf8sKI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=P5n5bs8SI52J5LlQpVwDbgDPxQsgUcewkC0J/JmCtuM=;
        b=DNwBLB0ILDGGkRZNEjeXyhEmziTsTAYxnoYSoXOqchxFJlrfQ7PkpRh+WmaoRqrP0e
         9umlE0iZiEvIViPVKcPGYH/yURq8HkZHC1EU1UieDrsinpvQMqbooXo/XTC8UG2Na1pu
         45RNH9j5F/+r9hagd3/cshe954l8DQUA8aa68NZMvR3mGjVukQE4gyAQpnTusmu9XFjg
         JF1kbunCM9uHr0/pAeX8cKDR92Iv8tK7sb4enEWrB6I0zml/joclrRKxgrxYSxJwsSZA
         zCG6ofwc+N8j0pFz6P9QTu7kNx9v8eL66XXARa/l6cMutFOhNe4GG1uKFY+tEckXJuZT
         1meg==
X-Gm-Message-State: APjAAAXHHYlxCWR3363a6NLBHKbbOWh0Ng5l6Crl32hatn2WuOrNiphZ
	VpCFThB93sdoIo0KtWIbkYcOLg==
X-Google-Smtp-Source: APXvYqwD66TY8J7gU37j2YC0tRNQHoy4mdsqAc0PGGUncq1nwgcj9+YoSQUtf7A44mSZFVEbBtAo2g==
X-Received: by 2002:a63:f13:: with SMTP id e19mr4333234pgl.132.1567705869647;
        Thu, 05 Sep 2019 10:51:09 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id r23sm3146316pjo.22.2019.09.05.10.51.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 10:51:09 -0700 (PDT)
Date: Thu, 5 Sep 2019 13:51:08 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>,
	Carmen Jackson <carmenjackson@google.com>,
	Mayank Gupta <mayankgupta@google.com>,
	Daniel Colascione <dancol@google.com>,
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
Message-ID: <20190905175108.GB106117@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz>
 <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz>
 <20190904162808.GO240514@google.com>
 <20190905144310.GA14491@dhcp22.suse.cz>
 <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
 <20190905133507.783c6c61@oasis.local.home>
 <20190905174705.GA106117@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905174705.GA106117@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 01:47:05PM -0400, Joel Fernandes wrote:
> On Thu, Sep 05, 2019 at 01:35:07PM -0400, Steven Rostedt wrote:
> > 
> > 
> > [ Added Tom ]
> > 
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
> 
> Hey Steve,
> 
> Something like an analog to digitial coversion function where you lose the
> granularity of the signal depending on how much trace data:
> https://www.globalspec.com/ImageRepository/LearnMore/20142/9ee38d1a85d37fa23f86a14d3a9776ff67b0ec0f3b.gif

s/how much trace data/what the resolution is/

> so like, if you had a counter incrementing with values after the increments
> as:  1,3,4,8,12,14,30 and say 5 is the threshold at which to emit a trace,
> then you would get 1,8,12,30.
> 
> So I guess what is need is a way to reduce the quantiy of trace data this
> way. For this usecase, the user mostly cares about spikes in the counter
> changing that accurate values of the different points.

s/that accurate/than accurate/

I think Tim, Suren, Dan and Michal are all saying the same thing as well.

thanks,

 - Joel


