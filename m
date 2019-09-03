Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D189C3A5A5
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 20:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DFA921883
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 20:09:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="RAFKiSFF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DFA921883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E02186B0005; Tue,  3 Sep 2019 16:09:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB3C56B0006; Tue,  3 Sep 2019 16:09:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA0A86B0007; Tue,  3 Sep 2019 16:09:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0208.hostedemail.com [216.40.44.208])
	by kanga.kvack.org (Postfix) with ESMTP id A47296B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:09:14 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 16D7F180AD802
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 20:09:14 +0000 (UTC)
X-FDA: 75894698628.27.box50_3371858643154
X-HE-Tag: box50_3371858643154
X-Filterd-Recvd-Size: 7224
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 20:09:13 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id d15so2055816pfo.10
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 13:09:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=7eVGP53YTW/D0hbaqvHg3EgbpTi7q/9GTd1TuT/wVbs=;
        b=RAFKiSFFOo6SWz2LmXsJCz9OopbHRQ1px8LjsohZczWNPODmZ8d250yRDbLckVfPQi
         fCdXUHhxg3W+O9ovB2KR7q51aN+DvqFDAe0QDKABwNuf+zut+p+XENj3KsQ/Y82HSVH8
         38RS42Vo8hje0mxI7kPzRZQtRcFgtUsRmiRSc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=7eVGP53YTW/D0hbaqvHg3EgbpTi7q/9GTd1TuT/wVbs=;
        b=H3y/OLQvUn5Q44imO7Oi3QPI65D5bxYS66xMwIapQzUG0KtTKr4RiMLj7C/4pmJN/X
         5p/qLeslQyyHtn3/JpvUd6ZQeR5xAdM42VJBM5GjUi3HpuPqMO7etNVRicaYmeIk5fA9
         UfIBHzUVHNK+EiA291zbQYQU4jfU6whOQ+r6agES+xyhIDeM007aRoXwryID6v9y2Vcd
         Aij+aQPcGxFyvObI8X2Ra5xFNrVMOESo/0MUHy5VZbII0gvwGwyfphyFRwSBAGVoXTTY
         H1kNS+8FLXC2QML4jWXDgeNZtfddot8kAi0rfcSn7nyDQnk/Ylr7WlAL5hU4Agb3kmAi
         /piQ==
X-Gm-Message-State: APjAAAU0Y4NverGvWzJj459OJwDwpD0Rvv+2YnUxtXik+55oSHc4h2RC
	UknIqzCOyDHj94LfYhp6OEIm7w==
X-Google-Smtp-Source: APXvYqxyyljZGlHrPmCRSYgC2fuoUWmRy8YfTx4pOoOE+ElDtTnIKw5bOMZ4hJBZcO0wfMbBd6wtOA==
X-Received: by 2002:a62:7641:: with SMTP id r62mr40628483pfc.201.1567541352326;
        Tue, 03 Sep 2019 13:09:12 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id a23sm19651758pfo.80.2019.09.03.13.09.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 13:09:11 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Tim Murray <timmurray@google.com>,
	carmenjackson@google.com,
	mayankgupta@google.com,
	dancol@google.com,
	rostedt@goodmis.org,
	minchan@kernel.org,
	akpm@linux-foundation.org,
	kernel-team@android.com,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"Jerome Glisse" <jglisse@redhat.com>,
	linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.cz>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Date: Tue,  3 Sep 2019 16:09:05 -0400
Message-Id: <20190903200905.198642-1-joel@joelfernandes.org>
X-Mailer: git-send-email 2.23.0.187.g17f5b7556c-goog
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Useful to track how RSS is changing per TGID to detect spikes in RSS and
memory hogs. Several Android teams have been using this patch in various
kernel trees for half a year now. Many reported to me it is really
useful so I'm posting it upstream.

Initial patch developed by Tim Murray. Changes I made from original patch=
:
o Prevent any additional space consumed by mm_struct.
o Keep overhead low by checking if tracing is enabled.
o Add some noise reduction and lower overhead by emitting only on
  threshold changes.

