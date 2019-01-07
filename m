Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA4C38E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 06:08:15 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v24so19123997wrd.23
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 03:08:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h7sor35119406wrv.20.2019.01.07.03.08.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 03:08:14 -0800 (PST)
MIME-Version: 1.0
From: Amit Pundir <amit.pundir@linaro.org>
Date: Mon, 7 Jan 2019 16:37:37 +0530
Message-ID: <CAMi1Hd0fZwp7WzGhLSmWG3K+DS+nwT9P9o=zAOGRFDDhjpnGpQ@mail.gmail.com>
Subject: [for-4.9.y] Patch series "use up highorder free pages before OOM"
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Hi Minchan,

Kindly review your following mm/OOM upstream fixes for stable 4.9.y.

88ed365ea227 ("mm: don't steal highatomic pageblock")
04c8716f7b00 ("mm: try to exhaust highatomic reserve before the OOM")
29fac03bef72 ("mm: make unreserve highatomic functions reliable")

One of the patch from this series:
4855e4a7f29d ("mm: prevent double decrease of nr_reserved_highatomic")
has already been picked up for 4.9.y.

The original patch series https://lkml.org/lkml/2016/10/12/77 was sort
of NACked for stable https://lkml.org/lkml/2016/10/12/655 because no
one else reported this OOM behavior on lkml. And the only reason I'm
bringing this up again, for stable-4.9.y tree, is that msm-4.9 Android
trees cherry-picked this whole series as is for their production devices.

Are there any concerns around this series, in case I submit it to
stable mailing list for v4.9.y?

Regards,
Amit Pundir
