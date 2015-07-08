Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2C86B0254
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 09:04:31 -0400 (EDT)
Received: by wifm2 with SMTP id m2so88907944wif.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 06:04:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id la1si3780838wjc.209.2015.07.08.06.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 06:04:25 -0700 (PDT)
From: Michal Hocko <mhocko@suse.com>
Subject: [PATCH 0/4] oom: sysrq+f fixes + cleanups
Date: Wed,  8 Jul 2015 15:04:17 +0200
Message-Id: <1436360661-31928-1-git-send-email-mhocko@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
some of these patches have been posted already: http://marc.info/?l=linux-mm&m=143462145830969&w=2
This series contains an additional fix for another sysrq+f issue
reported off mailing list (patch #2).

First two patches are clear fixes. The third patch is from David with
my minor changes. The last patch is a cleanup but I have put it after
others because it has seen some opposition in the past.

Shortlog says:
David Rientjes (1):
      mm, oom: organize oom context into struct

Michal Hocko (3):
      oom: Do not panic when OOM killer is sysrq triggered
      oom: Do not invoke oom notifiers on sysrq+f
      oom: split out forced OOM killer

Thanks!

And diffstat:
 Documentation/sysrq.txt |   5 +-
 drivers/tty/sysrq.c     |   3 +-
 include/linux/oom.h     |  26 +++++----
 mm/memcontrol.c         |  13 +++--
 mm/oom_kill.c           | 141 +++++++++++++++++++++++++++---------------------
 mm/page_alloc.c         |   9 +++-
 6 files changed, 116 insertions(+), 81 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