Co-developed-by: Tim Murray <timmurray@google.com>
Signed-off-by: Tim Murray <timmurray@google.com>
Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>

---

v1->v2: Added more commit message.

Cc: carmenjackson@google.com
Cc: mayankgupta@google.com
Cc: dancol@google.com
Cc: rostedt@goodmis.org
Cc: minchan@kernel.org
Cc: akpm@linux-foundation.org
Cc: kernel-team@android.com

 include/linux/mm.h          | 14 +++++++++++---
 include/trace/events/kmem.h | 21 +++++++++++++++++++++
 mm/memory.c                 | 20 ++++++++++++++++++++
 3 files changed, 52 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..823aaf759bdb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1671,19 +1671,27 @@ static inline unsigned long get_mm_counter(struct=
 mm_struct *mm, int member)
 	return (unsigned long)val;
 }
=20
+void mm_trace_rss_stat(int member, long count, long value);
+
 static inline void add_mm_counter(struct mm_struct *mm, int member, long=
 value)
 {
-	atomic_long_add(value, &mm->rss_stat.count[member]);
+	long count =3D atomic_long_add_return(value, &mm->rss_stat.count[member=
]);
+
+	mm_trace_rss_stat(member, count, value);
 }
=20
 static inline void inc_mm_counter(struct mm_struct *mm, int member)
 {
-	atomic_long_inc(&mm->rss_stat.count[member]);
+	long count =3D atomic_long_inc_return(&mm->rss_stat.count[member]);
+
+	mm_trace_rss_stat(member, count, 1);
 }
=20
 static inline void dec_mm_counter(struct mm_struct *mm, int member)
 {
-	atomic_long_dec(&mm->rss_stat.count[member]);
+	long count =3D atomic_long_dec_return(&mm->rss_stat.count[member]);
+
+	mm_trace_rss_stat(member, count, -1);
 }
=20
 /* Optimized variant when page is already known not to be PageAnon */
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index eb57e3037deb..8b88e04fafbf 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -315,6 +315,27 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->change_ownership)
 );
=20
+TRACE_EVENT(rss_stat,
+
+	TP_PROTO(int member,
+		long count),
+
+	TP_ARGS(member, count),
+
+	TP_STRUCT__entry(
+		__field(int, member)
+		__field(long, size)
+	),
+
+	TP_fast_assign(
+		__entry->member =3D member;
+		__entry->size =3D (count << PAGE_SHIFT);
+	),
+
+	TP_printk("member=3D%d size=3D%ldB",
+		__entry->member,
+		__entry->size)
+	);
 #endif /* _TRACE_KMEM_H */
=20
 /* This part must be outside protection */
diff --git a/mm/memory.c b/mm/memory.c
index e2bb51b6242e..9d81322c24a3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -72,6 +72,8 @@
 #include <linux/oom.h>
 #include <linux/numa.h>
=20
+#include <trace/events/kmem.h>
+
 #include <asm/io.h>
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
@@ -140,6 +142,24 @@ static int __init init_zero_pfn(void)
 }
 core_initcall(init_zero_pfn);
=20
+/*
+ * This threshold is the boundary in the value space, that the counter h=
as to
+ * advance before we trace it. Should be a power of 2. It is to reduce u=
nwanted
+ * trace overhead. The counter is in units of number of pages.
+ */
+#define TRACE_MM_COUNTER_THRESHOLD 128
+
+void mm_trace_rss_stat(int member, long count, long value)
+{
+	long thresh_mask =3D ~(TRACE_MM_COUNTER_THRESHOLD - 1);
+
+	if (!trace_rss_stat_enabled())
+		return;
+
+	/* Threshold roll-over, trace it */
+	if ((count & thresh_mask) !=3D ((count - value) & thresh_mask))
+		trace_rss_stat(member, count);
+}
=20
 #if defined(SPLIT_RSS_COUNTING)
=20
--=20
2.23.0.187.g17f5b7556c-goog

