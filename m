Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61976C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 15:59:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 217AF2175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 15:59:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Y2Nu9OJQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 217AF2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B45F88E0002; Mon, 28 Jan 2019 10:59:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACDBD8E0001; Mon, 28 Jan 2019 10:59:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 996118E0002; Mon, 28 Jan 2019 10:59:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 656CB8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:59:46 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id x64so9800126ywc.6
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:59:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yG+IPoHDMDTax/O7ZuXb5W3f6MupuLya0ZnIkWYX/6w=;
        b=pPEAn4jxgsAkYPEJ8iXkHPzU0kGAYMySu52YfeUf0W1dCWk2ZvPupMkGpd4EtMFqCb
         /MAG1oKgjVEtG2IRM7zhW2rZlqEHbK1BOEHXARfrpn9QcUkuQQ//z8eI+c441nJ3ko4A
         Au6c9Fo3E9CS7GPreoOeFz7/srxdNKIuFYangeEWXeuxJPcgpy4G+pBeQr0wftFSHpz/
         M15JKMuN5cLd0PnoBexqpflZc2AVWeKpk8k+UJKE5jwi3bYNeJYhPFidVfFETQQPmEbq
         E+PkR3BwwjaXzdSlqe0aUKHIRd7Re0kHUJ4FQTPau/dtcWgEkhgWdKuJH3hegSytVjKq
         4Yjw==
X-Gm-Message-State: AJcUukdVwR32Z5rEfScnwaMHwUBvHE8WohDsblLRhXNt1Xpp4e8kJ6ps
	vSMQRaPletDdH746Q1I9g5CY3Hrxv69rPxmKLL4qiWJJGV76CpayPyOSIPDlxJ2KHty6Xl2lrDC
	AlEpwelxPfuY7zCU7n6DrD1JcaOIMTSwI7VFdjmbIQjOcBEUUG6P2CVqNV8nVl+eeFjp4WpdxPv
	tnZfJFeCoG4VeH2j6gRuCzL7brI4ymZHDZwiHoyL2zOi0b6yeGSN8lbWwLK9aOB+GFX92UIHxV1
	nQUs8EHBIzcyKp87IRN80ucfyEZbEEOwZb3HSsqLIs7McLhdjyFYHRxfev4NK9gVIAxlyM3XOMk
	Vim+HSP6D+sr93tSfQhFV168AMnxERdKm/3TGHaCMToNUzm3MIMW6SZuNc3UJWAcarLPsWKcwfX
	k
X-Received: by 2002:a5b:4c1:: with SMTP id u1mr20862480ybp.82.1548691185995;
        Mon, 28 Jan 2019 07:59:45 -0800 (PST)
