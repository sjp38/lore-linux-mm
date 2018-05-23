Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45B136B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 08:56:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p7-v6so17529970wrj.4
        for <linux-mm@kvack.org>; Wed, 23 May 2018 05:56:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y33-v6sor6068507wrd.59.2018.05.23.05.56.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 05:56:03 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] few memory hotplug fixes
Date: Wed, 23 May 2018 14:55:53 +0200
Message-Id: <20180523125555.30039-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@techadventures.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

[Resending with the mailing lists CCed - sorry for spamming]

Hi Andrew,
Oscar has reported two issue when playing with the memory hotplug
[1][2]. The first one seems more serious and patch 1 should address it.
In short we are overly optimistic about zone movable not containing any
non-movable pages and after 72b39cfc4d75 ("mm, memory_hotplug: do not
fail offlining too early") this can lead to a seemingly stuck (still
interruptible by a signal) memory offline.

Patch 2 fixes an over-eager warning which is not harmful but surely
annoying.

I know we are late in the release cycle but I guess both would be
candidates for rc7. They are simple enough and they should be
"obviously" correct. If you would like more time for them for testing
then I am perfectly fine postponing to the next merge window of course.

[1] http://lkml.kernel.org/r/20180523073547.GA29266@techadventures.net
[2] http://lkml.kernel.org/r/20180523080108.GA30350@techadventures.net

Michal Hocko (2):
      mm, memory_hotplug: make has_unmovable_pages more robust
      mm: do not warn on offline nodes unless the specific node is explicitly requested

Diffstat
 include/linux/gfp.h |  2 +-
 mm/page_alloc.c     | 16 ++++++++++------
 2 files changed, 11 insertions(+), 7 deletions(-)
