Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15C13C5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C14D02083B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nifty.com header.i=@nifty.com header.b="raNNZCAO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C14D02083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=socionext.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 546AB6B0003; Thu,  4 Jul 2019 23:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F5AD8E0003; Thu,  4 Jul 2019 23:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BD948E0001; Thu,  4 Jul 2019 23:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03DE16B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 23:45:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k19so4796095pgl.0
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 20:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=gyzrOPyoHJn8yznucnkE9+HI+d/Euv7RRhUiRYloNpg=;
        b=SRa4oKc3jBXCmKkOl5xURDP0N8kpsc8PJl1J8hXZXXlykG8thsndDr/2jQNyRAqUC9
         AsKRQ0FoqNm7vTgUHibfLxXABYQ48RLfBbG+TbmY5Ct8AM1B9EFam1cBrNfFBH4KnSIy
         SkffTf3vFoa/6RcARoJHv71nmJQG1wLp5pBnW8eo+OYRXz+PUFu4Yj94bXTTImmbWT+A
         k8NeNwHDJ8RLjQJ8bd3SduuzZ3sv94Ajv0qn0d0hjtF+huzGpzMkQcfoZx9b7Walpsee
         +CLCBVx66ZfdANru2FTOYpf9F9z4QwDTBcNq+ME+pz1ixB02520nZ3s7nbBve1wLeSsw
         jUKQ==
X-Gm-Message-State: APjAAAX0rigCgjVp5Btz9JID1nq8KF/g5WqJ2AfP8SYTnZRH8Qv8HfY6
	MbCkoQz1JEzxJ5OpEurKYL9nSLEHutJSOHASjjrcfEzzo4Beq/k+NtSlBZQrWkh59/7e5iU8eql
	OObYR0eqgGW/hbZ4EIo5awKslTRp3uOIT++B3JukrdbfVejMoK9VFzshsbWuQB/o=
X-Received: by 2002:a63:e62:: with SMTP id 34mr113447pgo.331.1562298310460;
        Thu, 04 Jul 2019 20:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySq1LpOUpxoGPhd1Hu5mfDtyd58m9Igv4ahmk8X9Kijdnu19fKnLbGQmnbRzK9D7C1i4Ly
X-Received: by 2002:a63:e62:: with SMTP id 34mr113379pgo.331.1562298309629;
        Thu, 04 Jul 2019 20:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562298309; cv=none;
        d=google.com; s=arc-20160816;
        b=pyEldoxNvr6uYoXfgJRLI8DcolYzmbLDudrahQEvuFycmD7m8qsx9/m5IbDsbcQR/b
         SVbBBGyA0mYj6TXWUAsBOGt5dw+SGzLtHM9hk4wrdOYFTIPnoaokbaCCji4cYxftN1sK
         oLnjphmCwIymH4U1yq1NdsvPGI//xRy0vqcLw5+TJL6aseLMLsvGHingOb7CMbZiBD/b
         SqEvnm8cAC7WBcnCNsWZ45/poW+iXRE3jPfQc/nkpzhtPvMsivaM+kkAcQlzOv8oYTuV
         /Wv+J55sX8jd39Kl86xzNvFuz10ITeBR6PZLxB85llIUo6Sd9JZ7ZkbRjZVqRopPnRu7
         ZMPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature:dkim-filter;
        bh=gyzrOPyoHJn8yznucnkE9+HI+d/Euv7RRhUiRYloNpg=;
        b=PTIYw3WAPc+tZMTvSLjYbM61Rh099H2Yb+2E1hyPFfSftW2xXwSzLAEg+OOWpdLMHS
         2N7xUm8WI5uCIpyTILFMue/ECREQ1ui2F6FHssWsYegiMCMu0FPI2ht4lffgMmAnDKkb
         kh4nuja8QM2ITgkK9R5xlbYyKrjQORAZLI4F2LbX5nilhnqGrM1fY1fh5v2qkadkcSOA
         ZgPb4gxBRw8i9dW56AkFJv/SVAMwr7F9riLsnhtU5QjGwecg5uj6JbhfQCXJ2vTAYVZO
         t5gkUr+sFp9CGXznAvu03XCLo5Pp+3TruxMBqkAy8o/UGbC/A5xPFhVJ/WNOBiGOTuHu
         eZNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nifty.com header.s=dec2015msa header.b=raNNZCAO;
       spf=softfail (google.com: domain of transitioning yamada.masahiro@socionext.com does not designate 210.131.2.81 as permitted sender) smtp.mailfrom=yamada.masahiro@socionext.com
Received: from conssluserg-02.nifty.com (conssluserg-02.nifty.com. [210.131.2.81])
        by mx.google.com with ESMTPS id 5si7597818plx.200.2019.07.04.20.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 20:45:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning yamada.masahiro@socionext.com does not designate 210.131.2.81 as permitted sender) client-ip=210.131.2.81;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nifty.com header.s=dec2015msa header.b=raNNZCAO;
       spf=softfail (google.com: domain of transitioning yamada.masahiro@socionext.com does not designate 210.131.2.81 as permitted sender) smtp.mailfrom=yamada.masahiro@socionext.com
