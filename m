Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2F6FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:48:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82DB02054F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:48:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="deYxp5Ec"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82DB02054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1876C8E0003; Tue, 12 Mar 2019 12:48:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 136D08E0002; Tue, 12 Mar 2019 12:48:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 025FA8E0003; Tue, 12 Mar 2019 12:48:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D05A18E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:48:42 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v3so2283415iol.3
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:48:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Vn5wNO/WHCHX81GlqPviWQYIH5Lzg6cde82VdIWJCjc=;
        b=i9eIRXRtCaGf/XU5YpHsKCUQAx0tkfQyFkoXXyNZIOKd5d9ckCJ+LUkURxM6Skaz61
         O8KGDZj4hx5ENH5YD7+T9OB0CxFBQGWsqwIcJEyyFpBKANYpN7KD+oWghD+tFzhGZlqm
         ajgLlw5+L6wFDPZzIPAnNCR4b1dM2CgSkAc4BIlNwSXF5wbqPfL43b5ZancC4bisicOf
         HcY9rgBtdelrziWF8t82DfkF1Gr0tpXASY65+DTRKnYs/7g47UXNXNNc4aZBmV5bRwnu
         ZE34JoIppzmDkeU/KMG739G9J3Y4FdO9lGFJxA82vfxCBKlVnQF5SuxDuNVaBPJuqFVx
         5mFQ==
X-Gm-Message-State: APjAAAWGcmtmb1egtvFFlnTQCLE0ijuw0yMMM5SJClYCodYQ0EohBGDH
	L+aFxpkh2oMk8qRgj9iUP6SiRsAvUOshd+oSOJys2EebeGZdzYkywugSlOzTZ+zVXe5Qll7bGo8
	3CM5+WbH6rKaIKNlvhAin9rZ8TihoBFqomk5Yh0md8TymuBbc+E0cZYolLylUcA6Fcw==
X-Received: by 2002:a24:6006:: with SMTP id i6mr2680664itc.134.1552409322596;
        Tue, 12 Mar 2019 09:48:42 -0700 (PDT)
X-Received: by 2002:a24:6006:: with SMTP id i6mr2680634itc.134.1552409321760;
        Tue, 12 Mar 2019 09:48:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552409321; cv=none;
        d=google.com; s=arc-20160816;
        b=JYGN91XCdFFEhaqy1MJCjOMkSw+eqP/hTFgyHDF9LMoIcGyJVTo1tadT9IYgGEowVb
         leQDpjf5TkJwfpkkru3QMGfW4+gjXkvk8w5t2YJ7d9ELAWhx3NDt7kWXZkjhnCJ8tv0q
         +9ph/dS9MU1z2ZYmji5H8rSXqDIqpfFsWNiiCRcz3lgnPkDJ8ymdkoUcPOXIuIIlpkxA
         r5svClQlKD8G63ZgQPmyP5IeRv7It+pZ3juGbuqOCwSUUjpa4+ip46AT4k0+FlAeG03c
         7dY8XuG73ygY9k/x/ItNXpmo5IilzHy2lcIYigCE0FigKD2jvsn16u6Fd99bNqxs34o4
         SqSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Vn5wNO/WHCHX81GlqPviWQYIH5Lzg6cde82VdIWJCjc=;
        b=0e94ud3sc09ORRGMUceyU1M/pjmivv/26Mj7VLt7OFEcwmWowAUkyXYmVN8mxoS33U
         bYkBgazcwnLswqgWm9QGowD1M004u4V0U8i/ox32GUSdksVN3uMKVux2us4CpCOxNzim
         y78Bbg4MshZ0Pj4lRqsgXa8ys8UO8AeDzLwyWZ+zdFuKeYV/s0CIsUFIj7ek4mMYRpsR
         4cDzxKmFU/u87UpzETIEZ5em65Qu9tGfHEnlFK2Y9iv0WFl2IDxp/z1/Be9zZNcWsCm3
         zeED/IXVLYgeYKiYVINzkjuyJLgk8MXiCd+JMcsGpurnJuq9irACWdJwwVzcUsM1Q0Kb
         xciQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=deYxp5Ec;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b4sor4732977ios.13.2019.03.12.09.48.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 09:48:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=deYxp5Ec;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Vn5wNO/WHCHX81GlqPviWQYIH5Lzg6cde82VdIWJCjc=;
        b=deYxp5EciTonLP20GiipCn6zYpT6i3uEQqvqeLMYjvljhs47mCzzshPuTtD8RSDDVS
         Pe7MV5S+CwfbZM+r6pMsbsS0WOifN0FMUMGTwUc94CCm6FcnEtggJXVUycXIYHws+449
         0lVcQujc+6IwJAHtFZFxD59LGeagXWdVpo5bB/271Z1FWOXeG/9wiW1ZnwSetXGcDY0T
         xT+mfiJ0vREY5611ZF1EzHYIzkHlifo9JphZnFKlUar6xkC6EyYpqd3vVUtvUXM8L9wz
         8r+TZEsQxteBO/6pd2qFsxlhzPmfzAs/P6XOA+eK6KegArqBWnO7Gr/OnwZnQx3aPQpn
         VVBg==
X-Google-Smtp-Source: APXvYqxsDkikFxqx/sEbgrtm9RM2PjJGtNIcVX64HEMgN3lMFB5D3QiHEorrQdr1ygFj1VOyLjjpE07EQeirFNKKxKw=
X-Received: by 2002:a6b:e50d:: with SMTP id y13mr326423ioc.142.1552409321489;
 Tue, 12 Mar 2019 09:48:41 -0700 (PDT)
MIME-Version: 1.0
References: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com>
 <1551501538-4092-2-git-send-email-laoar.shao@gmail.com> <20190312161803.GC5721@dhcp22.suse.cz>
 <CALOAHbBR119mzbkkQ5fmGQ5Bqxu2O4EFgq89gVRXqXN+USzDEA@mail.gmail.com> <20190312164422.GD5721@dhcp22.suse.cz>
In-Reply-To: <20190312164422.GD5721@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 13 Mar 2019 00:48:05 +0800
Message-ID: <CALOAHbC5+YJR6BYLCz+-8xPhZPczqnaKv-rZ97tF+traPTut0A@mail.gmail.com>
Subject: Re: [PATCH] mm: compaction: some tracepoints should be defined only
 when CONFIG_COMPACTION is set
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 12:44 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 13-03-19 00:29:57, Yafang Shao wrote:
> > On Wed, Mar 13, 2019 at 12:18 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Sat 02-03-19 12:38:58, Yafang Shao wrote:
> > > > Only mm_compaction_isolate_{free, migrate}pages may be used when
> > > > CONFIG_COMPACTION is not set.
> > > > All others are used only when CONFIG_COMPACTION is set.
> > >
> > > Why is this an improvement?
> > >
> >
> > After this change, if CONFIG_COMPACTION is not set, the tracepoints
> > that only work when CONFIG_COMPACTION is set will not be exposed to
> > the usespace.
> > Without this change, they will always be expose in debugfs no matter
> > CONFIG_COMPACTION is set or not.
>
> And this is exactly something that the changelog should mention. I
> wasn't aware that we do export tracepoints even when they are not used
> by any code path. This whole macro based programming is just a black
> magic.
> --

Sure, I will modify the changelog and send v2.

Thanks
Yafang

