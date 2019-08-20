Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA0B4C3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:48:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DB7F2054F
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:48:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="K+mam5zv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DB7F2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 043DB6B0005; Tue, 20 Aug 2019 12:48:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F354A6B0006; Tue, 20 Aug 2019 12:48:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4A646B0007; Tue, 20 Aug 2019 12:48:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id BDB0A6B0005
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 12:48:53 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6BB08181AC9B4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:48:53 +0000 (UTC)
X-FDA: 75843390546.05.shape63_6aa324c586041
X-HE-Tag: shape63_6aa324c586041
X-Filterd-Recvd-Size: 4009
Received: from mail-yb1-f194.google.com (mail-yb1-f194.google.com [209.85.219.194])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:48:52 +0000 (UTC)
Received: by mail-yb1-f194.google.com with SMTP id m9so2299816ybm.3
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:48:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HfS/3YweTIcGGO2RRMlCPJRIxqMja+WwkZZpwCr9I0U=;
        b=K+mam5zvf/E3cU2LIDxXZWug/rqk3N2IZZ43MXOq44SNotDZn+byvLHrUFInHkDO7K
         krZMi68j2Wv9KleBJmISlXyAtf+AWs9TyWORM/Is9r/JWDOIisvRoaxJKLMa9X2+DkSD
         X8/9HsIrCN6cY1UKIUVTesBhBp4i3524bVcclEQ++s0bi/yh5/iX8yzTgk/KVOUmV0on
         7IlLZhBsYqtAIBE6vQRbijMnbR9VYedqBUFYnNM8Rbdx/bhjrOR+OtiJMEX84yYFHCtT
         KdyACLP9WpPoCaDmJFCRZjVP1xzZkn+G18umMyHY3eO4qR19pRTmM/TC8TB1C0CiILyZ
         TXzg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=HfS/3YweTIcGGO2RRMlCPJRIxqMja+WwkZZpwCr9I0U=;
        b=dlA7SM470TNSpY7NVI5PxCsrM+robCC8f0K/FPWAzNe8XD/lRVe1ChDo5WwCRG8ZxT
         Xlh9rBEll09y2Ip/CkGzNvNsWFj/Gpp0FFCE71N+hWwmnvNgrT74LozawTdJXb1heydl
         IcORt9rIZHJDI1EK/HVTe7sABLIsxoA7vcxdQ3BJsxNs3zj8+HhSzDN7DlA51S7kxzmD
         i2RFWfk9728Yxh5HApJISMghKaLzcUUXInXCY3B8SC7zraAL3uXHS3JPq5sBp04lh9c2
         XLg9OlVCsnjxc51AcZOhWTrnxRcZkfq8tGpYbPHPVeWEYuO94WJJv9vvtpcF0eSj1xdM
         lS6w==
X-Gm-Message-State: APjAAAVnWvNmAwAPmJnSxT6ML/+HRsnj2CqvBRJLjx3YzqGJCs2RgzJD
	Qv0WwIjZ1zuVk4fZmE72gRHrHl6gDom2lGuETcijUA==
X-Google-Smtp-Source: APXvYqxnanSSbRg2czlqAz97bkbZhcKO5rytay9XH6axiOD/F2S2TPwc7saIWI++F16Xc8DLHrIgnPN0HuxOeH9Q56U=
X-Received: by 2002:a25:f503:: with SMTP id a3mr21166644ybe.358.1566319731656;
 Tue, 20 Aug 2019 09:48:51 -0700 (PDT)
MIME-Version: 1.0
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com> <20190820104532.GP3111@dhcp22.suse.cz>
In-Reply-To: <20190820104532.GP3111@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 20 Aug 2019 09:48:40 -0700
Message-ID: <CALvZod7-dL90jwd2pywpaD8NfUByVU9Y809+RfvJABGdRASYUg@mail.gmail.com>
Subject: Re: [PATCH 00/14] per memcg lru_lock
To: Michal Hocko <mhocko@kernel.org>
Cc: Alex Shi <alex.shi@linux.alibaba.com>, Cgroups <cgroups@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, 
	Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 3:45 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 20-08-19 17:48:23, Alex Shi wrote:
> > This patchset move lru_lock into lruvec, give a lru_lock for each of
> > lruvec, thus bring a lru_lock for each of memcg.
> >
> > Per memcg lru_lock would ease the lru_lock contention a lot in
> > this patch series.
> >
> > In some data center, containers are used widely to deploy different kind
> > of services, then multiple memcgs share per node pgdat->lru_lock which
> > cause heavy lock contentions when doing lru operation.
>
> Having some real world workloads numbers would be more than useful
> for a non trivial change like this. I believe googlers have tried
> something like this in the past but then didn't have really a good
> example of workloads that benefit. I might misremember though. Cc Hugh.
>

We, at Google, have been using per-memcg lru locks for more than 7
years. Per-memcg lru locks are really beneficial for providing
performance isolation if there are multiple distinct jobs/memcgs
running on large machines. We are planning to upstream our internal
implementation. I will let Hugh comment on that.

thanks,
Shakeel

