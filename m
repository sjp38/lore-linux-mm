Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC6F7C4649E
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 14:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FC0A216E3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 14:33:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qca823AY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FC0A216E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1F1C6B0003; Fri,  5 Jul 2019 10:33:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECDF98E0003; Fri,  5 Jul 2019 10:33:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBC658E0001; Fri,  5 Jul 2019 10:33:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD6926B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 10:33:41 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s9so6729869iob.11
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 07:33:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yxRgMFd8oh6cGshyzg2AnYic1FdOX2L1/QsFVRgaEEg=;
        b=H2ajs1f5TONV9QUmH463Cs0HSyUaUIIgl5/RKPaEB9d0CTV9DeJIoLxDz/IogQkJHk
         3iAoQbtTJ0DobO3BGLgqjTGUeWVjQUoQUsXbEPZ2TXC6UtLrllcfvEo5B+z1bl0R7wLi
         LSqjjSM44qfPryElxNcUPv3Kxl3LHImY2we4BoVk6CuOvZ9bo+gIO/ffJMoXY0ABJQOl
         Mz8x7JjA16k4OHzMfskJW+lKvJokIzyDShHVMj/iwYGi7OpDfa4FDX1NjD1OQ3+H42gf
         pvIkM+r2L61Bw3V4QrTC2wGZIe5OCAH1kFV5Z7TPgaSe9FeV/wBnDAkzmXmJl8Q0Z7gn
         wRng==
X-Gm-Message-State: APjAAAWvmJjSWvSumRtbBmLcg5GbU5WOyaJiVumsU9HSQp2gL+b1Pg3w
	X07fdg8Zb8LfK2Syvv9VtSHoPSElwmCberJV8okgnlxMk9t+MsaciV9tL+CC/QV7RrJT6SLgTFD
	2C1txQ6gMJpUqz4aKEHT3M4a0E1hrLb4uZjeGRI/d1mpIkWW+7VeZ0633+3l1mCCDpQ==
X-Received: by 2002:a02:ac03:: with SMTP id a3mr5130667jao.132.1562337221417;
        Fri, 05 Jul 2019 07:33:41 -0700 (PDT)
X-Received: by 2002:a02:ac03:: with SMTP id a3mr5130599jao.132.1562337220750;
        Fri, 05 Jul 2019 07:33:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562337220; cv=none;
        d=google.com; s=arc-20160816;
        b=qvtWqow4vef5AyKahkX6HwlCdb4MjVMzh10OHrzhkHtEKnkPEyh9f359OPhbHnl9V/
         NAXSNAmrgyQigFWZkCEb4LH0QgruOO1gJLR2wT4qPcEWhKComCGIWMKXDRFPxjygepca
         7+guaMq8VxRd3txe+gyRbdNxwK8A5FVqPhEAoByu3tQL9/8e8UQmJPCm/fJfYe+lrZlD
         yl0M/pSSNxd7rqHfpvsZSacjQcboYOjDsH9FRpdwraeH6iuUrvsd9o6MYOW6pMOymM+C
         Rhffs1i5HHNJldTxJD8u3gC/EXKLvrpEgcW2OC8KXWwKQdYcmxSH0PSDVw+85HER4/jF
         ncmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yxRgMFd8oh6cGshyzg2AnYic1FdOX2L1/QsFVRgaEEg=;
        b=rfuOtkXjs+gGXIWll4Xn6Y10T/IfATRS1amZTZ1LvJjDtOS39/69YbWWUfjgtCroHG
         A7bsE2jtaksljfCvMFoIiANah6dqM/bovABp618+Rtx8GEbNfjX9nvme1l8a58yw5zWy
         4/3lg/9LvNnPQZBsAfJUBuHdAJzGY0yTcI6XzT/el5pWlZMvC8gRv8bOwWrDWoFSxHXM
         VVQ/JVvONfDSZgjFzeKDClQy21CogvFTbJpajWwMKmoQgaKEXG83OzWo7PpBRtHciJTV
         L8FM6eQP8/WoXhsDw/V+uP1n3slWg4QJ1PH7HhsVeXjnhYwma/x9HbP1G/yE/VnuKFX2
         HXDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qca823AY;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3sor12735072jam.9.2019.07.05.07.33.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 07:33:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Qca823AY;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yxRgMFd8oh6cGshyzg2AnYic1FdOX2L1/QsFVRgaEEg=;
        b=Qca823AY+IO+GvGOaBEu+sJ1UqcFssFZLQaUZ7K72hHb/JA5T448mKEOVBmfXUno7i
         5kRlNoxlqvyjRyt2q2fytmU7K3CQw64J9IuNbtUneJmNRvE787g5yad0ab2UetN5eYcS
         bE9HZCrbZXLCCOyaBJt+hae7xYp1vHqMViy1pvex2FkaZ8aalSTPKadS7v9I0HDjZhT8
         zKIZO/dUkuK1bxUCPFqEOwALRaKWXNxhyazaZbFpC66NQOD+80XGPxuJpIYycdgxbngz
         rMQCAUFr6LIpsZ3GvPZqkDl2+61R/Dt3oRKojdo7+llRkmXrPRElqZEM4kEnt08xArIX
         AVBA==
X-Google-Smtp-Source: APXvYqwQJmrCjSGvFy8WpgAuRdZYKHVE5EdRGD2xVrYMUoeq05t3riKfGIDqNYdjNZ57W2yAoYeSEm2/uiuGTdiPzow=
X-Received: by 2002:a02:230a:: with SMTP id u10mr4993440jau.117.1562337220305;
 Fri, 05 Jul 2019 07:33:40 -0700 (PDT)
MIME-Version: 1.0
References: <1562310330-16074-1-git-send-email-laoar.shao@gmail.com>
 <20190705090902.GF8231@dhcp22.suse.cz> <CALOAHbAw5mmpYJb4KRahsjO-Jd0nx1CE+m0LOkciuL6eJtavzQ@mail.gmail.com>
 <20190705111043.GJ8231@dhcp22.suse.cz>
In-Reply-To: <20190705111043.GJ8231@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 5 Jul 2019 22:33:04 +0800
Message-ID: <CALOAHbA3PL6-sBqdy-sGKC8J9QGe_vn4-QU8J1HG-Pgn60WFJA@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: support memory.{min, low} protection in cgroup v1
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Shakeel Butt <shakeelb@google.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 5, 2019 at 7:10 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 05-07-19 17:41:44, Yafang Shao wrote:
> > On Fri, Jul 5, 2019 at 5:09 PM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > > Why cannot you move over to v2 and have to stick with v1?
> > Because the interfaces between cgroup v1 and cgroup v2 are changed too
> > much, which is unacceptable by our customer.
>
> Could you be more specific about obstacles with respect to interfaces
> please?
>

Lots of applications will be changed.
Kubernetes, Docker and some other applications which are using cgroup v1,
that will be a trouble, because they are not maintained by us.

> > It may take long time to use cgroup v2 in production envrioment, per
> > my understanding.
> > BTW, the filesystem on our servers is XFS, but the cgroup  v2
> > writeback throttle is not supported on XFS by now, that is beyond my
> > comprehension.
>
> Are you sure? I would be surprised if v1 throttling would work while v2
> wouldn't. As far as I remember it is v2 writeback throttling which
> actually works. The only throttling we have for v1 is reclaim based one
> which is a huge hammer.
> --

We did it in cgroup v1 in our kernel.
But the upstream still don't support it in cgroup v2.
So my real question is why upstream can't support such an import file system ?
Do you know which companies  besides facebook are using cgroup v2  in
their product enviroment?

Thanks
Yafang

