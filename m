Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A76E8C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:04:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3975D205ED
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:04:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="t5CyOJNf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3975D205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98F5F6B0003; Wed, 19 Jun 2019 19:04:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93F1D8E0002; Wed, 19 Jun 2019 19:04:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82D898E0001; Wed, 19 Jun 2019 19:04:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6781B6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:04:41 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id c3so1023837ybo.9
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:04:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NbzMOyrZckNlP/Lcg+Lm/vM3zrC2t8DPpb83xlh9FiI=;
        b=boUdE2L7akKcRzY/lTs14BgwnOB+K8mc8jIm+KMnehZ1XyxQ/98TicuGB8yCDEItjB
         BerYeUjlYfQBAZCtzdM8jDdiRg2yqGmw9VenUw1KNGjq48mn22wPOMq/W/yjfE9+SuKX
         lnbNGqGJ15p+A2a5s7fY0C0R1qhNabhxOTzHqnC7G6ULOwUcK/2bV7GoUD829gsWTdVr
         Yo6QdKbFOyrTyJxT82nXTLjL01a3718D7MstQslDsG+T9kSurwO5aW2RTI1OPkOkKJRY
         XT35emJshg238G3Lrjnna0KwPaDRE06xEH+ngi7UMcdKrz9Nsl0QxJFOG3ubJZMfnwDl
         5T6w==
X-Gm-Message-State: APjAAAXj06rkwK09+Q6ZUC45FwryS9iycGB7wDrhuh38CfQw+r1yKAlt
	8seWDL4z32wpXJN6ehxCMyxFNfL33l4kDb9Dp+y3q8pbPJPiRV4a2PrudiePhzMK+K5rnlnIprU
	9OAj9zUlUHktdf2JbIuQyzj+curNT6VuXy5hLGPUBW+VokhH5lFEdImgfp+xg6hiZ6g==
X-Received: by 2002:a81:2905:: with SMTP id p5mr54678319ywp.357.1560985481130;
        Wed, 19 Jun 2019 16:04:41 -0700 (PDT)
X-Received: by 2002:a81:2905:: with SMTP id p5mr54678277ywp.357.1560985480542;
        Wed, 19 Jun 2019 16:04:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560985480; cv=none;
        d=google.com; s=arc-20160816;
        b=JW/oogLRunpkfHI/PVxWKiIK9L12Vqv1gAf5pNnc6Eg/CpGnSDNEwz1dJFrNX6IIVZ
         lT3KbKdAcyGvF36ZPflgyepyivenHWNw3cpPtilMW1rTmvqNVfC2x7zzzI14Wgmd3w6S
         8XFfg6e5Y6SLJ14tSSSQ9mqPodIs50tCoxNMAkj1QISMCSV9VwGurMJQN71KcMo6V3rl
         buJuHqN88AEL/038Cxgi6DGfsGYUbvBUpv/iT9MDwiSoFLbAmum33O2qlEP0gOAXaFXA
         fjRi/KgLJC3zM5zYaJ1z/JJ+n7OSXmY9Vt1Gp+7JCCSXNEivUoMKdEgTSH10/4Pxn3GD
         W5xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NbzMOyrZckNlP/Lcg+Lm/vM3zrC2t8DPpb83xlh9FiI=;
        b=urcVRD1sFDdHCx3gMT0HADbryMNJHgH3M54Ki2kSwC7oQetYjWIdjooPcmsmgrfYgs
         UIwcREW95HrUN4+qrgdDgUfh5FN/jPJeVt6XTi2DllWdD5FCLp9s2sQdNIO3hHsk4tht
         uZ3j5aJIwwoL/+uZxusHYgWmvRAuyXwIyImdjqz6wVnvyrrIUtO39SIZ67VvMWTDMwDM
         QsChPBQR6k0d9wKtARdALAscVCCUXhO4zaa+n6r0HrLHlPxfCrol5/TK7zhitKPIuCHr
         iKeTZsojX/ro9X9VzD4W4wjPaAfLoIJFEF+38edvQnyXioSaX56NrpvwP5/UNeavLJ09
         mHbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t5CyOJNf;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p124sor10092011ywp.103.2019.06.19.16.04.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 16:04:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t5CyOJNf;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NbzMOyrZckNlP/Lcg+Lm/vM3zrC2t8DPpb83xlh9FiI=;
        b=t5CyOJNfaac+Q7sPzpACyPTDx6EHsMBAXAnNFHc1O5tDZWecDaCzf1vYTuyz7Zjf/e
         67AVLo3wFwFhYh4mwpzgD+9UNuTSphgseGd0AVOtn7iOtYOElLcQ3s+WX4gwDSQUJSAG
         kHzUBPWbM3Dmo4KyNNeKLuRTTau5zxBm1pYUE8IUgg96i3/B0ojjp1aZCvK8b5YvIrRq
         3y/D3kCzgimUMVAjolJtiirGA8S5lSRCCmJdB1ggTynoPqquMl1gDOrFf2Hao69SK3nD
         qqRIODa4r7NbdVpNTrP+mSFxZxA2I3Lap/PkRe7pPMQAA9C50Yxp8L3JthprklpEeTg/
         Qmtw==
X-Google-Smtp-Source: APXvYqwwLc9GbuN1yski600QDsOdlXMt97I/+eg7SO2Z7GQo/t8DI3dWtHIREvPeuOmKIK1eoWONOQDWPdZIfMaHZBs=
X-Received: by 2002:a81:a55:: with SMTP id 82mr37722007ywk.205.1560985479831;
 Wed, 19 Jun 2019 16:04:39 -0700 (PDT)
MIME-Version: 1.0
References: <e5cfe17c-a59f-b1d1-19ce-590245106068@intel.com>
In-Reply-To: <e5cfe17c-a59f-b1d1-19ce-590245106068@intel.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 19 Jun 2019 16:04:28 -0700
Message-ID: <CALvZod6Bfbi57mRmbYetO+R=gB07kkewo=F9sTyMdWpDXGgwDg@mail.gmail.com>
Subject: Re: memcg/kmem panics
To: Dave Hansen <dave.hansen@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	"Williams, Dan J" <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 3:50 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> I have a bit of a grievance to file.  :)
>
> I'm seeing "Cannot create slab..." panic()s coming from
> kmem_cache_open() when trying to create memory cgroups on a Fedora
> system running 5.2-rc's.  The panic()s happen when failing to create
> memcg-specific slabs because the memcg code passes through the
> root_cache->flags, which can include SLAB_PANIC.
>
> I haven't tracked down the root cause yet, or where this behavior
> started.  But, the end-user experience is that systemd tries to create a
> cgroup and ends up with a kernel panic.  That's rather sad, especially
> for the poor sod that's trying to debug it.
>
> Should memcg_create_kmem_cache() be, perhaps filtering out SLAB_PANIC
> from root_cache->flags, for instance?  That might make the system a bit
> less likely to turn into a doorstop if and when something goes mildly
> wrong.  I've hacked out the panic()s and the system actually seems to
> boot OK.

You must be using CONFIG_SLUB and I see that in kmem_cache_open() in
SLUB doing a SLAB_PANIC check. I think we should remove that
altogether from SLUB as SLAB does not do this and failure in memcg
kmem cache creation can and should be handled gracefully. I can send a
patch to remove that check.

Shakeel

