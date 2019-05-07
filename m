Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85429C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 15:00:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A25020578
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 15:00:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nkZAd+pV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A25020578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 995166B0005; Tue,  7 May 2019 11:00:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 946626B0006; Tue,  7 May 2019 11:00:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85BA16B0007; Tue,  7 May 2019 11:00:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6682C6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 11:00:47 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id l6so5400059ioc.15
        for <linux-mm@kvack.org>; Tue, 07 May 2019 08:00:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AUBXah1K1wqCe2pcopHQTaPDxfCaD4ckuPch4S/5izY=;
        b=c9JTZ2UC83BGYaoFjw3dgPsfzhwEG41gU3qr7XNOJUbzJ1P5e0EQ0BTFee+b7Fhgp2
         TO5YX4dmF1mPQliuVAe84Kp+0O5Sqnst27OYL1/iFb11X2t36P/d0Iz8EIp3uKrHerkA
         kCHi63Wwp4KHXFPsGdi9xaZXUS2skubW5hD1d5FUKUEkpRMBjEJFIz3wQNT0I8OlPKzn
         CkQhhE6mJqr8nGkgD5zxvFZ3T0e2C5gtZPJNYtugyOiD1te9vFqWb+lgd+YjayAX9THX
         uOXZ87Dl4TlWB4URmCepV2kzV4VJSc3ZFIWi/Rf9dgnBm1M5HxZ/qClJB8m+KXG9Eoii
         NPWw==
X-Gm-Message-State: APjAAAVt4e789PQ9TQLbDwGB58VmsIEoCTkpX0WJIPnrjiDm0mvVpyJK
	OBE2ZOE8X3uSeY/nEt8oWYVh780AVVmmJ9L3KlrkT8KZcrz6Afh3FXnzv4nT2n/oJ5xFmiyVei7
	FDwPCBBzpyarPZcm8vV+fQYkXZucvKfWbLpnFZn1bJUI/oOJMQ0oMB+AeUOEqiZA+FA==
X-Received: by 2002:a24:398d:: with SMTP id l135mr15222715ita.79.1557241247110;
        Tue, 07 May 2019 08:00:47 -0700 (PDT)
X-Received: by 2002:a24:398d:: with SMTP id l135mr15222631ita.79.1557241246121;
        Tue, 07 May 2019 08:00:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557241246; cv=none;
        d=google.com; s=arc-20160816;
        b=08N5An60sDir/QyC+II0WfBGLTJwuyy8Ndb2VM8A/H708cPnW0rWVqZmuDsL5w49Nv
         +v84va7tv6TGvK2QLVZb6MuoeGQLkAAw+po2y6s4SjNrmI8LS4aKm6HYN4pbOjZnYRQH
         j3btlURkeMYV9OUQ5vmyQzejGOJ26hTDPQhbZJqM0RVVV/Oc5vCL2aVllv8gGGmmpmM2
         wsPV6VKxc1BJi3jgHfLI9txiijguCtxwov4olAd7apqRIbsOTDm4gf2tNAotzx5fN1Lo
         uUAdBI51FqIslAzmQT+alP8vCeyqyHjRVNreXsEQ84qAPo4xf3PGoaHFzQPUsCZRGxNV
         SCPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AUBXah1K1wqCe2pcopHQTaPDxfCaD4ckuPch4S/5izY=;
        b=mmzGtXsD6uBvjx/4lNDpkdiTipx3mZdcoUpDAQDL/eMgyOgr6KbwzhqCEV81ITZ70T
         p/WJZZ6MCLpyhJI3oMTdV+wFJ8mEwr+8fgTmKehipQ7uMGqA83zPZld7BAViEyB/UBo5
         cQoWPMXKsVrZa9oMpYwkeIRaPK++H5sMgxNZYPfKC5QbwjmIwNwF1TE8hGyFA+l9Hqh3
         +sGFeTwo/AyD7HMw2ZMnpd3DhigOagibcClFZcFPde4Rh3X18jGi9PFKp1AgXJel1oVa
         zjQFf2ZeeB55JPApCWDv0AkvxxZc6Hv+rB4pZ5CKeOsFd006sEAy7L7c63Mn+LWAgh4f
         Z7gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nkZAd+pV;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u129sor17974396itb.3.2019.05.07.08.00.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 08:00:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nkZAd+pV;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AUBXah1K1wqCe2pcopHQTaPDxfCaD4ckuPch4S/5izY=;
        b=nkZAd+pVG87j5NEOaZljIZjiOYXG+mYSTnoQ2n4bY0Y5biB9Ydgyo1jwr0wZ6CsblX
         bQDVlSlgxO32gRnc/M35uxBQwuOF+o2Ir64zrmeeIc0yGD+J09eiQU1TyCvW1yGfZyUn
         0rGgRo0pYuL+JE3ptJkuD+tWB0+B1KGDCgdkyW86nYaDzt3PAdpx7Upubg0Nhmck/4w6
         62fudeP56JTf2eS9h8zpTeN10rTslXHZvIcCjYZyYpWZ78U/RlFGH+gU5+QcRdH1A9t3
         L7uL0JSKRGwq6BJujcPPtmDpaibB1648ACSDaypvN/x8DXsq6jvfuHpKqZhjXehl8CAU
         tbow==
