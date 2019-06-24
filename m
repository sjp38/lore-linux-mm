Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6385C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:06:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 573322063F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:06:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ci0OKKcZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 573322063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEEAB8E0003; Mon, 24 Jun 2019 09:06:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC7568E0002; Mon, 24 Jun 2019 09:06:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB5D78E0003; Mon, 24 Jun 2019 09:06:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A26768E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:06:51 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n7so4321259pgr.12
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:06:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=XFbbsnGz16ubBdyKJEViXGxsb6uY/jBZOE6mchMBd4g=;
        b=O4bhcuEPLkRsbhgrfCF69nns6F9B4nLyMjmBR1YK4I+Ul+U66wfryRCf/yp7SA4sRo
         u3cnXx5tsxcCWQTnSazymUFlqnJpKMvVbkqpHGEez2ojHgIAZj3FY+iRrOYP+ol2dvbR
         cjpMQQSmbM+2EEB43sA+F0NH3MCUK1+h30fWUZp5DyKkcEbtkYhiynrHyo4LTwfKQwty
         f402OghJwyM2JZAvsgRvHj8shQzhG8HiJpcptO5j4qZo0DEEBfHryGa8/s7MmzpNwTPW
         KguZkI6FHj8ugf1VYLM5oU6v3oLgFYZ3hTElE5NdgCBt/iDOLYPalbDJijrAyp3O2O99
         HfZg==
X-Gm-Message-State: APjAAAUiwyWTVs/BBF99tGkIYNykeDaZMK22Fj5fAxNgaeGbTVtufJnQ
	HdHba6aDeOSFgsOixrySc8sin1uAw6NTFOEKbWffcs1rbNdQieWeDx041fJS1FKqeeO63rgJwTm
	C20bTKXum5YIKYQ8RYa0t7OLIFcj0V+JVUCFWpSqsrgTD2k+gySLnWmxNdKSC8yWggA==
X-Received: by 2002:a65:62c2:: with SMTP id m2mr9203584pgv.413.1561381611051;
        Mon, 24 Jun 2019 06:06:51 -0700 (PDT)
X-Received: by 2002:a65:62c2:: with SMTP id m2mr9203493pgv.413.1561381610128;
        Mon, 24 Jun 2019 06:06:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561381610; cv=none;
        d=google.com; s=arc-20160816;
        b=tSXqUDHsVHO+n3rgyxPijNrR+qy8o5rfLOBcuPNFL+Kcmw3cLw5fjpv2A5L4kK+tdt
         cLIS6x/EB2VyEPd1u9e2BKGCpJssRvdfO1SRB4kNWISzUlnttmA09qGIN33YfXFNiRX0
         paz3xLxaG3MjMlcRY0qKM7tBVwXjm+J4qnoHkK6SJ+QmKhhISxyKTTYs92dUR/PSMI57
         igJpwl0GMT5zPReGs0YBYkQ2Dy/ar6OQ06ptfo3hCCm+WEQWb3reIryVCmUnKba4ArDw
         iOh/YS/SLHm7aMJoDv6bNN5NC3CgYuiUZweVHJKDbcG5TgZPeErsgqz0YcVR97e3vS+e
         KCLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=XFbbsnGz16ubBdyKJEViXGxsb6uY/jBZOE6mchMBd4g=;
        b=MBfn8Nmx51vGD+KkF10eEiW/7DzyRgu9FxsZhl6oTVx41thoFfmcUANr/vkDXdmwl3
         jKge39kLUGXbHl/EcKDE/WfGssjkjmqLongGgucCkEV2xYdsvJnEjndpknce2NtCMrNO
         bWvpQRIU6rDMjPseiwZP4RWE9dOgx2x7YGyNXbRZ2ysrTz/nisHeTVZIKlJ//I109A0h
         W7rf7mCeVjr3uwpKcBKAboN7R2Iy1xxpaPbos0fMftJ3kekj+o5iVTNrI8YEbdKrFjnY
         +/dy83vnC0r7teVpC3X2Dp/4g/dT/R1HWWl6/2KVQaHVas8eMOgBhR8C0MeJpE/M4Y9u
         5Hpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ci0OKKcZ;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r27sor7111271pfg.42.2019.06.24.06.06.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 06:06:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ci0OKKcZ;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=XFbbsnGz16ubBdyKJEViXGxsb6uY/jBZOE6mchMBd4g=;
        b=Ci0OKKcZpfCCzb3wyBiUs5GtEotx0DlmKkaRZiV7i5zZV1Eyha6bCbUlFp5iKeI4Zg
         0NrbavM4/dGkMSExR9Y+wcJd9FGjVosmZw7z//Kla3UiQQsXqswIkwScQ7CL4b9zH9/+
         ATohfwGcP+o2aGWd+JXRR6HAInr8PqyqoGAUHnn0vvIArcrSvpGpRMbJ0B+aGIk0103w
         gUXWs0Lo+DVzoCuZcM27DMFB9GfX7B8WMnOUgYrxLZHcXhqN/DZTEw2FZdnuV4t6pePJ
         WE848Y/V3FxnExi2nZTVCP6/Om05HF+QDqZ/J+GoNJV1NB516JKoOsw5fRbAvKTn8jB3
         yzDg==
X-Google-Smtp-Source: APXvYqwjyZb5q4hGCc72kYISR9//35pxYSQ3wODP84B2Pme1saxklx9TJbvRmA/oQpNXMF2BoNonPw==
X-Received: by 2002:a63:9e53:: with SMTP id r19mr24453378pgo.442.1561381609752;
        Mon, 24 Jun 2019 06:06:49 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id i3sm9350967pgq.40.2019.06.24.06.06.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 06:06:49 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	ktkhai@virtuozzo.com
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/vmscan: add a new member reclaim_state in struct shrink_control fix
Date: Mon, 24 Jun 2019 21:06:22 +0800
Message-Id: <1561381582-13697-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The earlier commit
"mm/vmscan.c: add a new member reclaim_state in struct shrink_control"
forgot to remove the reclaim_state assignment from __perform_reclaim()
pointed by Kirill.
This patch is to fix it.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/page_alloc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b178f29..3238b96 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4046,7 +4046,6 @@ void fs_reclaim_release(gfp_t gfp_mask)
 __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 					const struct alloc_context *ac)
 {
-	struct reclaim_state reclaim_state;
 	int progress;
 	unsigned int noreclaim_flag;
 	unsigned long pflags;
@@ -4058,13 +4057,10 @@ void fs_reclaim_release(gfp_t gfp_mask)
 	psi_memstall_enter(&pflags);
 	fs_reclaim_acquire(gfp_mask);
 	noreclaim_flag = memalloc_noreclaim_save();
-	reclaim_state.reclaimed_slab = 0;
-	current->reclaim_state = &reclaim_state;
 
 	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
 								ac->nodemask);
 
-	current->reclaim_state = NULL;
 	memalloc_noreclaim_restore(noreclaim_flag);
 	fs_reclaim_release(gfp_mask);
 	psi_memstall_leave(&pflags);
-- 
1.8.3.1

