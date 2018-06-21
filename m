Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6656B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 06:59:24 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j10-v6so1135968pgv.6
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 03:59:24 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n187-v6si3639304pga.98.2018.06.21.03.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 03:59:23 -0700 (PDT)
Date: Thu, 21 Jun 2018 18:58:48 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [RFC PATCH] mm, oom: oom_free_timeout_ms can be static
Message-ID: <20180621105848.GA114615@lkp-hsx02>
References: <alpine.DEB.2.21.1806201458540.14059@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1806201458540.14059@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


Fixes: 45c6e373dd94 ("mm, oom: fix unnecessary killing of additional processes")
Signed-off-by: kbuild test robot <fengguang.wu@intel.com>
---
 oom_kill.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8a775c4..6b776b9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -653,7 +653,7 @@ static int oom_reaper(void *unused)
  * Millisecs to wait for an oom mm to free memory before selecting another
  * victim.
  */
-u64 oom_free_timeout_ms = 1000;
+static u64 oom_free_timeout_ms = 1000;
 static void wake_oom_reaper(struct task_struct *tsk)
 {
 	/*
