Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45045C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:14:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF01920643
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:14:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V4poo/qq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF01920643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 776A18E0003; Thu, 28 Feb 2019 03:14:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 723EB8E0001; Thu, 28 Feb 2019 03:14:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 613308E0003; Thu, 28 Feb 2019 03:14:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 207238E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:14:42 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h15so15398505pfj.22
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:14:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=zon0ew5x/BwZ1nMJkhATZQEPA03H1UiNt5omM55UDMk=;
        b=A8JTCTqUeC0YHgdiZB0VbIXhoY9TIeeZ7cSlv/DdPxB31Qp6mqAxvK3dX5JtS5J2WX
         oSLwJDewITzvwYG15geHkDScl7+027uSiV/vySKI2oHGtGUTr3UA5KhkVN7WrlJHAjOq
         iA56BAQVy6AhzvXz9k9gA54fX9/4e1qLMtQn6RL+fv3jice21sUvrlFQZzmtPUyHeM1J
         BWF4gctVv5UL7rUwiYXZbA3vkrRh0m4XjSrA+b/uZZMaMgMEsVRxF327YuUs234Z+KI0
         dvfYYeQrQ9cVBO7a6t4FlziIEOmf3lmlJs6zqVo76nFhQC8SNpyIsLI71k8BoG7PmqsK
         vCGw==
X-Gm-Message-State: AHQUAubmJYBDt2j7R0c6aj/RPofvmcWL6Juf2cyuEoe2ktPXMnTFl9ak
	m7QepcL8T61K5BtYv2yACYw6XD9CS1yK85yLtvoBT16cN10voQHc6jyisVcYM+lHL6R1Q+Cf5+I
	l6HXGrllbhQNwy77DTbUp9Tnvuqrh3JLfTvhVBbUOG8+D0qvYtlFV4O+PKLv76IfRMFP6iHXpT1
	47dHwLmit3u2wBGWoT5lnUrYJZc447hLQHndoECwm5wNwUOoF8lEPGBqCx/tLGF0vqPpglgzQP1
	4Sp4ueg13nm/NLDM9ZZj5cBo0HFBM4uWuBypNDeMFo1sJ8E2pbdUfcbcwO/pXVC1iVeddQ6FF2x
	p3RvIKkyqcQyWfZbfzvBizzQ2z1rPgb8SUjICQiPGOlWH7Js02gWArTQ1TsWqbEaE/hkZOeYpXy
	i
X-Received: by 2002:a17:902:2a69:: with SMTP id i96mr6676433plb.58.1551341681758;
        Thu, 28 Feb 2019 00:14:41 -0800 (PST)
X-Received: by 2002:a17:902:2a69:: with SMTP id i96mr6676374plb.58.1551341680790;
        Thu, 28 Feb 2019 00:14:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551341680; cv=none;
        d=google.com; s=arc-20160816;
        b=TZZtVVLgGHeOTWeRCj5rUupaFYG4fShIzqg702LCEabMEIzobx4xHH4uunNmDuB3qf
         Dmhz5Bdg1U2GZ73WEmn2kszah40OWEeADie1PS9SrTvjB5wBfNnOUNatC5p2HFvH/bKo
         AKnY6AnrVhQ9CXyi4AokzU4ENnqHQ25lfN7aijhbjR6iL0x+colepKnJzUPz8EQy0Mg8
         Ar7xYmQ8CFDbnN9NK8JSUstHwYRISI5L2/ddM5d07Hxjm+aXg5VI2RiruVOtvl3MXksE
         ZiQ0cgOBQqrYThPvUPThL8e0Otz+JMqliiwmMQk9cktSjayVxMc/UduNCTIENR6/z+dn
         ccvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=zon0ew5x/BwZ1nMJkhATZQEPA03H1UiNt5omM55UDMk=;
        b=poFaLb8nSAPEo3lcDQJ04bshnUG6jMKKfs0vEsUcNKhnFgNrdpTn63Pz+ZoyiPO73V
         CRCP4BSMYQC4AX6ol4yj4ik7w7HYb0oPOLC95sbctg47q6d+38Qmh3dwnKy/gUp9hpGi
         M4aQ3qnKZsjwu0FfU4umE5MHEFZvQAchJJePAHEQuujPXo0ZeaBZ5EvEb5jlS7vPEe2X
         E2tmSz3UP67DtxipqJB9t6lvKXpnSzPE6xZFeiKwgoXoo1sTUOaTFnOGXjlMc/r7KfX/
         D/NwdhS13+h+qtaTj9Zv2mlOjWmF+nDbCfrPOTng4X5l7p8epkHIFp91igftXnhJ3W2Q
         vXFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="V4poo/qq";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j187sor27157113pge.20.2019.02.28.00.14.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 00:14:40 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="V4poo/qq";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=zon0ew5x/BwZ1nMJkhATZQEPA03H1UiNt5omM55UDMk=;
        b=V4poo/qqoH40lYrImPCASuj8eZ34Ti7ztd+/i0PwEcVljD4HuJ7O0EYtbtyY3hWO5K
         UaZkBtc4U3K8NYk0pXEevyAKxW72Fk9iHyLw/oRYc7quovIOwjeqANfD/RF1PaC10oTp
         FaMx5IxynzOxqX7P5eSColJysPiWtWfJpTUuxiTGjDrQUhRGDaOdYLr6Z0ToOhqL6e1v
         iCCsCYFje2WBhq9Q861wA+G36FY4+f21tSXcDHrwqxNEj3yA+eNsmXme2lUTw0jMvMFi
         hDzHdJ3TjHAvWdMCgK/Km1+7sQ4mcDWvRO5Q0Ty2OPFu+27gxPH5NtSZbjE38paIDBHt
         w0Jg==
