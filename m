Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 847049003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 04:21:33 -0400 (EDT)
Received: by lblf12 with SMTP id f12so10417373lbl.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 01:21:33 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id d7si6861081lag.88.2015.07.24.01.21.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 01:21:31 -0700 (PDT)
Date: Fri, 24 Jul 2015 11:21:17 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [linux-next:master 3983/4215] fs/proc/page.c:332:4: error:
 implicit declaration of function 'pmdp_clear_young_notify'
Message-ID: <20150724082117.GD19029@esperanza>
References: <201507241449.L78EAUko%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201507241449.L78EAUko%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Andres Lagar-Cavilla <andreslc@google.com>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Jul 24, 2015 at 02:37:50PM +0800, kbuild test robot wrote:

>    fs/proc/page.c: In function 'kpageidle_clear_pte_refs_one':
> >> fs/proc/page.c:332:4: error: implicit declaration of function 'pmdp_clear_young_notify'
> >> fs/proc/page.c:338:4: error: implicit declaration of function 'ptep_clear_young_notify'

From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] mmu_notifier: add missing stubs for clear_young

This is a compilation fix for !CONFIG_MMU_NOTIFIER.

Fixes: mmu-notifier-add-clear_young-callback
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index a5b17137c683..a1a210d59961 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -471,6 +471,8 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
+#define ptep_clear_young_notify ptep_test_and_clear_young
+#define pmdp_clear_young_notify pmdp_test_and_clear_young
 #define	ptep_clear_flush_notify ptep_clear_flush
 #define pmdp_huge_clear_flush_notify pmdp_huge_clear_flush
 #define pmdp_huge_get_and_clear_notify pmdp_huge_get_and_clear

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
