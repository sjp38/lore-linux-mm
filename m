Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3239C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 09:57:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAB3F20863
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 09:57:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAB3F20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 504F58E00D6; Mon, 11 Feb 2019 04:57:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B3F48E00D2; Mon, 11 Feb 2019 04:57:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CBD08E00D6; Mon, 11 Feb 2019 04:57:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE9928E00D2
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:57:31 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id y85so6572046wmc.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 01:57:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=43gfAs8S19v+DF7nahEqdkiir2tpELaJfFMcaGcH8sI=;
        b=AOpRuh30xWm3/8cq4TgFI5Sei9a3o9MgBeJuEmPCatMIsxk4sDPxjhLOBVDe00Pn5j
         V6fH8wtWjnCRWEvPLrfdzYhG0xXvhEn2TX+JaDmroA6mTH55TyvR3icSR2glUwfkcIon
         CMI3lIFmVrsRYtb10915LD0BkkDQ9mJSjW9pqmUNNt4knw6W64HTjhG+57oXR/ZK/NSW
         TiP4xKWo0OhMBgP5SWP+5LMU59tWbtTrq2RyI7SV8JOVt4e1LCujrWlXBwlSSz8kEmrt
         RYgwC1He7G1bi+f55PlP3vA3/Ia4loh5ZOghQdVYzFE/dDeIELsR0S0OlvD7UfKIYAfk
         HGZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: AHQUAubp3m2kQw6/6RDY/7G0VbvvR+LgJDwEg7OB00lnrxZSSHEwK4t3
	hP/mjt1yPNcgZpHwtEOIgyzENLYmhYNiRe49eocNj1TyLS8REKU1ha3eqXTz4OtllrwyZ+wX89l
	Lrfdrndbtdgd9TYuIzX5BUBK9v1VyuBBlNZve8k22BzRYvCv1PndhtS67ZeH0daJmiQ==
X-Received: by 2002:a1c:b30a:: with SMTP id c10mr8579043wmf.126.1549879051310;
        Mon, 11 Feb 2019 01:57:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IayGCgWPu7KhDSITWnAtlXhCnbtoxQhYCtd2UTD/3Zs/UN8XUcQkos0oizjIEoVnF0aeb7V
X-Received: by 2002:a1c:b30a:: with SMTP id c10mr8578998wmf.126.1549879050410;
        Mon, 11 Feb 2019 01:57:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549879050; cv=none;
        d=google.com; s=arc-20160816;
        b=WFfGL64TUTKcyJzqndPIx5P2q9wRGdXjDU097U74H2W9Vbcj7vq0GXTR7Z71xJQgb0
         7gP+XeUXi5lDQQxIdp8VxoWCBXTmAxFZVgyCGOtUOnHIy8/ob2GhsG232KsR2NsKeQrq
         zASsea4NguAs0vSFQ0ltghQUP0tjiyovcX+d3caBcbb6JIDIzNnFHuL01XbIFjR8Nsvy
         ZwSYi0FOaTvTbm8HziwUplAXPSolY506sLP/rove9++4tzDHm8oo/VmVhf6gFuEJCGX3
         3vpWeOrZR3lgpfDd04awBbKnwEiCXkSXaKV+/fYisQuQvNyd3yD915N8J6p71imo5Mkb
         pK8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=43gfAs8S19v+DF7nahEqdkiir2tpELaJfFMcaGcH8sI=;
        b=B+b2AyhPl4ZhCIFa8wl6Lkb1oS8QqJnARW6eiOeEnzwzPcxQNyz/PJrbOtDQ8TERqV
         YHx30x99MeRTXIv0VS5fYY2lNEZA5elX1bUGOleBfgk/XBh50aNPo6PS5cbF23WtF2ji
         1/as9XRDBo4bXLjzzxZAog76roK2NNRHq3elTcKP/NzhodaT3Nq66JoMHWlpIKH+uHgy
         d4L7w6AhYZ3mN0wg/QRGRXAsW4FTkytgkX/AmsGeIIaGibPiIX21p1KO38rgHH8Jo9QA
         eip6c+Sg/Yef4fWtbz7vtTxtxSyiuIaUeTbn3sHTpVq6BaXYMs49o42izHpXR998ptTy
         sebg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u185si7155108wmg.131.2019.02.11.01.57.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 11 Feb 2019 01:57:30 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1gt8L7-0001NA-4u; Mon, 11 Feb 2019 10:57:25 +0100
Date: Mon, 11 Feb 2019 10:57:25 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH] mm: workingset: replace IRQ-off check with a lockdep assert.
Message-ID: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit

  68d48e6a2df57 ("mm: workingset: add vmstat counter for shadow nodes")

introduced an IRQ-off check to ensure that a lock is held which also
disabled interrupts. This does not work the same way on -RT because none
of the locks, that are held, disable interrupts.
Replace this check with a lockdep assert which ensures that the lock is
held.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/workingset.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index dcb994f2acc2e..c75d10d48be16 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -368,6 +368,8 @@ static struct list_lru shadow_nodes;
 
 void workingset_update_node(struct xa_node *node)
 {
+	struct address_space *mapping;
+
 	/*
 	 * Track non-empty nodes that contain only shadow entries;
 	 * unlink those that contain pages or are being freed.
@@ -376,7 +378,8 @@ void workingset_update_node(struct xa_node *node)
 	 * already where they should be. The list_empty() test is safe
 	 * as node->private_list is protected by the i_pages lock.
 	 */
-	VM_WARN_ON_ONCE(!irqs_disabled());  /* For __inc_lruvec_page_state */
+	mapping = container_of(node->array, struct address_space, i_pages);
+	lockdep_is_held(&mapping->i_pages.xa_lock);
 
 	if (node->count && node->count == node->nr_values) {
 		if (list_empty(&node->private_list)) {
-- 
2.20.1

