Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B70D36B025E
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 05:24:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q76so3502784pfq.5
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 02:24:56 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 34si404049plz.129.2017.09.15.02.24.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 02:24:55 -0700 (PDT)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH 3/3] sysctl/vm.txt: Update document
Date: Fri, 15 Sep 2017 17:23:26 +0800
Message-Id: <1505467406-9945-4-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Kemi Wang <kemi.wang@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Add a paragraph to introduce the functionality and usage on vmstat_mode in
sysctl/vm.txt

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
Suggested-by: Ying Huang <ying.huang@intel.com>
Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 Documentation/sysctl/vm.txt | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9baf66a..6ab2843 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -61,6 +61,7 @@ Currently, these files are in /proc/sys/vm:
 - swappiness
 - user_reserve_kbytes
 - vfs_cache_pressure
+- vmstat_mode
 - watermark_scale_factor
 - zone_reclaim_mode
 
@@ -843,6 +844,31 @@ ten times more freeable objects than there are.
 
 =============================================================
 
+vmstat_mode
+
+This interface allows virtual memory statistics configurable.
+
+When performance becomes a bottleneck and you can tolerate some possible
+tool breakage and some decreased counter precision (e.g. numa counter), you
+can do:
+	echo [C|c]oarse > /proc/sys/vm/vmstat_mode
+ignorable statistics list:
+- numa counters
+
+When performance is not a bottleneck and you want all tooling to work, you
+can do:
+	echo [S|s]trict > /proc/sys/vm/vmstat_mode
+
+We recommend automatic detection of virtual memory statistics by system,
+this is also system default configuration, you can do:
+	echo [A|a]uto > /proc/sys/vm/vmstat_mode
+
+E.g. numa statistics does not affect system's decision and it is very
+rarely consumed. If set vmstat_mode = auto, numa counters update is skipped
+unless the counter is *read* by users at least once.
+
+==============================================================
+
 watermark_scale_factor:
 
 This factor controls the aggressiveness of kswapd. It defines the
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
