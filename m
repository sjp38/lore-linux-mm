Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1BBCC3A589
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 01:01:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52A4B22D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 01:01:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FFc/ZXxa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52A4B22D6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3CC36B0275; Tue, 20 Aug 2019 21:01:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEDF96B0276; Tue, 20 Aug 2019 21:01:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB5776B0277; Tue, 20 Aug 2019 21:01:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id 89C396B0275
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 21:01:16 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 33E4455FA5
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:01:16 +0000 (UTC)
X-FDA: 75844631352.03.patch32_28250489ac14c
X-HE-Tag: patch32_28250489ac14c
X-Filterd-Recvd-Size: 4692
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:01:15 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id p12so1230895iog.5
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 18:01:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nA9aEHMdZugi2Oyc8655NW5b4uoWYUceKwO95Xg/zK4=;
        b=FFc/ZXxasUfjEBKvwYHn60BKk3L9kr4Foty/5WmCm1kRGS98oJlVtJ4fH7ESAorx/F
         L5ZYdpbVtItG80WcUB2zGFcss+1boz++tBAG5XwTmfE0dxu3bsdGn4n5QJODcj4uxiMF
         XEgtXwpBU6owTiw+d/aTar4QGNdFqmlZG34duUjRULCUyy/rkNvwuwFKF2I8j1anWzgQ
         Jb2x/2sE4g0St4t616M7JYiRDJHZ5Dndt6A+MU8+OiinFj4XX4FZ7s48wI3U/ibKYajg
         uCmGtS04mdm+sUioUA+ONZiF15ozuYeBTPAYhgHYlUVMLRsL/UpP/qBzdjdSgxljyrdO
         7pUw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=nA9aEHMdZugi2Oyc8655NW5b4uoWYUceKwO95Xg/zK4=;
        b=f3ivocMMBFDrG6KnUq6iNLeLcZVTpp0no3WTPaLfJaJ8jGGa+/aoR9G3/fDM0++fbp
         8oBaE1Y6FofZO7dY/Y0x9i6tHnPpUZk4PekLleYiEka0vMiOdAgGTkmbvfPbwLpiGNHt
         piSwYV3HI++aimGEiS1RhsiO8xml/Zh0ZZ4Awvpn98SNrNE0qd8NSdXAz4lJBvFRUTT7
         iNHou5INbH4SFdUbZKo3d/m6Gj3sCTqrkPTjjeg89DptXMvwjztPTKko9JIEH6fbK9DQ
         nP/ZtM47B4NuFbvXMbavPPgY/dAV9311bdo51WHgUHX9+H7gfclvO5wBXghHfv0sZNZm
         1zIg==
X-Gm-Message-State: APjAAAWNg/bA9aTh1v3chV7pUx4CfFvZSv76vujaPnKVRBjvJQBbj1aL
	FNUf7r49G09X2HSiQ9G8MYLN3FJ6KXsqLgY0RE0=
X-Google-Smtp-Source: APXvYqxTPA/ZM4Ic07vOzcvMB7I4HFHWgmGtVye97uKh5MQ0QtyKjsKXkQGpWJoa4qcDzwYuCHTPPAsMQ1rIbDmgD5g=
X-Received: by 2002:a05:6638:a09:: with SMTP id 9mr7273951jan.95.1566349275060;
 Tue, 20 Aug 2019 18:01:15 -0700 (PDT)
MIME-Version: 1.0
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com> <20190820213905.GB12897@tower.DHCP.thefacebook.com>
In-Reply-To: <20190820213905.GB12897@tower.DHCP.thefacebook.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 21 Aug 2019 09:00:39 +0800
Message-ID: <CALOAHbBSUPkw-XZBGooGZ9o7HcD5fbavG0bPDFCnYAFqqX8MGA@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
To: Roman Gushchin <guro@fb.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	Randy Dunlap <rdunlap@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 5:39 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > In the current memory.min design, the system is going to do OOM instead
> > of reclaiming the reclaimable pages protected by memory.min if the
> > system is lack of free memory. While under this condition, the OOM
> > killer may kill the processes in the memcg protected by memory.min.
> > This behavior is very weird.
> > In order to make it more reasonable, I make some changes in the OOM
> > killer. In this patch, the OOM killer will do two-round scan. It will
> > skip the processes under memcg protection at the first scan, and if it
> > can't kill any processes it will rescan all the processes.
> >
> > Regarding the overhead this change may takes, I don't think it will be a
> > problem because this only happens under system  memory pressure and
> > the OOM killer can't find any proper victims which are not under memcg
> > protection.
>
> Also, after the second thought, what your patch really does,
> it basically guarantees that no processes out of memory cgroups
> with memory.min set will be ever killed (unless there are any other
> processes). In most cases (at least on our setups) it's basically
> makes such processes immune to the OOM killer (similar to oom_score_adj
> set to -1000).
>

Actually it is between -999 and -1000.

> This is by far a too strong side effect of setting memory.min,
> so I don't think the idea is acceptable at all.
>

More possible OOMs is also a strong side effect (and it prevent us
from using it).
Leave all other works to the userspace is not proper.
We should improve it.

Thanks
Yafang

