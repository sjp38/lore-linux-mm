Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A5AC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 01:25:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9C5220B1F
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 01:25:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cj5+AGFc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9C5220B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB2106B0003; Wed, 22 May 2019 21:25:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A62BD6B0006; Wed, 22 May 2019 21:25:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94FF46B0007; Wed, 22 May 2019 21:25:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71E916B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 21:25:04 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id k8so3907633itd.4
        for <linux-mm@kvack.org>; Wed, 22 May 2019 18:25:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DwrwlKuIdoVYrJdyb0eyY3233BEFJTf1xEwDvRn1qmE=;
        b=kjQRTXGHTfUlYd3Nm3GuU6rHmWGK3Jaw3hNLrlHVBnnI52JE5ZPIIvFHXymG1hLYtA
         b5HZ/9qySg3mKhYdQsej1F7iClMnlaT7pFOQQ2VgCoHhjvuwgbcZEhkliYTBKRmRITn1
         jd/A50VUGwCB4g6UX7EqwODmehq12p5dCbBwmCVsrb0cK056gUpfyi5f91bfzBKAmH4A
         sY69Kc82fQwly5LERVf8ErZ6lWlEb4+THle84ASO2nKViBiDPRE1qYjH0x6l754oe5B/
         s1pFc0iDLeyb5Hr5ARz3ReLaJ3wgngJXxA1cMQ226cjsOZZkUZzaNXjv23rQWTfdERvd
         O5NA==
X-Gm-Message-State: APjAAAVa1T+6qoAhXES6IUO5afhJ6MaxIo1sVeM1drD5kZiB8Fz9zXWM
	AVGYRgboK80hma4+pV3j2BK3pGLfKN9JyYZM3xOwY5D/32prFQBO2nu2k2tMomxHfj8qhxjSjoh
	ia2AEKSHYlWuqqWhRTjWNVtmVE10/UKu6tLtMr0s0JxsLhzNONvXqwu7TIegAbYcSfQ==
X-Received: by 2002:a05:660c:492:: with SMTP id a18mr10962445itk.48.1558574704206;
        Wed, 22 May 2019 18:25:04 -0700 (PDT)
X-Received: by 2002:a05:660c:492:: with SMTP id a18mr10962401itk.48.1558574703429;
        Wed, 22 May 2019 18:25:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558574703; cv=none;
        d=google.com; s=arc-20160816;
        b=mzxmk9AzVdDQ4IuRQcuMHxYHzna5TgVJhMoobzhIXjBQSwXtyprue2Pj0ZuvOpuUKh
         wdiF0Zen/XbaEXk2Fu7pRjsoVCel53BMU2Fvsgww6c68tByTBcKkabGphMG3Eel1NxMq
         fylX5QOtpkVqwRES+HurgU/w0FhXMD/PSiRUiYd+9ecW9knvHYLe7veBMs04Z1YAof8W
         RIkA5fdARWdoKTZyDdpXqijSkavCa6Msulw73hACM2MwqKNyoZ6IF8DvYuatBNJrH565
         EU9Ut3CvP2mMKnAoqRU2gqEM/VXvGCcCpN31gul+FMO4MxKEAynCtcZc62p2ywpppl/a
         CBEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DwrwlKuIdoVYrJdyb0eyY3233BEFJTf1xEwDvRn1qmE=;
        b=iOQ6bxeRM7Uh2ibJJuJEiYFRA+/Y5r9pN4a0/8XMwkF0aybrNslPKBiUy/QaaTxQHh
         XliAsbd+odZQMnRq1L7iD5bK0q7y1A6SZCszmrKFdSNV+a8PAL76oFp8IWfRwbqTGypx
         MF/a0XCfEWaiKaQj7RCI8p6hd87pdmkoTrXa404+Oi05u05y7M8oYVuh/RmbpVc9ZMGR
         oYalXXFj/Ti5hamVSHrsEjQ2QKln3Y/IRXUB64REfI1dr5sUU3BE8i4LbIm7L1cvVA+v
         ZfBPp53dqVJQTfl1Rx6/2XJfsfTHNH/2IArSh00sLPAbmJgmd+t2N4XvmVbObO7bNC16
         u8EA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cj5+AGFc;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h1sor10443409ior.20.2019.05.22.18.25.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 18:25:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cj5+AGFc;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DwrwlKuIdoVYrJdyb0eyY3233BEFJTf1xEwDvRn1qmE=;
        b=cj5+AGFcIJ6mMVhY0Grxcklza0OvOObx9vT0xDujcgfRz774kcxwmlGOk6zNARoWxi
         A+PveCNSxbLF3BodTEUNUcGiKkqQoukA983GWFtTgtufkHdiUhiYANsAon4WWmi/dlC2
         iQ2rDNPsdNbVUBfmzws6xTkyZ0aLHV/LfOVtGk6obeYJns7fQ6CjAHpRLirXekyWsDHD
         TvQGd4oNOztziWnMPEbE24edV+MssyM8rxz+RhtRWYkDcNMp6rFtnO5uHZLDruNI41by
         hJo6PNJPtB9KAekGNoOTmE89PbjP9tIbw/ylrYT2X8bLdY0G1JnXQAF7MS9pUsl/YAqJ
         jZ0Q==
X-Google-Smtp-Source: APXvYqxErFwLeE1PTEpKDqML7Cqul0fImhXrqEeKAf47KdF58aPbu2rSfqa9mY9LQ/9Gj6zfA5CZf1sX6MEePssFroI=
X-Received: by 2002:a05:6602:2049:: with SMTP id z9mr26907713iod.46.1558574703020;
 Wed, 22 May 2019 18:25:03 -0700 (PDT)
MIME-Version: 1.0
References: <1557649528-11676-1-git-send-email-laoar.shao@gmail.com> <20190522123314.e17fc708ff6548b9b621d6ad@linux-foundation.org>
In-Reply-To: <20190522123314.e17fc708ff6548b9b621d6ad@linux-foundation.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 23 May 2019 09:24:26 +0800
Message-ID: <CALOAHbBYj-Y5fLEDusHO2DM4ni4CskeS9Qw=e=RqY1dLj-C=2w@mail.gmail.com>
Subject: Re: [PATCH v2] mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Dolgov <9erthalion6@gmail.com>, Michal Hocko <mhocko@suse.com>, shaoyafang@didiglobal.com, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 3:33 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Sun, 12 May 2019 16:25:28 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
>
> > We can use the exposed cgroup_ino to trace specified cgroup.
> >
> > For example,
> > step 1, get the inode of the specified cgroup
> >       $ ls -di /tmp/cgroupv2/foo
> > step 2, set this inode into tracepoint filter to trace this cgroup only
> >       (assume the inode is 11)
> >       $ cd /sys/kernel/debug/tracing/events/vmscan/
> >       $ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_begin/filter
> >       $ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_end/filter
>
> Seems straightforward enough.
>
> But please explain the value of such a change.  What is wrong with the
> current situation and how does this change improve things?  A simple
> use-case scenario would be good.
>
> I can guess why it is beneficial, but I'd rather not guess!
>

Got it.
The reason I made this change is to trace a specific container.

Sometimes there're lots of containers on one host.
Some of them are not important at all, so we don't care whether them
are under memory pressure.
While some of them are important, so we want't to know if these
containers are doing memcg reclaim and
how long this relaim takes.

Without this change, we don't know the memcg reclaim happend in which
container.

Thanks
Yafang

