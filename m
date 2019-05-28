Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96BF9C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:56:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 446832133F
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:56:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Dd/Xr8jA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 446832133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DED236B0276; Tue, 28 May 2019 10:56:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9EBA6B027A; Tue, 28 May 2019 10:56:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8D536B027C; Tue, 28 May 2019 10:56:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7E276B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 10:56:13 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id y185so18514408ybc.18
        for <linux-mm@kvack.org>; Tue, 28 May 2019 07:56:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jTlIgeBI8R5oN3O3HQ99I++T6jlNEV+UFbvjja9ZAd4=;
        b=f4Q/ikcWN16nbcuRQG8y2fH5kYtStI6wxVsgBEBUFBGZ3sCajL+hbMEvn3h19KJq8c
         NO6Ufl6odTQrixy1GQRVLi/IT3EfVQthVklja+6Jys+FP5mFgdCwwxV0YvWgmHcRoZoA
         DAAb+ds7zFHv7hvX8gBzRdLt+BcVsG6XoQITazfL4TstlI/5Z2JJZsHm0REcgbTYx3Kl
         Dg8r0MYhJgKPWkm+hik0jg5LZfhonGmGYODeR6V1/K+p+UGdFUZYlQqEgH76BUvg6hMW
         tNnzTMlSFSIjPyb9Rmwb8tlh3mu6st1Qm/fqXhfgDR5sjVPlZ8qRrjra8Q5iI/QbVE8Q
         1Dog==
X-Gm-Message-State: APjAAAXZabkXWS2a+lR2kU4WDRzS+S6+00bpDpAC/fsbNAvchT3ODkB/
	0QR4wkRP6GsVhUmlvbpiQ/ZM4ZNTmzRqPSj8QbEY/1xsyWQ6JNv+5V+RlGQ8RyIRkB7IjxUcuZ3
	iokbnbry2R/HzUmokXdJ3umfQtRRVmluIkSk+77yX9LFgRRcIW3LQaTr6wUj2jDNwQQ==
X-Received: by 2002:a25:ca08:: with SMTP id a8mr39804182ybg.285.1559055373317;
        Tue, 28 May 2019 07:56:13 -0700 (PDT)
X-Received: by 2002:a25:ca08:: with SMTP id a8mr39804155ybg.285.1559055372674;
        Tue, 28 May 2019 07:56:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559055372; cv=none;
        d=google.com; s=arc-20160816;
        b=FoyC159TGjMJxRIoLWAYWXrgbYc8S1l1rNMcJgCA+EZ0mQgmkGUAkxy0sKkjkd9VNY
         6GeuDJ8SQ5uu0SrP+xsnBn0ODQ57KQSTHRzW0DVJ/ROIUaaMMyGGhvkgzAPTV8McIqWN
         ef7mWz6B8sEdqPazYvfVYwIN3RKNq8NtPulYV2PLMos4VsnlmfN3DsLXSWakw8vDlQwI
         SANUso/DLJkA0KzLUdr1KWLqjNzTHTIK6wenEdG8VQWd3JgllbPumtyfG8PMSrkhe1pG
         TvlUAlMvRzIUSInW53km2nab/68tKktiWS7+f5eYiU+XzYSvwcND8vhTi73l7q7LpT6N
         Ogrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jTlIgeBI8R5oN3O3HQ99I++T6jlNEV+UFbvjja9ZAd4=;
        b=QnVRvu33bzq+2VDlqpQWMsL/LCqOIa6sWmIoOat9l5pec1zGbkANPKaQEhtKS2DVUM
         /Su/xaxGLey1TSk5mFBGdYV9bs8Vvy08UY6vL3/pdsu2tJpvAEN8e7k8JYAL87jhJ0kn
         15DMW/Mr0kez/LdsakXtjeuj/f/6AHYLxaorbQchP5kGe/Jf5BYFWJlhBTneeTT0SfI8
         uTNfP0NNdWbRdsUBP4aCcqlJeV0ynT9vi7jPcAF3YTUDqTFWdTMXZ6Q7wMIMf/g11NX0
         XDX/4h4IIYNFamNKxo8H9z044MOPZtRdA7L9/ylQlcJ8sMpZzhaagFpLw2/YQAmVAOBJ
         7tew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Dd/Xr8jA";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o67sor6648443ywf.215.2019.05.28.07.56.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 07:56:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Dd/Xr8jA";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jTlIgeBI8R5oN3O3HQ99I++T6jlNEV+UFbvjja9ZAd4=;
        b=Dd/Xr8jAObDU6D9ZyHopPb9p2XU0aQy+5Dp2qCVlY5+K+u8uFPGUTNWtUA4uZvV1rC
         16K+8dmbWHg7ykKlo9+yfIW53zK9R59RzBfnjrrMrCAeaTsu713KYjTk26zl/L6/IFmO
         i2+Enq9iPO+4cZgVEPtNB1nLDfJHsnmfvUL4X2Ln3s03Mg2VuVxTixykG3PrRLA8VW/k
         QO996765hLFUmCg7+/LeKPJfMaUWpbaA+ZORbgDbpJevZEoYtO/cCP1ihhFOaidAU+LY
         F5iWtIC5dwHah+OTNRTs7i3EU+loD5SpSbSsBYl5Vr5rRpNnoh06+ecieHQO7YBc7rtA
         zZNg==
