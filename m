Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A87FCC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 671102190F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DyZA8GwF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 671102190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16C316B000E; Thu, 25 Jul 2019 14:44:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11D3A6B0010; Thu, 25 Jul 2019 14:44:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00C168E0002; Thu, 25 Jul 2019 14:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2FF86B000E
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:44:30 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 191so31456805pfy.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:44:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cSpp6Nuo51h9S4IQ0r6ZMWrFSMbu5tBaK4Gt2EEXwJY=;
        b=afuGAoOF7Xb+25WrEr5vgu6oqegY2OcTUrXpUdJt50ZNV15yB8DUHMgIQLVcL7KEUY
         pP8IacGoXSriRzWaS2+zzVmULknZP8N6JkQpBFf/KJ6C/nAvT7RMlSXLaVMVQdv9QsHm
         ll81qycNgLloWT3zWifBkuiOLKJg/qyJsFqhHYhXgjAxTZi3bEfLOGOoO38Vi8qkqyZl
         dilzD9bRf0OIRjZOiEgiGg+BUx6kfC/xr01ULyatfw9Yz4FpmdlNMf9Bfz6OZsFQVayn
         Qo3JXiT/EulIp+tH3qczJGXp6/zyOKlaPll9/REl1crUhLqM91Ofit3sXDbBVRuWqBoF
         za7A==
X-Gm-Message-State: APjAAAUJfnMX+YpxL1iVFYpb7JX4C+mtBU4qQ9fA+YXhNdsoK2q3qB89
	SMh6+zKlCjon6OE5cO1lLnQJhXlQpbD4QlwmvZjEdVymcfjTARUz6A8CrklV3altgVmprdVl++F
	cYefRMQQpknNZFPgh1PHXmDg8FhElgUkBchF0GGhCMmL+yCXBkbFD7kAkN/lF5huYzA==
X-Received: by 2002:a62:35c6:: with SMTP id c189mr18090658pfa.96.1564080270496;
        Thu, 25 Jul 2019 11:44:30 -0700 (PDT)
X-Received: by 2002:a62:35c6:: with SMTP id c189mr18090610pfa.96.1564080269456;
        Thu, 25 Jul 2019 11:44:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080269; cv=none;
        d=google.com; s=arc-20160816;
        b=zF56st2z8r2NhUwmZy6FRr/8ak7b+0CT6VRxZ7D4i3skGCj4N0g8gpfr97/bzhJRwV
         l2ReVJEc08YVLH3f+l5aAzY0OUqcXm2l1ISycHx2WHe6GG0swsmTolwPee1Vdq42W2Zt
         hGiwIlShgCWsj2seNlOlgw2UvH/6QgXSoFwkLEVI8K6h7oTV6iCiaO9hRUjUZM8Ni9HV
         hW5LS6/leU7T+/30nkoA+bt/VPd8S9HQ7I+eHi0NYTFruwAvZCIDPHv6gsFpc3XgHnya
         HbK8oEApiUY2J+axp26OxTXqbabJdzzWomkWRly89Q02OVK9l0d0WFppHmAdW+XWzCxh
         J9Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=cSpp6Nuo51h9S4IQ0r6ZMWrFSMbu5tBaK4Gt2EEXwJY=;
        b=WwG9BLv57NHWgKCptUvb90m75hulHu6sCeKqvZfrC+/RstPWqDqPzy+xoyP8q/68k0
         dIGoJalFRxErX7BmUrXZav/p0o5OV7mCubrfonczcmc9vf13v+6vqb9zUbqnaducGk5l
         IT+Rl2/FWQmVb81HOZdSLH9nHyOcLNq1++jyAhX1zDKQ3kTi1A60WIABWn/VqQxuk9Ct
         u2Q8Q7RWOCE91UFrMobFldz2UtjQktwf/dm+ptiT75JeTkA5L5h4vuNlQYwXf9fiXQTT
         trrMA7JvE+8ajLsi0m3bQ1RC9TYiLuiXRY2sMZG+R/jl/uyO30tTNZvS3T/9feek0UuI
         ZlKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DyZA8GwF;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j21sor31721649pfr.2.2019.07.25.11.44.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:44:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DyZA8GwF;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=cSpp6Nuo51h9S4IQ0r6ZMWrFSMbu5tBaK4Gt2EEXwJY=;
        b=DyZA8GwFGugFPNtlb6hWQqdevFK/xcnOR1T7j4zqKSmueRWnvAGKZ0TdyG/ILXydMP
         QaU8fhvkVZuTxAypDDsTHwTjK8tk8Nny7LbDvofi1XkmE2WvdMeRs8CC628qrXpWlgFc
         mUdAzbj+Ayk8SxOiM2a3sSsK0gRsqtVFcRLHA7eLN/WE+xniQdjex/IEdmAwQMCP2oqU
         GrWuxTFPGidJ5KWv1Iu0N2QHh7uIWNiJvmDCK6BJmuVmaGFfWakftJPHqNe9T4h6MivC
         GFpAEtR2f0Mq0zscxlhOKj/ci7H3xrWIY1Ai83IKPF2oxCEK/sbjFL5hHouF9Q/GkQHD
         TW1g==