Received: from mail-vs1-f50.google.com (mail-vs1-f50.google.com [209.85.217.50]) (authenticated)
	by conssluserg-02.nifty.com with ESMTP id x653iqxK019522
	for <linux-mm@kvack.org>; Fri, 5 Jul 2019 12:44:53 +0900
DKIM-Filter: OpenDKIM Filter v2.10.3 conssluserg-02.nifty.com x653iqxK019522
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nifty.com;
	s=dec2015msa; t=1562298295;
	bh=gyzrOPyoHJn8yznucnkE9+HI+d/Euv7RRhUiRYloNpg=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=raNNZCAOKEPHYVaij4yEdaIPKfvnxsA4hdGo8Hv/tDo5sAMhN3jJg1vcGLVFG9JTO
	 L82ldU/CtNN81FFKJATdWEWwLXD9X9dT/W55cJJzb4hOlZdWIOYWD+Dz31Rc9Ho+L2
	 9d4lOBh29rcUHfGBSuhjrB3yJ2W8klxOCrUGuql9fHk3XFRg2YseiwYMWW418NdkV5
	 pb3b1IPwiFBgAWnYhc5fvJG9QtWqWovvnNdC5XhfgO/YZfedaZryTDOg+MKhUHbT1w
	 DTWRmEilTshfqDmGuvLBRNE4VcefzUbsRp6eREmJQjN9WrlJJlKkirp+/37mAvc2d/
	 hejICWC+a9ycA==
X-Nifty-SrcIP: [209.85.217.50]
Received: by mail-vs1-f50.google.com with SMTP id m23so3003712vso.1
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 20:44:53 -0700 (PDT)
X-Received: by 2002:a67:d46:: with SMTP id 67mr791736vsn.181.1562298292360;
 Thu, 04 Jul 2019 20:44:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
 <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org> <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
 <CAK7LNASLfyreDPvNuL1svvHPC0woKnXO_bsNku4DMK6UNn4oHw@mail.gmail.com> <5e5353e2-bfab-5360-26b2-bf8c72ac7e70@infradead.org>
In-Reply-To: <5e5353e2-bfab-5360-26b2-bf8c72ac7e70@infradead.org>
From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Fri, 5 Jul 2019 12:44:16 +0900
X-Gmail-Original-Message-ID: <CAK7LNATF+D5TgTZijG3EPBVON5NmN+JcwmCBvnvkMFyR+3wF2A@mail.gmail.com>
Message-ID: <CAK7LNATF+D5TgTZijG3EPBVON5NmN+JcwmCBvnvkMFyR+3wF2A@mail.gmail.com>
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Brown <broonie@kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-mm@kvack.org,
        Linux-Next Mailing List <linux-next@vger.kernel.org>, mhocko@suse.cz,
        mm-commits@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
        dri-devel <dri-devel@lists.freedesktop.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 5, 2019 at 12:23 PM Randy Dunlap <rdunlap@infradead.org> wrote:
>
> On 7/4/19 8:09 PM, Masahiro Yamada wrote:
> > On Fri, Jul 5, 2019 at 12:05 PM Masahiro Yamada
> > <yamada.masahiro@socionext.com> wrote:
> >>
> >> On Fri, Jul 5, 2019 at 10:09 AM Randy Dunlap <rdunlap@infradead.org> wrote:
> >>>
> >>> On 7/4/19 3:01 PM, akpm@linux-foundation.org wrote:
> >>>> The mm-of-the-moment snapshot 2019-07-04-15-01 has been uploaded to
> >>>>
> >>>>    http://www.ozlabs.org/~akpm/mmotm/
> >>>>
> >>>> mmotm-readme.txt says
> >>>>
> >>>> README for mm-of-the-moment:
> >>>>
> >>>> http://www.ozlabs.org/~akpm/mmotm/
> >>>
> >>> I get a lot of these but don't see/know what causes them:
> >>>
> >>> ../scripts/Makefile.build:42: ../drivers/gpu/drm/i915/oa/Makefile: No such file or directory
> >>> make[6]: *** No rule to make target '../drivers/gpu/drm/i915/oa/Makefile'.  Stop.
> >>> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915/oa' failed
> >>> make[5]: *** [drivers/gpu/drm/i915/oa] Error 2
> >>> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915' failed
> >>>
> >>
> >> I checked next-20190704 tag.
> >>
> >> I see the empty file
> >> drivers/gpu/drm/i915/oa/Makefile
> >>
> >> Did someone delete it?
> >>
> >
> >
> > I think "obj-y += oa/"
> > in drivers/gpu/drm/i915/Makefile
> > is redundant.
>
> Thanks.  It seems to be working after deleting that line.


Could you check whether or not
drivers/gpu/drm/i915/oa/Makefile exists in your source tree?

Your build log says it was missing.

But, commit 5ed7a0cf3394 ("drm/i915: Move OA files to separate folder")
added it.  (It is just an empty file)

I am just wondering why.


-- 
Best Regards
Masahiro Yamada

