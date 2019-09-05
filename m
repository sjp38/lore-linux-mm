Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 658D1C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:23:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55A49207E0
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:23:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="hpdJnxdr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55A49207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EEC56B028A; Thu,  5 Sep 2019 10:23:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C7466B028B; Thu,  5 Sep 2019 10:23:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B4E66B028C; Thu,  5 Sep 2019 10:23:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id 68E4A6B028A
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:23:21 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id F3531181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:23:20 +0000 (UTC)
X-FDA: 75901084560.23.patch27_3a46201dd0d31
X-HE-Tag: patch27_3a46201dd0d31
X-Filterd-Recvd-Size: 6481
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:23:20 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id q10so1878393pfl.0
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 07:23:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=o0kJLOF+oseq1sFKQHmWAceakgmtIl8cUwVOf1CyohA=;
        b=hpdJnxdrixWVfeofcxwBZ6pDNTjh757qry9LSInbu6J/TKbviVyCRd4+icNXHOfbu/
         enOsoYQtx00GpthU5ztf0reocsmYwyDwhMRZW4u63+ccuTefIwvgH/4GI5O0qs9GGtD0
         ELjmFfLbDQjkIcAtui4m3jtUvnImposTuinC0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=o0kJLOF+oseq1sFKQHmWAceakgmtIl8cUwVOf1CyohA=;
        b=jDhUQqv5PkwizKsKv9aaNpDL6XWZJjP8nSCoL7YRar3ETcKJRP6NdG5W95jB0g36dI
         Lci8ZncBaKMg59W2ndCecDL7y1z5JCsgQ1ZjXokNt46B3HFRKAgubzlpq7qiS79H0T+C
         wjl0af40gQLIK4Br1ROnX78f99ahERGo/QCchfQTf0VlW1qklWl41gE5xPa9M1pMKZkc
         9WtykRoOr5xLjJdx+DEn0eEdUD9fPr7apbS9bJoGE4IAHWittrIhUy7Hpa3YKekYb1if
         AQ2YCpkETfGn5EcEor02IiHmuulpe+E+hUY4UEg7DNutlJLQoEF2UCq/bAIOAvd8HZK1
         no0A==
X-Gm-Message-State: APjAAAWKZxS23pFnvvGUEqDCLSzMYYG6gJtDyGr3yE8cRzcNXS8ydszY
	plHBRbDkRnY8q0dD/Q67A5BeEA==
X-Google-Smtp-Source: APXvYqyRmXPJSFub5OtQlmOXJveZtzr88UtyV9DSQaRDTAUPJYUtpXUW3xtLdzMJjjIysrig3oGj6w==
X-Received: by 2002:a17:90a:d793:: with SMTP id z19mr4077370pju.36.1567693399291;
        Thu, 05 Sep 2019 07:23:19 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id s5sm2470598pfm.97.2019.09.05.07.23.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 07:23:18 -0700 (PDT)
Date: Thu, 5 Sep 2019 10:23:17 -0400
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
Message-ID: <20190905142317.GD26466@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz>
 <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz>
 <20190904162808.GO240514@google.com>
 <20190905105424.GG3838@dhcp22.suse.cz>
 <20190905141452.GA26466@google.com>
 <20190905142010.GC3838@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905142010.GC3838@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 04:20:10PM +0200, Michal Hocko wrote:
> On Thu 05-09-19 10:14:52, Joel Fernandes wrote:
> > On Thu, Sep 05, 2019 at 12:54:24PM +0200, Michal Hocko wrote:
> > > On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> > > > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > > > > > On Wed, Sep 04, 2019 at 10:45:08AM +0200, Michal Hocko wrote:
> > > > > > > On Tue 03-09-19 16:09:05, Joel Fernandes (Google) wrote:
> > > > > > > > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > > > > > > > memory hogs. Several Android teams have been using this patch in various
> > > > > > > > kernel trees for half a year now. Many reported to me it is really
> > > > > > > > useful so I'm posting it upstream.
> > > > > > > >
> > > > > > > > Initial patch developed by Tim Murray. Changes I made from original patch:
> > > > > > > > o Prevent any additional space consumed by mm_struct.
> > > > > > > > o Keep overhead low by checking if tracing is enabled.
> > > > > > > > o Add some noise reduction and lower overhead by emitting only on
> > > > > > > >   threshold changes.
> > > > > > >
> > > > > > > Does this have any pre-requisite? I do not see trace_rss_stat_enabled in
> > > > > > > the Linus tree (nor in linux-next).
> > > > > >
> > > > > > No, this is generated automatically by the tracepoint infrastructure when a
> > > > > > tracepoint is added.
> > > > >
> > > > > OK, I was not aware of that.
> > > > >
> > > > > > > Besides that why do we need batching in the first place. Does this have a
> > > > > > > measurable overhead? How does it differ from any other tracepoints that we
> > > > > > > have in other hotpaths (e.g.  page allocator doesn't do any checks).
> > > > > >
> > > > > > We do need batching not only for overhead reduction,
> > > > >
> > > > > What is the overhead?
> > > > 
> > > > The overhead is occasionally higher without the threshold (that is if we
> > > > trace every counter change). I would classify performance benefit to be
> > > > almost the same and within the noise.
> > > 
> > > OK, so the additional code is not really justified.
> > 
> > It is really justified. Did you read the whole of the last email?
> 
> Of course I have. The information that numbers are in noise with some
> outliers (without any details about the underlying reason) is simply
> showing that you are optimizing something probably not worth it.
> 
> I would recommend adding a simple tracepoint. That should be pretty non
> controversial. And if you want to add an optimization on top then
> provide data to justify it.

Did you read the point about trace sizes? We don't want traces flooded and
you are not really making any good points about why we should not reduce
flooding of traces. I don't want to simplify it and lose the benefit. It is
already simple enough and non-controversial.

thanks,

 - Joel


