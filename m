Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60258C04E87
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:11:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22DC92084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:11:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="diNffEIX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22DC92084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B13A56B0005; Wed, 15 May 2019 10:11:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9B666B0006; Wed, 15 May 2019 10:11:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9628B6B0007; Wed, 15 May 2019 10:11:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3B86B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 10:11:43 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id f138so2175090yba.4
        for <linux-mm@kvack.org>; Wed, 15 May 2019 07:11:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DkABSB9+ocVSEDM1acJkspFNCkj7bZrir9llBRZBZbk=;
        b=GjLgmhKoEaHwcQYjMIVNGCs/HGUiKgOoUGGbe8XD0zKZvCu12A43EJmtHxdZ1i/sZs
         +5xrgnenw7NpTQCviWmqNt+q34f2WrJ8ziZViu9I8HbmF2mm5amzd1BZTu89fOujoI3q
         K9gqQmEWMKQJPAMn24X4O3YGKJM4fciKBhnNndmCFyBnmcHLXgjrwdNf4Gt0ml2YTj2c
         tRhL3p6c0F60fj18fmWtbIip5BZTFYSgaHsbHCTEV2JJGCiF1lg8f6fVpOsfNRX0gZfV
         Nw9DEFsNjN5VXUfRPEKvOzDqICZotpS9EMUC45bfV04Iq6R2IkJWBNIkP0L7f9zsPAsB
         uHJQ==
X-Gm-Message-State: APjAAAVtbgQbhuh1IqKeJl6T0higox73j9fB6owiqMXemHLDZGIv8cU1
	Wfe809Bis7D0VFmBYTJW2HDE18HJqsVewwbRgePwbY3gEvlhAGXkJOhDGOL4GVkFrn2sm9o3IFE
	8fGGiGxHzUGarmF1zVytPvoTNMQgRGQcpdbeNtoOSSfyR53f2ABivSMcGe/u8rWKyLw==
X-Received: by 2002:a81:340b:: with SMTP id b11mr18598874ywa.98.1557929503039;
        Wed, 15 May 2019 07:11:43 -0700 (PDT)
X-Received: by 2002:a81:340b:: with SMTP id b11mr18598839ywa.98.1557929502465;
        Wed, 15 May 2019 07:11:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557929502; cv=none;
        d=google.com; s=arc-20160816;
        b=oOfFsundHXbyAYFF8Hcvl2nDArXO56Fn97DnuAK80ShfluzlkDCUex778MmUBS3/9B
         5eZBga1HtwFFvhF7Ty6NMD+xOHSUuPnl4ue90xUxj9I6MFYIZ9uvEz03hnv77YnzWCzs
         MRKv3cBelukO+55QvHNs+Ollfyes1VYn36xqgy+lQX2u53S00jQcLp6dkMX4SO5ligic
         Ju8MgObLAryQOJq/IJ5UzwQgPtZb8vSKvOlhmuaO6Y40CVVUjXNOHyv1N2hXznsGwXnP
         3QxY9cy6WFKwVzEKHNRIJPChPJi+rUslJokZOYg7f0ZZcJYFNg4JEJYy+RwpuxLqgWQI
         nRCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DkABSB9+ocVSEDM1acJkspFNCkj7bZrir9llBRZBZbk=;
        b=RPe8xJK11XiVklDhmpG25ynsv40Nb7oVJeXGmYC46IbiL7tdHmMIeImZrpg+9M2E/Y
         nids+/ynr9aJN2+3QtZ4pJhXq1zVb2+k7sGXmPSsH+hl3FWr16LE8IAx+z8faTDiq33e
         zUDzfN7YpQFUYZLD/bDYHhinDVPCA3AEuehMLuss9PgKSNtZAKf3ZK70zBPnJ4IuctdF
         CJeht0qZJHYGppY44V1Rv+s4OzHYj0fd1LpA8L8ZajRjofbhk4IlYTMxxZzjbUJVjz2v
         DIBwSjWAe0BJzPTV0JVtSlJ7PolwItMy/HfQEOYSL6xbQb0Ehm9wWdG7HI2wyx59M/5g
         74nA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=diNffEIX;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y9sor1026917ybh.81.2019.05.15.07.11.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 07:11:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=diNffEIX;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DkABSB9+ocVSEDM1acJkspFNCkj7bZrir9llBRZBZbk=;
        b=diNffEIXfA/QFvQ4JDN4yWPbBFk9QYgBHQ4+BVJ1NfD0TF6g+5vVE0YSL1BnVjtejf
         CrAeQK4hrTmj1WQuMCeXacIymo+qMfuKsRMkXThtVIfdGWD3UWU68tOQie85EkAx3kZA
         YA78rnXPrmWhtTDNmjqohIlpLATlRKpAgbVUzdHZ/0oIWDRCWeJPe4MkeQfL4NNPlAhb
         5gw18O/g48n/nZ7gRYd6s2xdXe7fCpmxbuVDtTd8Fhd7nK4blg8+HLxt6MmLicorJV+J
         ANLAPFx1lNLWprZ3HdLcTYYUg1gfx/xT6ADtn2L5nwfSQpvrZp2SEK2dbyUh8ZEYZ9Xq
         UKcQ==
X-Google-Smtp-Source: APXvYqwFVrkJc6Ars41vZLv1PWwWvp79P7NNy1HRLGKPliMA4SZgci9iPnaAggH1BDGnbrEDsgGovH0KqGY39VpJ6TM=
X-Received: by 2002:a25:4147:: with SMTP id o68mr20740148yba.148.1557929501573;
 Wed, 15 May 2019 07:11:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190514213940.2405198-1-guro@fb.com> <20190514213940.2405198-6-guro@fb.com>
 <0100016abbcb13b1-a1f70846-1d8c-4212-8e74-2b9be8c32ce7-000000@email.amazonses.com>
In-Reply-To: <0100016abbcb13b1-a1f70846-1d8c-4212-8e74-2b9be8c32ce7-000000@email.amazonses.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 15 May 2019 07:11:30 -0700
Message-ID: <CALvZod5dMM50pZWuOR5SN7aPPG8Zsp-+U3Y+q-UHTNo=Dgz-Nw@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] mm: rework non-root kmem_cache lifecycle management
To: Christopher Lameter <cl@linux.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Christopher Lameter <cl@linux.com>
Date: Wed, May 15, 2019 at 7:00 AM
To: Roman Gushchin
Cc: Andrew Morton, Shakeel Butt, <linux-mm@kvack.org>,
<linux-kernel@vger.kernel.org>, <kernel-team@fb.com>, Johannes Weiner,
Michal Hocko, Rik van Riel, Vladimir Davydov,
<cgroups@vger.kernel.org>

> On Tue, 14 May 2019, Roman Gushchin wrote:
>
> > To make this possible we need to introduce a new percpu refcounter
> > for non-root kmem_caches. The counter is initialized to the percpu
> > mode, and is switched to atomic mode after deactivation, so we never
> > shutdown an active cache. The counter is bumped for every charged page
> > and also for every running allocation. So the kmem_cache can't
> > be released unless all allocations complete.
>
> Increase refcounts during each allocation? Looks to be quite heavy
> processing.

Not really, it's a percpu refcnt. Basically the memcg's
percpu_ref_tryget* is replaced with kmem_cache's percpu_ref_tryget,
so, no additional processing.