X-Google-Smtp-Source: APXvYqz0HhIM6RNBE+TRQ41TCGSZSbxOh5+Wbu8anNVwU5DBWEFPTPFGgL0Hlh4rG2jNEIQljUoSr5BDj60TWijMZkA=
X-Received: by 2002:a24:7c9:: with SMTP id f192mr23678604itf.97.1557241245851;
 Tue, 07 May 2019 08:00:45 -0700 (PDT)
MIME-Version: 1.0
References: <1557038457-25924-1-git-send-email-laoar.shao@gmail.com>
 <20190506135954.GB31017@dhcp22.suse.cz> <CALOAHbAM26MTZ075OThmLtv+q_cCs_DDGVWW_GpycxWEDTydCA@mail.gmail.com>
 <20190506191956.GF31017@dhcp22.suse.cz> <20190507142148.GA55122@chrisdown.name>
In-Reply-To: <20190507142148.GA55122@chrisdown.name>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 7 May 2019 23:00:36 +0800
Message-ID: <CALOAHbDGbEKxGgTEr4wJRVCp_Tw7H0ziUTsALbniPp6u1Qx2jQ@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: avoid unnecessary PageTransHuge() when
 counting compound page
To: Chris Down <chris@chrisdown.name>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 10:21 PM Chris Down <chris@chrisdown.name> wrote:
>
> Michal Hocko writes:
> >On Mon 06-05-19 23:22:11, Yafang Shao wrote:
> >> It is a better code, I think.
> >> Regarding the performance, I don't think it is easy to measure.
> >
> >I am not convinced the patch is worth it. The code aesthetic is a matter
> >of taste. On the other hand, the change will be an additional step in
> >the git history so git blame take an additional step to get to the
> >original commit which is a bit annoying. Also every change, even a
> >trivially looking one, can cause surprising side effects. These are all
> >arguments make a change to the code.
> >
> >So unless the resulting code is really much more cleaner, easier to read
> >or maintain, or it is a part of a larger series that makes further steps
> >easier,then I would prefer not touching the code.
>
> Aside from what Michal already said, which I agree with, when skimming code
> reading PageTransHuge has much clearer intent to me than checking nr_pages. We
> already have a non-trivial number of checks which are unclear at first glance
> in the mm code and, while this isn't nearly as bad as some of those, and might
> not make the situation much worse, I also don't think changing to nr_pages
> checks makes the situation any better, either.

I agree with dropping this patch, but I don't agree with your opinion
that PageTransHuge() can make the code clear.

The motivation I send this patch is because 'compound' and
'PageTransHuge' confused me.
I prefer to remove the paratmeter 'compound' compeletely from some
functions(i.e. mem_cgroup_commit_charge,  mem_cgroup_migrate,
mem_cgroup_swapout,  mem_cgroup_move_account) in memcontrol.c
completely,
because whether this page is compound or not doesn't depends on the
callsite, but only depends on the page itself.
I mean we can use the page to judge whether the page is compound or not.
I didn't do that because I'm not sure whether it is worth.
The other reason comfused me is compound page may not be thp. Of
course it can only be thp in the current callsites.
Maybe 'thp' is better than 'compound'.

Thanks
Yafang

