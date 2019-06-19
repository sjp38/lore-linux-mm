Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72E58C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:19:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B55021880
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:19:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZR7FWN5U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B55021880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 742896B0003; Wed, 19 Jun 2019 11:19:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F35A8E0002; Wed, 19 Jun 2019 11:19:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E28E8E0001; Wed, 19 Jun 2019 11:19:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4BF6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:19:07 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id e193so17756947ybf.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:19:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=497trEoQ+MnWiMrpBRDIQlRXiLccDLhvItPlHmc2I1Q=;
        b=dEZbHyK9JOOUeGTJq/AyIR0bvezvbglWLQlCs4SyMLmMwr0tl+1DN4Vc7VJAWajlIE
         8WvFmRoYbdRz1DHaZSFoU1wVpPNDTX4Slav/Z+U5OGJ1KIStslSL6xMgM1VnpCI5W1Oz
         xilL/OYrj6vuLx4lmX9DUxsQlcaS7I+ODsj+JYnOnkDEfAgvzzFGPNn2SYVYU5tUbahA
         th4xOWao14Pku0d73MlxW2QgfnYxe2fkS9Rt9YxDxFYCd24rwXX/weWPr8F9t5BToVmy
         i5Ih2KSgRJSHGliyDh9UNUh1TJN9UorcWREdAm9kHSFUS9LH5lUyJHfUZhP49oRItlSk
         L99Q==
X-Gm-Message-State: APjAAAVUv1AqsJZpfVD1ZFOq3Ctu05Hh/vOKjgR2QVaMhbYypTO1XPev
	DihT9t8qMvuObtUJVahsIeijTu9a7+HKLS6RdpT/363G98iJpv6rJtqR1L3Na3244CS+0jnvygJ
	XRKYAyKJzt5dmhxlNGxgdUOPguzbr9TAK058DAZhSe5fjDvaeKqXUKKwkjsiMmVSruw==
X-Received: by 2002:a81:2f88:: with SMTP id v130mr1962273ywv.452.1560957547015;
        Wed, 19 Jun 2019 08:19:07 -0700 (PDT)
X-Received: by 2002:a81:2f88:: with SMTP id v130mr1962237ywv.452.1560957546452;
        Wed, 19 Jun 2019 08:19:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560957546; cv=none;
        d=google.com; s=arc-20160816;
        b=HLdRFX6Mz1YHonDrG+voEba5u2+MWf6cNR6a5ajI3fD3HJP5dj4Xk8trlgZduKH8j0
         7Ro2A6Hn/nobI+VE/Db3L+I66ejUZwH02MjxadpqVK1tp+NSEQNElS/kSUzJfMg06UFM
         D+P1M80/mb6/7Q6ur3DFzRuSa+GhAbpGWTbrB/onRfbZHWnfi/awefGrHaZu1CiHSsMr
         BMtCg+3BkG7fYtZcuPucyiZqVDVhY9y+I8p5ItQ5+JZacNR8RHj2pf0eOjhFXkROSI18
         CORyXx7KjOHPetu9pB2Eu2KuX6dyMUTuSm2e/00D357ARbDAXcaOB6kMrp20JlC9r4T4
         /OJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=497trEoQ+MnWiMrpBRDIQlRXiLccDLhvItPlHmc2I1Q=;
        b=P2Zaena23DDBnUOYiAbHTkXUjR/eRWRQ2sbAEWVnKiCmx23H6jbjlzy6of9BKw/swb
         oY9u2RSyFILSaTPfU+NQWmwJuZ58Ch4aqQtPzFCs2w7dYh7tvSvqcoPSJZrkUVnle5mB
         XqvcNC4hHqPuCBTBOGBwrRjhLhtsug24o01XRtCQG8+1HzOVvc4s0K/4bFF0SahcuoKz
         gDQeyCU3pVk5OA0ZD1O3Xm892oibOu4xtyLI6IdYAeir8AjJxQD8+0rUaBJkdhFeDAJZ
         RbxpOaRuk+llD8HOnNwQ0HLV1jMNyiJbDGnW2wJc9v/28pYLcRMp+PZDQSHRsVCH9Ptt
         5MeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZR7FWN5U;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor9791274ywd.158.2019.06.19.08.19.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 08:19:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZR7FWN5U;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=497trEoQ+MnWiMrpBRDIQlRXiLccDLhvItPlHmc2I1Q=;
        b=ZR7FWN5U5wMegqY43k4e0b9xlbLxhcVnkfYP2AHyH+M2qYeniu7mKY8gJk9qmy9N+D
         Fcwbou95jnlSIcEp7YB8+U2/w75RN3uL9g+h0p61XsduShIlAJ/yp4GvBh7UVZzShYdL
         ywggJRFRqk8vYrbYPhJiSOd/027k/lIIfiCqwfLSN2Brxbqh+c7+7ZBp5WEEPUBhFEC8
         XoSEqYMf7pMdG3iK9KeaRn79zsByPzakG+RpzbNLFBTwmZpSeETcSRDV3T90ccSnm0mF
         j+wqkAVQh/BuznmcxjNDF2Ax5SNxY/5sXzEoWjCg0GoVB4txl/Xpnet5rX7H+rCzbb4y
         aIlg==
X-Google-Smtp-Source: APXvYqzDCJLSOt3Xcw9H6eTxGEbr9cfIpCmRnBVPNbrAC0K1NdNy1iodvCpMQZq0NRV5Hk0GqIh28j7YOAwbZBG+Gzc=
X-Received: by 2002:a0d:c345:: with SMTP id f66mr22624175ywd.10.1560957545673;
 Wed, 19 Jun 2019 08:19:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190619144610.12520-1-longman@redhat.com>
In-Reply-To: <20190619144610.12520-1-longman@redhat.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 19 Jun 2019 08:18:54 -0700
Message-ID: <CALvZod5yHbtYe2x3TGQKGtxjvTDpAGjvSc8Pvphbn00pdRfs2g@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: Add a memcg_slabinfo debugfs file
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 7:46 AM Waiman Long <longman@redhat.com> wrote:
>
> There are concerns about memory leaks from extensive use of memory
> cgroups as each memory cgroup creates its own set of kmem caches. There
> is a possiblity that the memcg kmem caches may remain even after the
> memory cgroup removal. Therefore, it will be useful to show how many
> memcg caches are present for each of the kmem caches.
>
> This patch introduces a new <debugfs>/memcg_slabinfo file which is
> somewhat similar to /proc/slabinfo in format, but lists only slabs that
> are in memcg kmem caches. Information available in /proc/slabinfo are
> not repeated in memcg_slabinfo.
>

At Google, we have an interface /proc/slabinfo_full which shows each
kmem cache (root and memcg) on a separate line i.e. no accumulation.
This interface has helped us a lot for debugging zombies and memory
leaks. The name of the memcg kmem caches include the memcg name, css
id and "dead" for offlined memcgs. I think these extra information is
much more useful for debugging. What do you think?

Shakeel

