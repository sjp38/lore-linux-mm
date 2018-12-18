Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6768E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 13:54:14 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a18so14409578pga.16
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 10:54:14 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id n3si14038675pld.36.2018.12.18.10.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 10:54:12 -0800 (PST)
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: [PATCH 0/2] ARC show_regs fixes
Date: Tue, 18 Dec 2018 10:53:57 -0800
Message-ID: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-snps-arc@lists.infradead.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Vineet  Gupta <vineet.gupta1@synopsys.com>

Vineet Gupta (2):
  ARC: show_regs: avoid page allocator
  ARC: show_regs: fix lockdep splat for good

 arch/arc/kernel/troubleshoot.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

-- 
2.7.4
