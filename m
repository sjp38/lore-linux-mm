Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10E15C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 03:01:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC58C206DE
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 03:01:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="qKDIxdaB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC58C206DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C0C56B0007; Thu,  5 Sep 2019 23:01:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 371636B0008; Thu,  5 Sep 2019 23:01:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2602D6B000A; Thu,  5 Sep 2019 23:01:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id 0449D6B0007
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 23:01:46 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 87069824CA24
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 03:01:46 +0000 (UTC)
X-FDA: 75902995812.01.stew95_83c990a74c352
X-HE-Tag: stew95_83c990a74c352
X-Filterd-Recvd-Size: 7715
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 03:01:45 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id bd8so2376164plb.6
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 20:01:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VdtQHcHlOGfkgdoayOFupO26wYojQPptWdBT4QWZFV0=;
        b=qKDIxdaBOcENAQEPhYaySH0B5SQARhQhLC6br1u55nJm0eVwYM8SSQVmlFoHirjoub
         Q0JZknIUZ1KihMnJ+Y/QiW6S2D06im9oRco+h+YsqTvdg8pxq+y8iCrMrDOEZEZbIxig
         Ngr6Lv3il76BZi2EFjjXczMgUa5KVU0HK757M=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=VdtQHcHlOGfkgdoayOFupO26wYojQPptWdBT4QWZFV0=;
        b=UbSxjFH7BsJAwJDMHkN0vqKMIG8SHfVu5w2SvmOtvWYkg5PgXF15L29ExXaZ2NRThv
         jezPM3B7Ik1P0sbL5rLON1pWQqLOwa8Xz8xKW6m9GUFyQaFBu0YKGzQEV1LCTrbnEGau
         NXpBHFae/h73uPDa4HEAJjVCjKBMsqmVDVlrjF0Ba+aLHTA51hDh6BOnlNDCwI0qzYA2
         0B6+dgyL2vHOXWtV3KHOG0gWFMVd08HNHeHQfPa/9H16SZbBNSNkcBlmjqPaMJHuUr6h
         izvaaxgLVearL24xrpAAMH+zy8e9nltFx+Bt/J7y39Jm59g6SSrOZK+X50fSowb3fVQv
         uY1Q==
X-Gm-Message-State: APjAAAUt3TdpCU2MPCIHLrhSSdN8knX3BXE79n9aWhXj4V6q2IC1ldHR
	M/oOTCCW6MeWBmA0pjj9Wmyi3Q==
X-Google-Smtp-Source: APXvYqwZPj7q8xJbbhNyAYHvgPo532plxc4r83loWDY18f56T55uFaXSHxe+m00EA+dA31PShWQEPQ==
X-Received: by 2002:a17:902:bc4c:: with SMTP id t12mr6912147plz.90.1567738904014;
        Thu, 05 Sep 2019 20:01:44 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id d135sm4364879pfd.81.2019.09.05.20.01.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 20:01:43 -0700 (PDT)
Date: Thu, 5 Sep 2019 23:01:42 -0400
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
Message-ID: <20190906030142.GA29926@google.com>
References: <20190904084508.GL3838@dhcp22.suse.cz>
 <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz>
 <20190904162808.GO240514@google.com>
 <20190905144310.GA14491@dhcp22.suse.cz>
 <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
 <20190905133507.783c6c61@oasis.local.home>
 <CAKOZueuQpHDnk-3GrLdXH_N_5Z7FRSJu+cwKhHNMUyKRqvkzjA@mail.gmail.com>
 <20190906005904.GC224720@google.com>
 <CAKOZuevJyfZRFz3M5myLy+XpS=mAxYCf+oQ2csxCHh7VO-OrKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuevJyfZRFz3M5myLy+XpS=mAxYCf+oQ2csxCHh7VO-OrKw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 06:15:43PM -0700, Daniel Colascione wrote:
[snip]
> > > > > > > The bigger improvement with the threshold is the number of trace records are
> > > > > > > almost halved by using a threshold. The number of records went from 4.6K to
> > > > > > > 2.6K.
> > > > > >
> > > > > > Steven, would it be feasible to add a generic tracepoint throttling?
> > > > >
> > > > > I might misunderstand this but is the issue here actually throttling
> > > > > of the sheer number of trace records or tracing large enough changes
> > > > > to RSS that user might care about? Small changes happen all the time
> > > > > but we are likely not interested in those. Surely we could postprocess
> > > > > the traces to extract changes large enough to be interesting but why
> > > > > capture uninteresting information in the first place? IOW the
> > > > > throttling here should be based not on the time between traces but on
> > > > > the amount of change of the traced signal. Maybe a generic facility
> > > > > like that would be a good idea?
> > > >
> > > > You mean like add a trigger (or filter) that only traces if a field has
> > > > changed since the last time the trace was hit? Hmm, I think we could
> > > > possibly do that. Perhaps even now with histogram triggers?
> > >
> > > I was thinking along the same lines. The histogram subsystem seems
> > > like a very good fit here. Histogram triggers already let users talk
> > > about specific fields of trace events, aggregate them in configurable
> > > ways, and (importantly, IMHO) create synthetic new trace events that
> > > the kernel emits under configurable conditions.
> >
> > Hmm, I think this tracing feature will be a good idea. But in order not to
> > gate this patch, can we agree on keeping a temporary threshold for this
> > patch? Once such idea is implemented in trace subsystem, then we can remove
> > the temporary filter.
> >
> > As Tim said, we don't want our traces flooded and this is a very useful
> > tracepoint as proven in our internal usage at Android. The threshold filter
> > is just few lines of code.
> 
> I'm not sure the threshold filtering code you've added does the right
> thing: we don't keep state, so if a counter constantly flips between
> one "side" of the TRACE_MM_COUNTER_THRESHOLD and the other, we'll emit
> ftrace events at high frequency. More generally, this filtering
> couples the rate of counter logging to the *value* of the counter ---
> that is, we log ftrace events at different times depending on how much
> memory we happen to have used --- and that's not ideal from a
> predictability POV.
> 
> All things being equal, I'd prefer that we get things upstream as fast
> as possible. But in this case, I'd rather wait for a general-purpose
> filtering facility (whether that facility is based on histogram, eBPF,
> or something else) rather than hardcode one particular fixed filtering
> strategy (which might be suboptimal) for one particular kind of event.
> Is there some special urgency here?
> 
> How about we instead add non-filtered tracepoints for the mm counters?
> These tracepoints will still be free when turned off.
> 
> Having added the basic tracepoints, we can discuss separately how to
> do the rate limiting. Maybe instead of providing direct support for
> the algorithm that I described above, we can just use a BPF program as
> a yes/no predicate for whether to log to ftrace. That'd get us to the
> same place as this patch, but more flexibly, right?

Chatted with Daniel offline, we agreed on removing the threshold -- which
Michal also wants to be that way.

So I'll be resubmitting this patch with the threshold removed; and we'll work
on seeing to use filtering through other generic ways like BPF.

thanks all!

 - Joel


