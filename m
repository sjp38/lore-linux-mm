Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4A536B2C19
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:51:14 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id n32-v6so4706286edc.17
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:51:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x9-v6sor1058377edq.14.2018.11.22.08.51.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 08:51:13 -0800 (PST)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 0/3] RFC: mmu notifier debug checks
Date: Thu, 22 Nov 2018 17:51:03 +0100
Message-Id: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@ffwll.ch>

Hi all,

We're having some good fun with the i915 mmu notifier (it deadlocks), and
I think it'd be very useful to have a bunch more runtime debug checks to
catch screw-ups.

I'm also working on some lockdep improvements in gpu code (better
annotations and stuff like that). Together with this series here this
seems to catch a lot of bugs pretty much instantly, which previously took
hours/days of CI workloads to reproduce. Plus now you get nice backtraces
and the kernel keeps working, whereas without this it's real deadlocks
with piles of stuck processes (the deadlock needed at least 3 processes,
but generally it took more to close the loop, plus everyone piling in on
top).

If this looks like a good idea I'm happy to polish it for merging.

Thanks, Daniel

Daniel Vetter (3):
  mm: Check if mmu notifier callbacks are allowed to fail
  mm, notifier: Catch sleeping/blocking for !blockable
  mm, notifier: Add a lockdep map for invalidate_range_start

 include/linux/mmu_notifier.h |  7 +++++++
 mm/mmu_notifier.c            | 17 ++++++++++++++++-
 2 files changed, 23 insertions(+), 1 deletion(-)

-- 
2.19.1
