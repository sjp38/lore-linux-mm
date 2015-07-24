Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 984C16B025B
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 08:06:40 -0400 (EDT)
Received: by lagw2 with SMTP id w2so12809747lag.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 05:06:40 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id jt6si6048063lab.77.2015.07.24.05.06.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 05:06:38 -0700 (PDT)
Date: Fri, 24 Jul 2015 15:06:24 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [mmotm:master 260/385] warning: (HWPOISON_INJECT && ..) selects
 PROC_PAGE_MONITOR which has unmet direct dependencies (PROC_FS && ..)
Message-ID: <20150724120624.GC8100@esperanza>
References: <201507240611.VJT8Z6kt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201507240611.VJT8Z6kt%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andres Lagar-Cavilla <andreslc@google.com>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Jul 24, 2015 at 06:29:12AM +0800, kbuild test robot wrote:

> warning: (HWPOISON_INJECT && MEM_SOFT_DIRTY && IDLE_PAGE_TRACKING) selects PROC_PAGE_MONITOR which has unmet direct dependencies (PROC_FS && MMU)

Should be fixed by the following patch:

From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] mm/Kconfig: fix IDLE_PAGE_TRACKING dependencies

Fixes: proc-add-kpageidle-file
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/mm/Kconfig b/mm/Kconfig
index db817e2c2ec8..a1de09926171 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -657,6 +657,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 
 config IDLE_PAGE_TRACKING
 	bool "Enable idle page tracking"
+	depends on PROC_FS && MMU
 	select PROC_PAGE_MONITOR
 	select PAGE_EXTENSION if !64BIT
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