X-Received: by 2002:a5b:4c1:: with SMTP id u1mr20862447ybp.82.1548691185367;
        Mon, 28 Jan 2019 07:59:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548691185; cv=none;
        d=google.com; s=arc-20160816;
        b=b2MEqyNMvqNsTLPZr+QhU8G6vt4lmgXN9TGzX+63Fjs/2Y8JcOPBAVKZxg3/oWzoYT
         W70FWiSYntg0dlLxXp2EP30McmlTPmmOzuxrfV50GKsjFYKDxiobV+LKc9bnPTy9rvkN
         XB0Dp7adyjqJ5aUAZsAu8VmY6mGV8YqV8MhW3OKkXoqAffrPZUpnsCVfT4brk91S197z
         Iqd2f8rAo07+iVYzTMrZNRWGKTYTa75KSpNO4ePoN46R0C/VOP1Irt8cTrQNDNSBuIqI
         TVytiCOYnKF7F5VJRzgSLWvCtLyV2bGVv6cgSQM6xDikedoUgiE8DdYtt1gC5R7bOtjC
         evBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yG+IPoHDMDTax/O7ZuXb5W3f6MupuLya0ZnIkWYX/6w=;
        b=dZRm3GBaxTkk8AVMhSm42pLoS31ylNx304TcwhqkjFWykDj3+6G6HYRZMeB68klNQv
         MZkgjCP8TTAORazrQWPOcsuJ83fQLORdxwIjtyKuUH/BUwgDg7859D8kIDUiohXvJv5K
         iOpoOdBRyzQHzleJ3KHNCt+mtBfYP/W55nFOZktVRe5Qr3zUxHcHJVDCKTcXXHwoDmM9
         cE7OeTTxzyTsQ3jCnGIUAZ0btqj6VLd4xwqn4hhZfKlrK0KB7orfPdlPpaCIbdtE1nQs
         WXCoyDdv2T4fBzcLFK+3ZV/P1HeCYVQiUWPw6yQW+dkV7PYZ9mpnMKpK2yyP3X2RYcJH
         Mfow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Y2Nu9OJQ;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor5837759ywm.164.2019.01.28.07.59.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 07:59:45 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Y2Nu9OJQ;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yG+IPoHDMDTax/O7ZuXb5W3f6MupuLya0ZnIkWYX/6w=;
        b=Y2Nu9OJQzhF0nbbJyWful5kNWyBwddZ1f1VkAn29tp8WPoA3LQEpNLrXI0kn9uVKgy
         OlGZ5zSDZ626uxv8mP78Rj7AY2v4WkaCfuHsdJlBn+xXi/4FgKXoDRlJQ+mYBvaUcEBs
         /SM7LUD6MvsgbB1WryhJ8dhabqGvs4Z7Y6u8y+ALxnGe8PYsUrAJJ5Y/szN5wT1FRpNF
         mB6Q3M2uWHzBMJQYukDpHZlc+LY9Usy04PZ+TuJ6YRjmujaKDcTm2vvts6QrF8UMvKSD
         nwJH1risZ+AEEBgV+6YVoz9pRI6Oquh247133FVA/eaZMzmKJy+IaVYXqtOvdwRjrchm
         ysOw==
X-Google-Smtp-Source: ALg8bN7fCDdqmT/Poi2kifvBPpqajT1d4G+DhyRvU7E2FrC8gKAWDBqOykP3e9SscAD5+1zazZ4ERAHo037J/PrOYpg=
X-Received: by 2002:a81:ee07:: with SMTP id l7mr21402528ywm.489.1548691184840;
 Mon, 28 Jan 2019 07:59:44 -0800 (PST)
MIME-Version: 1.0
References: <20190123223144.GA10798@chrisdown.name> <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org> <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org> <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com> <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
In-Reply-To: <20190125182808.GL50184@devbig004.ftw2.facebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 28 Jan 2019 07:59:33 -0800
Message-ID:
 <CALvZod6LFY+FYfBcAX0kLxV5KKB1-TX2cU5EDyyyjvHOtuWWbA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, kernel-team@fb.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128155933.bnaG6aPWmMBR8ipdSemcgEdOpyU6vXw8hO5oaEuSAOM@z>

Hi Tejun,

On Fri, Jan 25, 2019 at 10:28 AM Tejun Heo <tj@kernel.org> wrote:
>
> Hello, Michal.
>
> On Fri, Jan 25, 2019 at 06:37:13PM +0100, Michal Hocko wrote:
> > > What if a user wants to monitor any ooms in the subtree tho, which is
> > > a valid use case?
> >
> > How is that information useful without know which memcg the oom applies
> > to?
>
> For example, a workload manager watching over a subtree for a job with
> nested memory limits set by the job itself.  It wants to take action
> (reporting and possibly other remediative actions) when something goes
> wrong in the delegated subtree but isn't involved in how the subtree
> is configured inside.
>

Why not make this configurable at the delegation boundary? As you
mentioned, there are jobs who want centralized workload manager to
watch over their subtrees while there can be jobs which want to
monitor their subtree themselves. For example I can have a job which
know how to act when one of the children cgroup goes OOM. However if
the root of that job goes OOM then the centralized workload manager
should do something about it. With this change, how to implement this
scenario? How will the central manager differentiates between that a
subtree of a job goes OOM or the root of that job? I guess from the
discussion it seems like the centralized manager has to traverse that
job's subtree to find the source of OOM.

Why can't we let the implementation of centralized manager easier by
allowing to configure the propagation of these notifications across
delegation boundary.

thanks,
Shakeel

