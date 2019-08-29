Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8FBEC41514
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 00:42:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7873F23403
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 00:42:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pBO9kFI7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7873F23403
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDC576B0006; Wed, 28 Aug 2019 20:42:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8CBD6B000C; Wed, 28 Aug 2019 20:42:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DACC56B000D; Wed, 28 Aug 2019 20:42:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id B915B6B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 20:42:31 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 654A7AF80
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 00:42:31 +0000 (UTC)
X-FDA: 75873614502.21.tax49_33179cf9e4e1b
X-HE-Tag: tax49_33179cf9e4e1b
X-Filterd-Recvd-Size: 3754
Received: from mail-yw1-f67.google.com (mail-yw1-f67.google.com [209.85.161.67])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 00:42:30 +0000 (UTC)
Received: by mail-yw1-f67.google.com with SMTP id m11so565229ywh.3
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 17:42:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JGRwNGErn4fgKcrUQ6xiTdFGa/UMxL0bW7u4f7HW4+s=;
        b=pBO9kFI77gE/gtpKbWkDAhKyiVvqdGWPANz9tNI0ulLcwYHoReFSfdXsKvIH5b2ukK
         WGnn+9GA91GX0cvQr5BUecBkiW3S29/Rw0gTWQUMFlFjv518j/HXADFAj+4761buG12B
         iyiEMUsd42x8e+ChjWSlMASRf9onmoRTvLke52aYFW5iHXS/bcePN11ElmPPs2wEHwr+
         +lo9WwG12RwAezKZNZnE+4D2qf1ZmnQwI4Yefcvpkkl6fjQclDsYV6Df+hzX3xOmZ8Wm
         w625t6PosUftPeW/9D5oDaSYkeGL4TR12mZ+mdAvFl3FLIEjoe+eb+wrL1d7u+9yz/dL
         GWgA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=JGRwNGErn4fgKcrUQ6xiTdFGa/UMxL0bW7u4f7HW4+s=;
        b=TT2sSTMTkJaVBkRSHaoH77XDYKcbV6v37fve7uKiZgPJ1Mptf7HXdpdlA6lH29as8W
         +R1d03JgXhjjbwSG0AXldpkCYgdwLDNVRImAf5EPhKxA+rSJvyM4xLHerRkHflbQESps
         Np8D11j/VIg8kCF45x3Q3uzkCt7x9IlGM0m4lSNJaYTQvR5SmLlmeAMUmjOY9SLBawEI
         a9goGuh0J67qz2J386rShHIYFgNS/WDj8paZzMiha3JNbo+/FDZChpHJrRYBzn++aq/M
         TcRk0ZKQ7rSdGdMPxYSAiJ7+iLemcMO61djlFhMV2Bx7LHWGO2WR/rTxaJ6aaLt7E7iF
         /sag==
X-Gm-Message-State: APjAAAV4xMTYyEEj1kfpCIvEEnVWrz5rbGRb+Igi/gLQqhq+fTIX9L3o
	6MBo+1kos9iGg4UFXQZLGC1RYH1EbeVF4lYIcFwdNQ==
X-Google-Smtp-Source: APXvYqy5sKfSQACB2NAIiSOftUd7x4Lw2pJ4Aa//yGOwNk/VbNo7vi6L+kgnsQlyUjh9vJq+0hA9wmBNIT5b9wnNNlk=
X-Received: by 2002:a81:6643:: with SMTP id a64mr4939106ywc.205.1567039350010;
 Wed, 28 Aug 2019 17:42:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190826233240.11524-1-almasrymina@google.com> <20190828112340.GB7466@dhcp22.suse.cz>
In-Reply-To: <20190828112340.GB7466@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 28 Aug 2019 17:42:17 -0700
Message-ID: <CALvZod50oU2M6uhUU1JsBz+qWYgSCb9brMVVnxmGnzSRY+1k_w@mail.gmail.com>
Subject: Re: [PATCH v3 0/6] hugetlb_cgroup: Add hugetlb_cgroup reservation limits
To: Michal Hocko <mhocko@kernel.org>
Cc: Mina Almasry <almasrymina@google.com>, mike.kravetz@oracle.com, shuah@kernel.org, 
	David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, khalid.aziz@oracle.com, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-kselftest@vger.kernel.org, Cgroups <cgroups@vger.kernel.org>, 
	aneesh.kumar@linux.vnet.ibm.com, mkoutny@suse.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 4:23 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 26-08-19 16:32:34, Mina Almasry wrote:
> >  mm/hugetlb.c                                  | 493 ++++++++++++------
> >  mm/hugetlb_cgroup.c                           | 187 +++++--
>
> This is a lot of changes to an already subtle code which hugetlb
> reservations undoubly are. Moreover cgroupv1 is feature frozen and I am
> not aware of any plans to port the controller to v2. That all doesn't
> sound in favor of this change.

Actually "no plan to port the controller to v2" makes the case strong
for these changes (and other new features) to be done in v1. If there
is an alternative solution in v2 then I can understand the push-back
on changes in v1 but that is not the case here.

Shakeel

