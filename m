Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20BEFC3A5AA
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 16:28:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB69922CEA
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 16:28:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="FszKmCEw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB69922CEA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C49E6B0003; Wed,  4 Sep 2019 12:28:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64E6E6B0006; Wed,  4 Sep 2019 12:28:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EDDC6B0007; Wed,  4 Sep 2019 12:28:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 269756B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:28:12 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id CA0A4824CA30
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 16:28:11 +0000 (UTC)
X-FDA: 75897770382.26.house90_47775c7fb5a08
X-HE-Tag: house90_47775c7fb5a08
X-Filterd-Recvd-Size: 6767
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 16:28:10 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id d10so6956323pgo.5
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 09:28:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Yk/Zf1u2BdMMV+kkm5yvLh1KAtBPz3BEz98OU76ZcXI=;
        b=FszKmCEwYuTJXHPJSyXKFkAIkX06tgKEEJ8rXP+NANZXqsq2cuSCbfHGT0tbvOWm1W
         fP1DI5Nht8S23YelKpJfF72JQLn7Cw/ai1ygsPjE3Z1afhZajlZgIWlrzap+qjSOUjJv
         kRKicL5mPA9cDbjDOaaQv844KwyulIeQ3qAds=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=Yk/Zf1u2BdMMV+kkm5yvLh1KAtBPz3BEz98OU76ZcXI=;
        b=L3w6pWX3QK9pLzvAHRRCUd6x7ESMDoFEQ4eFr2wic/CSElo6u3Pm7z8+7FSRBcmirZ
         MCUNIF6buBjOiLMv8D4j+UHcu6R0Yr2j37BvesASL+zR8b+krqM8scPPytuFDkxHubha
         PzloG/dIRHLOXG0rGVcRKEUN5pwdDuNil8EqGLqWmpuSV7QYi64oa6HEqPgQDsKmvb4q
         a9N6+jhphNDUVDDjE0RiIABV46mL7ftXn/rRWZVJg9FZBBIwhQ4YLrHDfemrTHyAFb1I
         LXmrcfERkunm90y03DhMMc5twZpDWTN3NocMYu8P3xP4jUAj/ki9ilh4x7pqtTKG1kbS
         ZYag==
X-Gm-Message-State: APjAAAUug5lXFq4YsUQhktRP3OxmoJtn4udpkc3fjinUSG+eK4l1Wfr7
	ZoVsdoFcwA2aQ89DYuxd6JChxQ==
X-Google-Smtp-Source: APXvYqy/vA5T9EERpFZ83PCmkYnMQMAWGtTYiDxLWWOcUETRK9wxLZfVoiyrnwFmnOAVpknrG9HWlg==
X-Received: by 2002:a17:90a:b38e:: with SMTP id e14mr5364244pjr.120.1567614489660;
        Wed, 04 Sep 2019 09:28:09 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id q4sm9721913pfh.115.2019.09.04.09.28.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 09:28:09 -0700 (PDT)
Date: Wed, 4 Sep 2019 12:28:08 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>,
	carmenjackson@google.com, mayankgupta@google.com, dancol@google.com,
	rostedt@goodmis.org, minchan@kernel.org, akpm@linux-foundation.org,
	kernel-team@android.com,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Message-ID: <20190904162808.GO240514@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz>
 <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904153759.GC3838@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > On Wed, Sep 04, 2019 at 10:45:08AM +0200, Michal Hocko wrote:
> > > On Tue 03-09-19 16:09:05, Joel Fernandes (Google) wrote:
> > > > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > > > memory hogs. Several Android teams have been using this patch in various
> > > > kernel trees for half a year now. Many reported to me it is really
> > > > useful so I'm posting it upstream.
> > > >
> > > > Initial patch developed by Tim Murray. Changes I made from original patch:
> > > > o Prevent any additional space consumed by mm_struct.
> > > > o Keep overhead low by checking if tracing is enabled.
> > > > o Add some noise reduction and lower overhead by emitting only on
> > > >   threshold changes.
> > >
> > > Does this have any pre-requisite? I do not see trace_rss_stat_enabled in
> > > the Linus tree (nor in linux-next).
> >
> > No, this is generated automatically by the tracepoint infrastructure when a
> > tracepoint is added.
>
> OK, I was not aware of that.
>
> > > Besides that why do we need batching in the first place. Does this have a
> > > measurable overhead? How does it differ from any other tracepoints that we
> > > have in other hotpaths (e.g.  page allocator doesn't do any checks).
> >
> > We do need batching not only for overhead reduction,
>
> What is the overhead?

The overhead is occasionally higher without the threshold (that is if we
trace every counter change). I would classify performance benefit to be
almost the same and within the noise.

For memset of 1GB data:

With threshold:
Total time for 1GB data: 684172499 nanoseconds.
Total time for 1GB data: 692379986 nanoseconds.
Total time for 1GB data: 760023463 nanoseconds.
Total time for 1GB data: 669291457 nanoseconds.
Total time for 1GB data: 729722783 nanoseconds.

Without threshold
Total time for 1GB data: 722505810 nanoseconds.
Total time for 1GB data: 648724292 nanoseconds.
Total time for 1GB data: 643102853 nanoseconds.
Total time for 1GB data: 641815282 nanoseconds.
Total time for 1GB data: 828561187 nanoseconds.  <-- outlier but it did happen.

> > but also for reducing
> > tracing noise. Flooding the traces makes it less useful for long traces and
> > post-processing of traces. IOW, the overhead reduction is a bonus.
>
> This is not really anything special for this tracepoint though.
> Basically any tracepoint in a hot path is in the same situation and I do
> not see a point why each of them should really invent its own way to
> throttle. Maybe there is some way to do that in the tracing subsystem
> directly.

I am not sure if there is a way to do this easily. Add to that, the fact that
you still have to call into trace events. Why call into it at all, if you can
filter in advance and have a sane filtering default?

The bigger improvement with the threshold is the number of trace records are
almost halved by using a threshold. The number of records went from 4.6K to
2.6K.

I don't see any drawbacks with using a threshold. There is no overhead either
way. For system without split RSS accounting, the reduction in number of
trace records would be even higher significantly reducing the consumption of
the ftrace buffer and the noise that people have to deal with.

Hope you agree now?

thanks,

 - Joel


