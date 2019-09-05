Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70808C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89425206DF
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:51:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dHJ3bLwn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89425206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AE016B0003; Thu,  5 Sep 2019 18:51:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7375E6B0006; Thu,  5 Sep 2019 18:51:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FDA46B0007; Thu,  5 Sep 2019 18:51:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0181.hostedemail.com [216.40.44.181])
	by kanga.kvack.org (Postfix) with ESMTP id 37F8B6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:51:58 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D045E181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:51:57 +0000 (UTC)
X-FDA: 75902366274.23.ants29_8583b2c159e51
X-HE-Tag: ants29_8583b2c159e51
X-Filterd-Recvd-Size: 4348
Received: from mail-vk1-f195.google.com (mail-vk1-f195.google.com [209.85.221.195])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:51:57 +0000 (UTC)
Received: by mail-vk1-f195.google.com with SMTP id 82so863726vkf.11
        for <linux-mm@kvack.org>; Thu, 05 Sep 2019 15:51:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AZyI05VZYlOHLVGP1sjJJPUL4F2uFByEj+mt1HHpIS8=;
        b=dHJ3bLwnjnryxwtM29ZQ7n1wQKxUzt0VnVdz/US7kDrOJCoxp9dTYJp68BCet8mdwc
         aKWlhNQDPhBFA4dTdsOXnXq6oBDXvuGfnccBVBsOwSWbKcJCSEQ0KEG4Cl18Zn3MJw4T
         M3jXGoB+KZgW9Ygf86B9mDCCodo4dHZ4J9KScwX2IR65+SpejSc2fNdXqZEGXa5sBXWm
         d0SHbcP04+Rk8IE53f2sXqpRWJ+b9LDGx0HAxhsTSHFBLvZWBJ/aZOVHuh45cWt5OzXL
         sDe6kKJr8DAppKrH02iuaMBeJsitIAMO1ioqZczD2lX08njHbtV9ZKXsDny7rN26cOUc
         Y0Qw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=AZyI05VZYlOHLVGP1sjJJPUL4F2uFByEj+mt1HHpIS8=;
        b=lYeigGrKKHVEoQTUh/7ebwJ87t1wzrH93cqxMd2DCWmWppcksZko0BFdOEoW77d+3S
         LALDq6SUYVupI8HK1Wym11M3s6ztyGHu+hD5WvYawOPbPH7lLLwGmqpLwJrVNTzg0vPF
         hAQqWGZmgYoyK6Gk3LRri9/X9AJP8RXM0bQpzXEoWjOR3lyzYUstxo5OI9rpYVmO4Egu
         xnTzWuTHXqPEdE+3cDSWb0w7nRLCTy0cAwseicCPwYAR8j15KQJOXIvBjeNCT3HqM+oq
         +PPAZ17jA+Geds/46hNGMI5fxQFNS1wTvm2E3ucjLqBZA8sQAN0HKyH/6tif11hAF7VD
         u7Bg==
X-Gm-Message-State: APjAAAWwfC44igLjNloc1q8LZmEKMTMbCWP0SkFZkRmvRfDy00ompN4E
	Bk+C7PWXoGgNQf2hOMTpeZiooTAy/pgoGsbcwHjMOA==
X-Google-Smtp-Source: APXvYqz6ti+rxtrP+RVfJsaZsc2bfJ1DYnmY/90nq3NltAjATPmgvKyDn7Z42q/cr/nxJboDCAfyITBtxFRA492fYlI=
X-Received: by 2002:a1f:c1c9:: with SMTP id r192mr2998246vkf.89.1567723916493;
 Thu, 05 Sep 2019 15:51:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz> <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz> <20190904162808.GO240514@google.com>
 <20190905144310.GA14491@dhcp22.suse.cz> <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
 <20190905133507.783c6c61@oasis.local.home> <20190905174705.GA106117@google.com>
 <20190905175108.GB106117@google.com> <1567713403.16718.25.camel@kernel.org>
 <CAKOZuescyhpGWUrZT+WpOoQP-gQ-8YYTyzwzZzBTxaJiLhMHxw@mail.gmail.com>
 <1567718076.16718.39.camel@kernel.org> <CAKOZuetfzp0FsB0cBd8mqQHQ=5t_fX-vCcBvYL71MPxtF6erTA@mail.gmail.com>
In-Reply-To: <CAKOZuetfzp0FsB0cBd8mqQHQ=5t_fX-vCcBvYL71MPxtF6erTA@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 5 Sep 2019 15:51:19 -0700
Message-ID: <CAKOZuetLW31vrsxndrH7gVh5er+J5DepBY6XcfxnFmZQaLWhrQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: Tom Zanussi <zanussi@kernel.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, Steven Rostedt <rostedt@goodmis.org>, 
	Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Tim Murray <timmurray@google.com>, 
	Carmen Jackson <carmenjackson@google.com>, Mayank Gupta <mayankgupta@google.com>, 
	Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	kernel-team <kernel-team@android.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, 
	linux-mm <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, 
	Ralph Campbell <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 5, 2019 at 3:12 PM Daniel Colascione <dancol@google.com> wrote:
> Basically, what I have in mind is this:

Actually --- I wonder whether there's already enough power in the
trigger mechanism to do this without any code changes to ftrace
histograms themselves. I'm trying to think of the minimum additional
kernel facility that we'd need to implement the scheme I described
above, and it might be that we don't need to do anything at all except
add the actual level tracepoints.

