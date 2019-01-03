Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 293D4C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 17:04:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D77DB2070D
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 17:04:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FnFhqWjJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D77DB2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 724F38E008A; Thu,  3 Jan 2019 12:04:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D51D8E0002; Thu,  3 Jan 2019 12:04:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C4C48E008A; Thu,  3 Jan 2019 12:04:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6AC8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:04:11 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id v6so9840587ybm.11
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:04:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bOa5IQ+9QpakIS1qQWCjI383Pmf9DvpNGSYurftvPLs=;
        b=ufXisKFyCEZTzY5Z42LRaod3Dgdr1y6pPxy3RjfnLoxgY0M7zXaxmxQskLpWEzRFqs
         FMpmmiJ+Fpz9V2jXX5rxiqZVprylcWMLEJS579zI1uw/dkn1cgL9ou2dJ6l99ReZkUwS
         APveEw8Wp/hgNfflmf4MS6RjgT0zmTdhiR83EeKvR6T23TsGyW3+RPpRlQ5g+keYAqqP
         ABellEcKv297avPMPsf97CrkvUzTZrdAmkuSGMsMMiVtbdE2cmjwl1pXaJR2FOrvZYej
         QF+xpDuiNaZYCtdiMPWYmD7fuZMPzoVSLSskGzf0lisuI4I+O9pKZXib8Ao9yIBNxLqg
         KWbg==
X-Gm-Message-State: AA+aEWbNzBeNkRO99eok2e9Rubgq9puIaC0UMeNSHHlBSPfxGXQ6losK
	aHA/o8N/iEdQYKZbh+5+yqFHnIH/GB9cER06qpwNanVGlTaeXVQ7yTgCrUP2Qo5Eqsbzunwrvcf
	GbCTAkJF9HqOYHOFTHduC6Eia4I03teaNoPJ4cEyowgnJruDa6EtTkxbznYwrcS4oYFHAeDfs/+
	3LI5qSEnVKlkFOvRby50+Ibk6Mj+DWBLAkv/AUkmzZsg1zF2p0bMejSBi7NSpYlE4amk+pWruPS
	ffw4MVudjw6VazyEIMywPD7c5ATWAwfm8lCFM+sqwSgHH7Gun2x6vnRqbyYshoqgtFAcROlZbNB
	1V+iWYU7hM4dNf1+n1qdH8P9rpvBMazqPDwYme59wLVSIR0Z+OlqeMlMeD804FYn+3neqNfb2iu
	i
X-Received: by 2002:a81:7542:: with SMTP id q63mr46380206ywc.321.1546535050777;
        Thu, 03 Jan 2019 09:04:10 -0800 (PST)
