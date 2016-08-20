Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6F36B0038
	for <linux-mm@kvack.org>; Sat, 20 Aug 2016 04:00:22 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j67so172656499oih.3
        for <linux-mm@kvack.org>; Sat, 20 Aug 2016 01:00:22 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0234.hostedemail.com. [216.40.44.234])
        by mx.google.com with ESMTPS id e4si7985382ite.66.2016.08.20.01.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Aug 2016 01:00:21 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] seq: Speed up /proc/<pid>/smaps
Date: Sat, 20 Aug 2016 01:00:15 -0700
Message-Id: <cover.1471679737.git.joe@perches.com>
In-Reply-To: <20160820072927.GA23645@dhcp22.suse.cz>
References: <20160820072927.GA23645@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org

Doing a simple cat of these files can take a lot more cpu than
it should.  Optimize it a bit.

Joe Perches (2):
  seq_file: Add __seq_open_private_bufsize for seq file_operation sizes
  proc: task_mmu: Reduce output processing cpu time

 fs/proc/task_mmu.c       | 94 ++++++++++++++++++++++++------------------------
 fs/seq_file.c            | 31 ++++++++++++++++
 include/linux/seq_file.h |  3 ++
 3 files changed, 82 insertions(+), 46 deletions(-)

-- 
2.8.0.rc4.16.g56331f8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