X-Google-Smtp-Source: APXvYqy9vQL6e+v//sfsxpH4SLF2FPA0wZMNMcxumuKmThjZf3GrZIKXbXgaGk5WSR6ilxCI3gSWhA==
X-Received: by 2002:a63:4846:: with SMTP id x6mr51416449pgk.332.1564080269118;
        Thu, 25 Jul 2019 11:44:29 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:624:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id w3sm43818257pgl.31.2019.07.25.11.44.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:44:28 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	mhocko@suse.com,
	vbabka@suse.cz,
	cai@lca.pw,
	aryabinin@virtuozzo.com,
	osalvador@suse.de,
	rostedt@goodmis.org,
	mingo@redhat.com,
	pavel.tatashin@microsoft.com,
	rppt@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 07/10] trace/events/compaction: make "order" unsigned int
Date: Fri, 26 Jul 2019 02:42:50 +0800
Message-Id: <20190725184253.21160-8-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190725184253.21160-1-lpf.vector@gmail.com>
References: <20190725184253.21160-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make the same type as "compact_control->order".

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/trace/events/compaction.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index e5bf6ee4e814..1e1e74f6d128 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -170,14 +170,14 @@ TRACE_EVENT(mm_compaction_end,
 TRACE_EVENT(mm_compaction_try_to_compact_pages,
 
 	TP_PROTO(
-		int order,
+		unsigned int order,
 		gfp_t gfp_mask,
 		int prio),
 
 	TP_ARGS(order, gfp_mask, prio),
 
 	TP_STRUCT__entry(
-		__field(int, order)
+		__field(unsigned int, order)
 		__field(gfp_t, gfp_mask)
 		__field(int, prio)
 	),
@@ -188,7 +188,7 @@ TRACE_EVENT(mm_compaction_try_to_compact_pages,
 		__entry->prio = prio;
 	),
 
-	TP_printk("order=%d gfp_mask=%s priority=%d",
+	TP_printk("order=%u gfp_mask=%s priority=%d",
 		__entry->order,
 		show_gfp_flags(__entry->gfp_mask),
 		__entry->prio)
@@ -197,7 +197,7 @@ TRACE_EVENT(mm_compaction_try_to_compact_pages,
 DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 
 	TP_PROTO(struct zone *zone,
-		int order,
+		unsigned int order,
 		int ret),
 
 	TP_ARGS(zone, order, ret),
@@ -205,7 +205,7 @@ DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 	TP_STRUCT__entry(
 		__field(int, nid)
 		__field(enum zone_type, idx)
-		__field(int, order)
+		__field(unsigned int, order)
 		__field(int, ret)
 	),
 
@@ -216,7 +216,7 @@ DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 		__entry->ret = ret;
 	),
 
-	TP_printk("node=%d zone=%-8s order=%d ret=%s",
+	TP_printk("node=%d zone=%-8s order=%u ret=%s",
 		__entry->nid,
 		__print_symbolic(__entry->idx, ZONE_TYPE),
 		__entry->order,
@@ -226,7 +226,7 @@ DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_finished,
 
 	TP_PROTO(struct zone *zone,
-		int order,
+		unsigned int order,
 		int ret),
 
 	TP_ARGS(zone, order, ret)
@@ -235,7 +235,7 @@ DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_finished,
 DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
 
 	TP_PROTO(struct zone *zone,
-		int order,
+		unsigned int order,
 		int ret),
 
 	TP_ARGS(zone, order, ret)
-- 
2.21.0

