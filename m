Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 132CD8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:35:14 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 68so2631353pfr.6
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:35:14 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id u129si18867621pfu.117.2019.01.23.12.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:35:13 -0800 (PST)
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: [PATCH v2 0/3] Replace opencoded set_mask_bits
Date: Wed, 23 Jan 2019 12:33:01 -0800
Message-ID: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, peterz@infradead.org, mark.rutland@arm.com, Vineet Gupta <vineet.gupta1@synopsys.com>

Hi,

Repost of [1] rebased on 5.0-rc3 + accumulated Acked-by/Reviewed-by.
No code changes since v1.

Please consider applying.

[1] http://lists.infradead.org/pipermail/linux-snps-arc/2019-January/005201.html

Thx,
-Vineet

Vineet Gupta (3):
  coredump: Replace opencoded set_mask_bits()
  fs: inode_set_flags() replace opencoded set_mask_bits()
  bitops.h: set_mask_bits() to return old value

 fs/exec.c              | 7 +------
 fs/inode.c             | 8 +-------
 include/linux/bitops.h | 2 +-
 3 files changed, 3 insertions(+), 14 deletions(-)

-- 
2.7.4