X-Google-Smtp-Source: APXvYqw3Axo/+z3owEKgLL2LzIbxvY7WvXKmqyzQBHebVf3TKOElb4jbYm35ijLdq40mUgqSmfZZvLmPzTWeBVUYSJ4=
X-Received: by 2002:a81:5ec3:: with SMTP id s186mr61920764ywb.308.1559055372056;
 Tue, 28 May 2019 07:56:12 -0700 (PDT)
MIME-Version: 1.0
References: <155895155861.2824.318013775811596173.stgit@buzz>
 <20190527141223.GD1658@dhcp22.suse.cz> <20190527142156.GE1658@dhcp22.suse.cz>
 <20190527143926.GF1658@dhcp22.suse.cz> <9c55a343-2a91-46c6-166d-41b94bf5e9c8@yandex-team.ru>
 <20190528065153.GB1803@dhcp22.suse.cz> <a4e5eeb8-3560-d4b4-08a0-8a22c677c0f7@yandex-team.ru>
 <20190528073835.GP1658@dhcp22.suse.cz> <5af1ba69-61d1-1472-4aa3-20beb4ae44ae@yandex-team.ru>
 <20190528084243.GT1658@dhcp22.suse.cz>
In-Reply-To: <20190528084243.GT1658@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 28 May 2019 07:56:00 -0700
Message-ID: <CALvZod4fZeQiARaMrw8eaw=9Tynb4x4quZx13nen22EwoC5epQ@mail.gmail.com>
Subject: Re: [PATCH RFC] mm/madvise: implement MADV_STOCKPILE (kswapd from
 user space)
To: Michal Hocko <mhocko@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, 
	Roman Gushchin <guro@fb.com>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 1:42 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 28-05-19 11:04:46, Konstantin Khlebnikov wrote:
> > On 28.05.2019 10:38, Michal Hocko wrote:
> [...]
> > > Could you define the exact semantic? Ideally something for the manual
> > > page please?
> > >
> >
> > Like kswapd which works with thresholds of free memory this one reclaims
> > until 'free' (i.e. memory which could be allocated without invoking
> > direct recliam of any kind) is lower than passed 'size' argument.
>
> s@lower@higher@ I guess
>
> > Thus right after madvise(NULL, size, MADV_STOCKPILE) 'size' bytes
> > could be allocated in this memory cgroup without extra latency from
> > reclaimer if there is no other memory consumers.
> >
> > Reclaimed memory is simply put into free lists in common buddy allocator,
> > there is no reserves for particular task or cgroup.
> >
> > If overall memory allocation rate is smooth without rough spikes then
> > calling MADV_STOCKPILE in loop periodically provides enough room for
> > allocations and eliminates direct reclaim from all other tasks.
> > As a result this eliminates unpredictable delays caused by
> > direct reclaim in random places.
>
> OK, this makes it more clear to me. Thanks for the clarification!
> I have clearly misunderstood and misinterpreted target as the reclaim
> target rather than free memory target.  Sorry about the confusion.
> I sill think that this looks like an abuse of the madvise but if there
> is a wider consensus this is acceptable I will not stand in the way.
>
>

I agree with Michal that madvise does not seem like a right API for
this use-case, a 'proactive reclaim'.

This is conflating memcg and global proactive reclaim. There are
use-cases which would prefer to have centralized control on the system
wide proactive reclaim because system level memory overcommit is
controlled by the admin. Decoupling global and per-memcg proactive
reclaim will allow mechanism to implement both use-cases (yours and
this one).

The madvise() is requiring that the proactive reclaim process should
be in the target memcg.  I think a memcg interface instead of madvise
is better as it will allow the job owner to control cpu resources of
the proactive reclaim. With madvise, the proactive reclaim has to
share cpu with the target sub-task of the job (or do some tricks with
the hierarchy).

The current implementation is polling-based. I think a reactive
approach based on some watermarks would be better. Polling may be fine
for servers but for power restricted devices, reactive approach is
preferable.

The current implementation is bypassing PSI for global reclaim.
However I am not sure how should PSI interact with proactive reclaim
in general.

thanks,
Shakeel

