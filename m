Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC66EC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:44:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 771902083B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 14:44:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="thXTMTeT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 771902083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EB5C8E0002; Thu, 20 Jun 2019 10:44:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19C9C8E0001; Thu, 20 Jun 2019 10:44:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 065218E0002; Thu, 20 Jun 2019 10:44:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAA838E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:44:39 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v15so2813025ybe.13
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 07:44:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hkFAHTitPkfoSMrSNRMsrnAtfZq9o+iv5woQgM2GCxU=;
        b=n3adRIkqa3gXZ71lUv05dNxwgCAUa8xVJWqDxc3URFB/IXu0YdFzg3lsBq+t+8TYKz
         7akhYhwaBl35dDWY981dfgM+ccAIt9mj28bPzCXp4o6g13Ttz2UfuFqd0zrp/3I/AGMf
         NqxsvcJTtg3UCK7WoIG2XLPWNzMju33awTEmgFn9m5ai0ylqWosdhfa4NjCv6rmYVN/I
         NBykvyc4+oGYQ0F2fac7v12oro2HbiRS0jA+t+ju1ts5wr/nu6r7vDRxvYToQ2BEBWWe
         SopK9ZbBy1qpZ3lwkp/bHOko831k3LlRTmdT25iPyyS3KnIGSqjr3/HeCXlqDCNMIudd
         VqRA==
X-Gm-Message-State: APjAAAXAczpCAje2eOA+b4ZidumtvZTLgGnSyObnppDBHx7Po2PlzUip
	Ka5Bxj3yMCPelJ3T9uSILrmGONQUm3FwtGBME6gUoAIMmhv8b9uAIGfK/pGvwSLhxKvERkA5Pkf
	YjUCdr00qu9vm0SrWM6YPQ0h40zYCEaUPaVZ2oplsqjrEgI4yoRka+CaGYE98eKFF/Q==
X-Received: by 2002:a25:e704:: with SMTP id e4mr52772478ybh.87.1561041879673;
        Thu, 20 Jun 2019 07:44:39 -0700 (PDT)
X-Received: by 2002:a25:e704:: with SMTP id e4mr52772456ybh.87.1561041879116;
        Thu, 20 Jun 2019 07:44:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561041879; cv=none;
        d=google.com; s=arc-20160816;
        b=SUp8CBzj+HnFNSwjTZsLo9KNHHcVUUuqE6m2hPzPs4S/a6cmK4lMhdbYW0Lj9fZN+w
         fkMPRG4Phr8oPhCilBl1gJ7VTlSswufOAVT8btjSDr+9SBxKSUbnbAPgsxyjm8CUhLlY
         69lpNy/nknZxrcUZ0oq/OAVq4uynenbW26MWGphjV2Bq9oLwU+rkOu9CDu8Iu2/oMlHv
         /mFFBnQ2aQ71987kQfzpNjQIRULkv1D/diJA/Si7GMC//SvK6raMlxKTkLwIYXPdP/pr
         9NEik9UAz1B42GL97iLsqlwCh9e6cI7gQep5ZAWSn05NNpME49kdudqd68KsADK6Pi/n
         mLLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hkFAHTitPkfoSMrSNRMsrnAtfZq9o+iv5woQgM2GCxU=;
        b=pP6Eqv0ffEezwiTd8/ofObQMzY/N/1sj34H0iZ8yB2viEvU/mUqwimiqFTsoGqZoUJ
         DX3nY6fTF3zZxt1L/Z0cYaxakqfiCB8Sh5ZfDrKBDC3xqu947FEWLw+XUO9BfG9RUWZ7
         1fH/xYrzG3vXxGh8SupCzjxykhXsQ/Ouh2iOgwyg9XRK5aqWKIbg0LDxvAgaWPJsJbM1
         TnXD5frCtHHno/WHCezVHnOGlJDJsrVOHETTUcGlACW0Iac0u33TVdRkv0cqyc6sj2Fz
         XddksaK9ERTyCyx9/LDBvw+Be07mKYda1w6LHsKftwy1xcE+knCL2uJvAWge9n+DORkg
         zoSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=thXTMTeT;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o194sor11500287ywo.122.2019.06.20.07.44.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 07:44:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=thXTMTeT;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hkFAHTitPkfoSMrSNRMsrnAtfZq9o+iv5woQgM2GCxU=;
        b=thXTMTeTx0xXiZ9u/a78f4w6z2h57qLbhWVkhGpc5uU4+H4pPEGPk9N0YCZIJUb/U4
         TnuCUQ66JQqC0RvWoZCgR5L5jwqo76zVzKpMp8pXzP0t0CQ13sojAuWtJV7WnzKSCT2L
         TWtmySeyPfLwUziR7l0nrBHtk8fljJ+2ySjxfL+NG8AENzVWfMDj+iozng9mw4Awlsxa
         skqETBHwe+amhnj7vzDXN7JX46bW7xj9yy4+eq7BrRCQxowABoE0AiBdKbjHH05Jx41W
         5BmmPDMNbpX33eiLB6cDqnj9kFawoUkLCrF0p8UIYzkm0l8IfyFnL90oSO42R54TvW4k
         dHxA==
X-Google-Smtp-Source: APXvYqx6zBr4fQkuPVHdnX/C78xgvMrTTDAZuq5i6MOjKE9DTzL7jnNL4Y6jb/qP1KrId0xDX5nVw5xKzMf3llYMevw=
X-Received: by 2002:a81:ae0e:: with SMTP id m14mr55624057ywh.308.1561041878378;
 Thu, 20 Jun 2019 07:44:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190619232514.58994-1-shakeelb@google.com> <20190620055028.GA12083@dhcp22.suse.cz>
In-Reply-To: <20190620055028.GA12083@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 20 Jun 2019 07:44:27 -0700
Message-ID: <CALvZod4Fd5X91CzDLaVAvspQL-zoD7+9OGTiOro-hiMda=DqBA@mail.gmail.com>
Subject: Re: [PATCH] slub: Don't panic for memcg kmem cache creation failure
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 10:50 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 19-06-19 16:25:14, Shakeel Butt wrote:
> > Currently for CONFIG_SLUB, if a memcg kmem cache creation is failed and
> > the corresponding root kmem cache has SLAB_PANIC flag, the kernel will
> > be crashed. This is unnecessary as the kernel can handle the creation
> > failures of memcg kmem caches.
>
> AFAICS it will handle those by simply not accounting those objects
> right?
>

The memcg kmem cache creation is async. The allocation has already
been decided not to be accounted on creation trigger. If memcg kmem
cache creation is failed, it will fail silently and the next
allocation will trigger the creation process again.

> > Additionally CONFIG_SLAB does not
> > implement this behavior. So, to keep the behavior consistent between
> > SLAB and SLUB, removing the panic for memcg kmem cache creation
> > failures. The root kmem cache creation failure for SLAB_PANIC correctly
> > panics for both SLAB and SLUB.
>
> I do agree that panicing is really dubious especially because it opens
> doors to shut the system down from a restricted environment. So the
> patch makes sesne to me.
>
> I am wondering whether SLAB_PANIC makes sense in general though. Why is
> it any different from any other essential early allocations? We tend to
> not care about allocation failures for those on bases that the system
> must be in a broken state to fail that early already. Do you think it is
> time to remove SLAB_PANIC altogether?
>

That would need some investigation into the history of SLAB_PANIC. I
will look into it.

> > Reported-by: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

