Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CCC336B0268
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 10:33:06 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id f132so4021504wmf.6
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:33:06 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r192sor1883140wme.51.2017.12.21.07.33.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 07:33:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALvZod432hzxPZgAypjPsZ33Z==0MxmMdPM3bEBZMea-7GFAVw@mail.gmail.com>
References: <20171219152444.GP3919388@devbig577.frc2.facebook.com>
 <CALvZod5sWWBX69QovOeLBSx9vij7=5cmoSocdTUvh2Uq8=noyQ@mail.gmail.com>
 <20171219173354.GQ3919388@devbig577.frc2.facebook.com> <CALvZod7pbp0fFUPRnC68qdzkCEUg2YTavq6C6OLxqooCU5VeyQ@mail.gmail.com>
 <20171219214107.GR3919388@devbig577.frc2.facebook.com> <CALvZod5XRhXc3XrQw50Jw_OpRQB2iCCbgG-NMDCa8xRmGNdLrw@mail.gmail.com>
 <20171220193741.GD3413940@devbig577.frc2.facebook.com> <CALvZod7Z1Yh+ZhU8qxzSiN0Pph2R7O4Mki5E23FbJFAzhyCH8g@mail.gmail.com>
 <20171220233658.GB1084507@devbig577.frc2.facebook.com> <CALvZod7eQWrD6LgbUrOvuhf5A1KKxBaK5t-U61gdFqvMeWXuzQ@mail.gmail.com>
 <20171221133726.GD1084507@devbig577.frc2.facebook.com> <CALvZod432hzxPZgAypjPsZ33Z==0MxmMdPM3bEBZMea-7GFAVw@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 21 Dec 2017 07:33:03 -0800
Message-ID: <CALvZod59K7ZoM3jAGQih7HjVNJQBAgrTwZAxsSHqX1kHT6RYOA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

> The swap (and its performance) is and should be transparent
> to the job owners.

Please ignore this statement, I didn't mean to claim on the
independence of job performance and underlying swap performance, sorry
about that.

I meant to say that the amount of anon memory a job can allocate
should be independent to the underlying swap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
