Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4C4FC43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:15:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B7CB222BD
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:14:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="a2pBHK6e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B7CB222BD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CC0E6B0284; Thu,  5 Sep 2019 10:14:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07E206B0285; Thu,  5 Sep 2019 10:14:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAD5E6B0286; Thu,  5 Sep 2019 10:14:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0001.hostedemail.com [216.40.44.1])
	by kanga.kvack.org (Postfix) with ESMTP id CA6CF6B0284
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:14:56 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 66A7F7838
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:14:56 +0000 (UTC)
X-FDA: 75901063392.11.time80_8256e40ec4358
X-HE-Tag: time80_8256e40ec4358
X-Filterd-Recvd-Size: 5450
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:14:55 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id x15so1502947pgg.8
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 07:14:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2dyh/qzhi2qens90CnAyZpu8nc1Cd1yi17MqcISR+xc=;
        b=a2pBHK6eVeP+DeXitzdhwlEvM99BkuEdPz9b/HbbIFuBRONPO0F/o6Um+dJ+WhLiki
         loBC03lOXyRmzxlQZn5Tub6me3ggBWFKOWP+jpBivc0UDj0Fuao3xzjPV3fWdHbmL60s
         bMR4jmepYzML3yWOff4TJnVSFSDkAhK0twfJk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=2dyh/qzhi2qens90CnAyZpu8nc1Cd1yi17MqcISR+xc=;
        b=GGHoQXb3p0Rm5blXtI6G8Jb6FTM7qgZzb/gbd/Y+L7O1Ny93zkHlEBriEIvfJ2uWnt
         C0jcCqZ43F2GJwVTyY3DzuXGY28m8zMgClt8/CyS1n4RMSJBK6Nc+SZ7Mi6jm4T5BkmQ
         lz4cFnRyOur+U4CQh7V48fe8HiKjMAmB+TH7UdSomuqwwy8aSTLZfXlUROvCbIO7RtnV
         /lRT/wzraxGxBBnGMPXbcbG5yeC6nYqjwXV2gSdCsIfwRZcxe6pHqPANokLd6L5S0mUB
         ZYgQkiobfT96KALQia0lwAtuC4yw1SgQR3SGuL/NgTdllwnySQbGyL7QuUTv6Z0I/FLy
         fSEg==
X-Gm-Message-State: APjAAAWMovobBeF351ICYarj0ayoqdsdykQ16DTV9QV8JHMSDHZrQ4XE
	77KVokbgpLtnmTeO9UEH/eQmWQ==
X-Google-Smtp-Source: APXvYqyWhg5wWBza0xoQXn734lb+BXrNSStNRVuCl14e2+JVF+qyGjoVQWM/ZfKFG0+uOaZkfe8M4w==
X-Received: by 2002:a65:518a:: with SMTP id h10mr3310283pgq.117.1567692894079;
        Thu, 05 Sep 2019 07:14:54 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id l6sm8709786pje.28.2019.09.05.07.14.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Sep 2019 07:14:53 -0700 (PDT)
Date: Thu, 5 Sep 2019 10:14:52 -0400
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
Message-ID: <20190905141452.GA26466@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz>
 <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz>
 <20190904162808.GO240514@google.com>
 <20190905105424.GG3838@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190905105424.GG3838@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 12:54:24PM +0200, Michal Hocko wrote:
> On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > > > On Wed, Sep 04, 2019 at 10:45:08AM +0200, Michal Hocko wrote:
> > > > > On Tue 03-09-19 16:09:05, Joel Fernandes (Google) wrote:
> > > > > > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > > > > > memory hogs. Several Android teams have been using this patch in various
> > > > > > kernel trees for half a year now. Many reported to me it is really
> > > > > > useful so I'm posting it upstream.
> > > > > >
> > > > > > Initial patch developed by Tim Murray. Changes I made from original patch:
> > > > > > o Prevent any additional space consumed by mm_struct.
> > > > > > o Keep overhead low by checking if tracing is enabled.
> > > > > > o Add some noise reduction and lower overhead by emitting only on
> > > > > >   threshold changes.
> > > > >
> > > > > Does this have any pre-requisite? I do not see trace_rss_stat_enabled in
> > > > > the Linus tree (nor in linux-next).
> > > >
> > > > No, this is generated automatically by the tracepoint infrastructure when a
> > > > tracepoint is added.
> > >
> > > OK, I was not aware of that.
> > >
> > > > > Besides that why do we need batching in the first place. Does this have a
> > > > > measurable overhead? How does it differ from any other tracepoints that we
> > > > > have in other hotpaths (e.g.  page allocator doesn't do any checks).
> > > >
> > > > We do need batching not only for overhead reduction,
> > >
> > > What is the overhead?
> > 
> > The overhead is occasionally higher without the threshold (that is if we
> > trace every counter change). I would classify performance benefit to be
> > almost the same and within the noise.
> 
> OK, so the additional code is not really justified.

It is really justified. Did you read the whole of the last email?

thanks,

 - Joel


