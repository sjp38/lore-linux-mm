Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id D080F8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:39:22 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id b186so149957wmc.8
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:39:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1sor35185705wro.44.2019.01.07.06.39.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 06:39:21 -0800 (PST)
MIME-Version: 1.0
References: <CAMi1Hd0fZwp7WzGhLSmWG3K+DS+nwT9P9o=zAOGRFDDhjpnGpQ@mail.gmail.com>
 <20190107114710.GA206194@google.com>
In-Reply-To: <20190107114710.GA206194@google.com>
From: Amit Pundir <amit.pundir@linaro.org>
Date: Mon, 7 Jan 2019 20:08:44 +0530
Message-ID: <CAMi1Hd2Zo=zK-rYUd9=Fq87QU7qr2rhftJB+CS-OUFWFQD+OPQ@mail.gmail.com>
Subject: Re: [for-4.9.y] Patch series "use up highorder free pages before OOM"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, 7 Jan 2019 at 17:17, Minchan Kim <minchan@kernel.org> wrote:
>
> On Mon, Jan 07, 2019 at 04:37:37PM +0530, Amit Pundir wrote:
> > Hi Minchan,
> >
> > Kindly review your following mm/OOM upstream fixes for stable 4.9.y.
> >
> > 88ed365ea227 ("mm: don't steal highatomic pageblock")
> > 04c8716f7b00 ("mm: try to exhaust highatomic reserve before the OOM")
> > 29fac03bef72 ("mm: make unreserve highatomic functions reliable")
> >
> > One of the patch from this series:
> > 4855e4a7f29d ("mm: prevent double decrease of nr_reserved_highatomic")
> > has already been picked up for 4.9.y.
> >
> > The original patch series https://lkml.org/lkml/2016/10/12/77 was sort
> > of NACked for stable https://lkml.org/lkml/2016/10/12/655 because no
> > one else reported this OOM behavior on lkml. And the only reason I'm
> > bringing this up again, for stable-4.9.y tree, is that msm-4.9 Android
> > trees cherry-picked this whole series as is for their production devices.
> >
> > Are there any concerns around this series, in case I submit it to
> > stable mailing list for v4.9.y?
>
> Actually, it was not NAK. Other MM guy wanted to backport but I didn't
> intentionally because I didn't see other reports at that time.
>
> However, after that, I got a private email from some other kernel team
> and debugged together. It hit this problem and solved by above patches
> so they backported it.
> If you say Android already check-picked them, it's third time I heard
> the problem(If they really pick those patch due to some problem) since
> we merge those patches into upstream.
> So, I belive it's worth to merge if someone could volunteer.

This is where it gets tricky, Code Aurora cherry-picked these patches
for their Android v4.9.y tree, where they get applied cleanly i.e. no
backport needed. But there is no way to tell if these patches indeed
solved an OOM bug or two for them.

So let me put it this way, is it safe to apply this series on v4.9
kernel? Or should I be wary of regressions?

Regards,
Amit Pundir

>
> Thanks.