X-Received: by 2002:a81:7542:: with SMTP id q63mr46380145ywc.321.1546535050098;
        Thu, 03 Jan 2019 09:04:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546535050; cv=none;
        d=google.com; s=arc-20160816;
        b=LuurYhjr9hA4CqvPJuZRBIA2iwG2p/6BsIjHHaVI7e5x8mRZuTQ6IRi3jip7NHvzLe
         4CXEHn+iprJG6j58O4dhSLlwfIXO5ZVRCqtgnA7zzEQJcxPOxV6Jld9zb9FKq0SAobGc
         hYRUm6p596yqh+DCz24KczpAVlUyNGJ7YTP601AFHMqCggile0sjp+wgGVp6MpyEVbZP
         c+rtNUrfkZ2XB5Q8S0uKxoTg4w5MZPrI5nz6L91uMsAA1TSDCyZQRyURtrefbZ6++9pt
         qTFzXbbFZ4IBOqPJuNP4i0JVK0q6N00yKdylVJ8NtE7pUGohc8gmDCI9XSfEnMT1ilvM
         sLiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bOa5IQ+9QpakIS1qQWCjI383Pmf9DvpNGSYurftvPLs=;
        b=z7ZsIYCxLDacG7rdyWwLhPGno3wuOTlbsGnC19zlsCKbXCP7LzwYWiOP0KGEHwjzyv
         XxcXEj2db7RgItLK0TUomDlhxUf+fGyPSosD/9UUHN3wUMRR+6zmhebWh88iJyERui8q
         UamClzsClaHnEBn3gR4vjO/bO7fx79G/14hLQH1BaAODOUvTdKTazFQJYw2Kagnmq88+
         B1l1uRGUDZ9Gw3BAo9zJ6qSvJtoUfE1tidVB6Tbq4kR+ndIB7fOs7ZrL8E2nH665SOg0
         uKqXiLX0qXpjK+BeR47MixsB8Cxa38vvKgjxXT+edWanVugtvAuFr3xGbYAb/YJHsbra
         xOgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FnFhqWjJ;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o192sor7627144ywo.136.2019.01.03.09.04.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 09:04:10 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FnFhqWjJ;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bOa5IQ+9QpakIS1qQWCjI383Pmf9DvpNGSYurftvPLs=;
        b=FnFhqWjJI8jMOGKfyG9SvTYBEw33RyGJef4mSM4iaKIcKQpGeKmA2CDVKj3xhplRFi
         PgxKW6LfkpIpRv6rDBCti1i4synkulMgENYelJloscl7kSZNxnFreycbr6dY69oUCBAy
         I3+lPz96ak5UtS8LVPPnDlG9z6h8hk9SfbaMkoZ6MZEwC4rYhpW5XMES9MQCHrAxdVgX
         XiZvHyB8dkr263E4XpfPFLvrdSQ0wn1nSxkMF5yMCvDmh9M+aK9T/DR7I1oXy5bbHehL
         +jPjGI2fg2qtCH8eFpoEG6V4wVmxZpxoS+K2QQ9j3/Os5s9fVzVIueifyLLzgYAUbIUi
         IwzA==
X-Google-Smtp-Source: AFSGD/W+8mJUletzYTpjEW3nYTKShDIMhSRtP1a2XGBUvlkFyAAT6bvtIfXSCb2cTn7KnXkl7XEDN6M07o2J+7DI9Uk=
X-Received: by 2002:a81:30d6:: with SMTP id w205mr49736002yww.27.1546535049481;
 Thu, 03 Jan 2019 09:04:09 -0800 (PST)
MIME-Version: 1.0
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <1546459533-36247-3-git-send-email-yang.shi@linux.alibaba.com>
 <CALvZod7X6FOMnZT48Q9Joh_nha6NMXntL3XqMDqRYFZ1ULgh=w@mail.gmail.com> <763b97f5-ea9c-e3e6-7fd9-0ab42cf09ca8@linux.alibaba.com>
In-Reply-To: <763b97f5-ea9c-e3e6-7fd9-0ab42cf09ca8@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 3 Jan 2019 09:03:58 -0800
Message-ID:
 <CALvZod5cZ60VkrxuO8o9dnSOhGmNt21o+NoS5Qy1Mh3-k6suyw@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: memcontrol: do not try to do swap when force empty
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103170358.xVf6tSLojcqBhCmhXyIRWQ0BpqII5Tu_nufrwjGmLtk@z>

On Thu, Jan 3, 2019 at 8:57 AM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>
>
> On 1/2/19 1:45 PM, Shakeel Butt wrote:
> > On Wed, Jan 2, 2019 at 12:06 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
> >> The typical usecase of force empty is to try to reclaim as much as
> >> possible memory before offlining a memcg.  Since there should be no
> >> attached tasks to offlining memcg, the tasks anonymous pages would have
> >> already been freed or uncharged.
> > Anon pages can come from tmpfs files as well.
>
> Yes, but they are charged to swap space as regular anon pages.
>

The point was the lifetime of tmpfs anon pages are not tied to any
task. Even though there aren't any task attached to a memcg, the tmpfs
anon pages will remain charged. Other than that, the old anon pages of
a task which have migrated away might still be charged to the old
memcg (if move_charge_at_immigrate is not set).

> >
> >> Even though anonymous pages get
> >> swapped out, but they still get charged to swap space.  So, it sounds
> >> pointless to do swap for force empty.
> >>
> > I understand that force_empty is typically used before rmdir'ing a
> > memcg but it might be used differently by some users. We use this
> > interface to test memory reclaim behavior (anon and file).
>
> Thanks for sharing your usecase. So, you uses this for test only?
>

Yes.

Shakeel

