Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02408C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 16:03:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 819CA206DE
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 16:03:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="r9T1e6uW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 819CA206DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5857C6B0010; Thu,  5 Sep 2019 12:03:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 535416B0266; Thu,  5 Sep 2019 12:03:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44B416B0272; Thu,  5 Sep 2019 12:03:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA2D6B0010
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 12:03:16 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B58CF40EC
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:03:15 +0000 (UTC)
X-FDA: 75901336350.18.dog99_39829add52b00
X-HE-Tag: dog99_39829add52b00
X-Filterd-Recvd-Size: 5429
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com [209.85.128.66])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 16:03:15 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id q12so3731486wmj.4
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 09:03:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xF5g9IO6jKnafhVzgDApXP2oM7DXnYkebnFH9y77eNE=;
        b=r9T1e6uWz1LE6nNNk8y0oqPRvd8zqa6gn7QDLNHiVCUH7vRly5jrqlmsPYtj9d1RKh
         v+3Esb1sjsGDRbND9GSNtycU3df7f7+1pEUYlkfnYh0Jripc/KwYnbfhlIbm982nC3Ev
         2R2yYm0BVRvJXOf4wvIf14T24AJ2P3aOei3lsX+3+tlRBZmQcprOacmv1tzWkgf6TGI3
         q6O9UGIv/4XF2K0O7xQ/SPUUjkipL3j/KcdRxrl9iSxEV8W5Do6YyDRK04T4DkGCS74o
         LimaWvMf0JtIOwj+brZ5XGVf7/gtJiq29j+6LA8fFMx8/NtiwAzun7s4pSONcQ1DkLWl
         pJZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=xF5g9IO6jKnafhVzgDApXP2oM7DXnYkebnFH9y77eNE=;
        b=hP7Ba0KXV4Rn/bobjHWvQoiAZXladWeG0MVUi0097TFIJStLToPWWQ2a6xTIAAL9ve
         sUVCPj1U9gMsUrEZ0FVUnCSMsSxHGkZikIfT50PBeTzPwSj4vZy8IvY1/2F3a3xD2/5r
         0fQ+abTe9Y43w3P6zxZnfwl+EDJtjAsvH1asHPq0QwQQ34cMsEiOB7Vf99UTXYMXqGAG
         3WZZQAZDQONmdO2wUowjtY8G4GkGfDNYqkk6mA9U5IFBHPOeYlUBSfA1JfylgcO7/hrh
         wRXdWR+KwAKWK2fZqnOVbn1Dsg+z5kfRMXI+wdYDV4zBr9PZ8KctiE0yA4T+COFrrqsQ
         u2OQ==
X-Gm-Message-State: APjAAAUy830dRHNsxXtKVTbQw2NYffQ5yi0SUqEZDM8S7l9bsIWYacsm
	0qnjYJZTVhoXiHY0+5c58SDS6bgCBQdIgMYaE6WauQ==
X-Google-Smtp-Source: APXvYqxn697f0MLbHLVLiNrv31ZON72Qw9YwLPyxM0jd0I67TVVrGvqak6f1I7B6szc8twvaNTAUZ5K2Mhj8xS132j0=
X-Received: by 2002:a1c:cfc9:: with SMTP id f192mr3378872wmg.85.1567699392897;
 Thu, 05 Sep 2019 09:03:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz> <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz> <20190904162808.GO240514@google.com> <20190905144310.GA14491@dhcp22.suse.cz>
In-Reply-To: <20190905144310.GA14491@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 5 Sep 2019 09:03:01 -0700
Message-ID: <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: Michal Hocko <mhocko@kernel.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, Steven Rostedt <rostedt@goodmis.org>, 
	LKML <linux-kernel@vger.kernel.org>, Tim Murray <timmurray@google.com>, 
	Carmen Jackson <carmenjackson@google.com>, Mayank Gupta <mayankgupta@google.com>, 
	Daniel Colascione <dancol@google.com>, Minchan Kim <minchan@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, kernel-team <kernel-team@android.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>, 
	Jerome Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Matthew Wilcox <willy@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 5, 2019 at 7:43 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> [Add Steven]
>
> On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> [...]
> > > > but also for reducing
> > > > tracing noise. Flooding the traces makes it less useful for long traces and
> > > > post-processing of traces. IOW, the overhead reduction is a bonus.
> > >
> > > This is not really anything special for this tracepoint though.
> > > Basically any tracepoint in a hot path is in the same situation and I do
> > > not see a point why each of them should really invent its own way to
> > > throttle. Maybe there is some way to do that in the tracing subsystem
> > > directly.
> >
> > I am not sure if there is a way to do this easily. Add to that, the fact that
> > you still have to call into trace events. Why call into it at all, if you can
> > filter in advance and have a sane filtering default?
> >
> > The bigger improvement with the threshold is the number of trace records are
> > almost halved by using a threshold. The number of records went from 4.6K to
> > 2.6K.
>
> Steven, would it be feasible to add a generic tracepoint throttling?

I might misunderstand this but is the issue here actually throttling
of the sheer number of trace records or tracing large enough changes
to RSS that user might care about? Small changes happen all the time
but we are likely not interested in those. Surely we could postprocess
the traces to extract changes large enough to be interesting but why
capture uninteresting information in the first place? IOW the
throttling here should be based not on the time between traces but on
the amount of change of the traced signal. Maybe a generic facility
like that would be a good idea?

> --
> Michal Hocko
> SUSE Labs
>
> --
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