X-Google-Smtp-Source: AHgI3IbKxVlM8kW6WNolAQ4mMGdkts+dktB9N5rAUcO0TkT8dj1WiWgQQtI5/trK/hKLbUbQlnNWsQ==
X-Received: by 2002:a63:43c1:: with SMTP id q184mr7151757pga.110.1551341680449;
        Thu, 28 Feb 2019 00:14:40 -0800 (PST)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id m13sm34387106pff.175.2019.02.28.00.14.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 00:14:39 -0800 (PST)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	ktkhai@virtuozzo.com,
	broonie@kernel.org,
	hannes@cmpxchg.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: vmscan: add tracepoints for node reclaim
Date: Thu, 28 Feb 2019 16:14:24 +0800
Message-Id: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the page alloc fast path, it may do node reclaim, which may cause
latency spike.
We should add tracepoint for this event, and also mesure the latency
it causes.

So bellow two tracepoints are introduced,
	mm_vmscan_node_reclaim_begin
	mm_vmscan_node_reclaim_end

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/vmscan.h | 48 +++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                   | 13 +++++++++++-
 2 files changed, 60 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb913..9310d5b 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -465,6 +465,54 @@
 		__entry->ratio,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
+
+TRACE_EVENT(mm_vmscan_node_reclaim_begin,
+
+	TP_PROTO(int nid, int order, int may_writepage,
+		gfp_t gfp_flags, int zid),
+
+	TP_ARGS(nid, order, may_writepage, gfp_flags, zid),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(int, order)
+		__field(int, may_writepage)
+		__field(gfp_t, gfp_flags)
+		__field(int, zid)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->order = order;
+		__entry->may_writepage = may_writepage;
+		__entry->gfp_flags = gfp_flags;
+		__entry->zid = zid;
+	),
+
+	TP_printk("nid=%d zid=%d order=%d may_writepage=%d gfp_flags=%s",
+		__entry->nid,
+		__entry->zid,
+		__entry->order,
+		__entry->may_writepage,
+		show_gfp_flags(__entry->gfp_flags))
+);
+
+TRACE_EVENT(mm_vmscan_node_reclaim_end,
+
+	TP_PROTO(int result),
+
+	TP_ARGS(result),
+
+	TP_STRUCT__entry(
+		__field(int, result)
+	),
+
+	TP_fast_assign(
+		__entry->result = result;
+	),
+
+	TP_printk("result=%d", __entry->result)
+);
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ac4806f..01a0401 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4240,6 +4240,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.may_swap = 1,
 		.reclaim_idx = gfp_zone(gfp_mask),
 	};
+	int result;
+
+	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
+					sc.may_writepage,
+					sc.gfp_mask,
+					sc.reclaim_idx);
 
 	cond_resched();
 	fs_reclaim_acquire(sc.gfp_mask);
@@ -4267,7 +4273,12 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	current->flags &= ~PF_SWAPWRITE;
 	memalloc_noreclaim_restore(noreclaim_flag);
 	fs_reclaim_release(sc.gfp_mask);
-	return sc.nr_reclaimed >= nr_pages;
+
+	result = sc.nr_reclaimed >= nr_pages;
+
+	trace_mm_vmscan_node_reclaim_end(result);
+
+	return result;
 }
 
 int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
-- 
1.8.3.1

