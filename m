Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E8FBC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FCFD218E2
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:00:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ecNB/AWi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FCFD218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9271E8E0174; Mon, 11 Feb 2019 17:00:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B0C08E0165; Mon, 11 Feb 2019 17:00:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7754A8E0174; Mon, 11 Feb 2019 17:00:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 254208E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:00:08 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w12so155853wru.20
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:00:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=btZJYBzt9vwgeXYpITL7uF1uBvgohSdy08HPUQnLqO0=;
        b=YQN7qKDvv7DIz3ry5aoI+24b+Nqpm585ai/IWTLjjm+bC/JgY7tLM726RKrD3aZymP
         qSSKeSuZ066ietO4t8xkbUWlFWETYjS+qL47sVK5QnBvb6vMpw0JFDdiGJbJh9thFe+s
         xJabLmvWtzMLDQFxms8SxqWyLGy7CqL/MdcvmJk/FvEq6cjW/nIP1kXnwhJRvdI19O4p
         T1L8G8iRGD2n6oPFB7p5RG4ph202yaWO1sNoOv0val9AbAwOtlw6NrfpVHXNxvxPA+zp
         3pM+TyDMa63TdnnPPKvdmXOyAhwp4KWdh3rAvXbDFfs2WnvEYvsgMBL0KA6Y/3rtuRno
         l+PQ==
X-Gm-Message-State: AHQUAuYBRoxtQoV2wjS05kP5j8LKxnqV3yJ72DOIqn+JSiO1WB3Ap+wj
	cfFmtPT3XLlVs4PMStxvc3ADtmBJkFKFcYuu7+HELruF5uPpy7xV0CawgDAXOG2GZ4dxl4A3psW
	8+gYBdjTWdQHExWaFKWEQ/N5SmOdTYFAPAknuPMV7C/nkajxfkOH215g9PoUYVbmZOe/bs5SE+2
	Mdx+ItEoNeXQg7i4/Hws1wANfqPy1YjHMPwfqjbuOZwbqoumj6vnhDm+/KKsi7hV2pWW3jqWPR6
	v6gwHVVICRA5FOGyzOf3F7BRnK3e8eJbqQwl+reWKQDnt8Bb60hSZGZTWbf4OwsS6FIdiDIToD2
	PHxaX5pfl6giFIHIgdWgHROV3TiUEoX904GCR9q53p1a5R6NRTqzSiV2++UT8c0lNrqluI9W1H/
	R
X-Received: by 2002:a1c:f901:: with SMTP id x1mr291400wmh.84.1549922407654;
        Mon, 11 Feb 2019 14:00:07 -0800 (PST)
X-Received: by 2002:a1c:f901:: with SMTP id x1mr291363wmh.84.1549922406794;
        Mon, 11 Feb 2019 14:00:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549922406; cv=none;
        d=google.com; s=arc-20160816;
        b=javh8aszhqXsWKu30pNVq/rYx25F6SWQS2gPg6oerJ2AiKl+IR3wT1yIXgqBpAUjLz
         8SzhaDjV5Z8KCwx5Bx/KiHMTRFnAwLlkZYL2ubiMpwXuNJpKyfSJr25N9PMprY4zTmS8
         xEYRLoydAxXcHr7rgw31Wx/exMNk/0Q8Orh6IgRstFiTTa4hszEpGCuv9q7f2kiHSRNr
         UuWU+TYO0dTra1uRKW0y2obMBfX3Tq+SIVZsFcluR37GhqSjxCUV743rxzLM9P+9NgmF
         WlPVSFj0tw06b4myhtv3Y2DibjituRTsgAQvb1UMmXEORayCsmuvZUbpj7sfc+hLvpVj
         Qenw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=btZJYBzt9vwgeXYpITL7uF1uBvgohSdy08HPUQnLqO0=;
        b=YYep6rtb40rDVECY9vtrhsPeUfnwUAK3NIyGgpBs8QBMp39i8di8UE7fqwcL4U85sL
         bSQA37TufRGyF/SILUGKC3Sqp3witcnTGwRF8IdD8O8Pibf4YjFJjkOoKcY0LfGdOtCc
         FVunbpQUdJ3h9oWz0QDvRao7Mr4DigAc1zSKxqlVOXeRs2/Z1EfcO62uM62w61F5GSEo
         zKLvniIMLoqHu0Yvx/uu7Hm339LnrdOhNFqBikucd1ZoiLkgQ8zHBxymAZOnYo76NXJ5
         eekEGz8C3YEDhlyA+PuTGq+pYRKPzf30BLtP6ZfM77UvOat241Cg6hPTDikOanDLOYWS
         SITQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ecNB/AWi";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c190sor361966wma.21.2019.02.11.14.00.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:00:06 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ecNB/AWi";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=btZJYBzt9vwgeXYpITL7uF1uBvgohSdy08HPUQnLqO0=;
        b=ecNB/AWi4z4l8AQ/we8wnm6SjWCcMGvpTpyc2v3pJeyC298tLkxxD+qZ+Dc4FG3rj9
         Is7o1YdjBZrw6wO7CC7sUPKmkF79J3SHPlM3cJuQIw3hapgPTfRqb3QmGNoHjpGNjd2a
         E5VB0Rr0IZCVZaefBRWqvksJUlJXSXnPTRrusgyT3iE0cM+0VImSK8Lo0JsnRB3OamDC
         DDWqXeWHiRXE+x+w+BJtw0Q7swK1uB+cQ0Z7KgYBnMNv8POPkCjGRZ7w+YzkfIllkThW
         hppiMFeEeGWSNvgHGToS/XafOlG4jTCytop5hi0mhlxw4WfxKE/YotFjBPiUY7IJJiXe
         2DlQ==
X-Google-Smtp-Source: AHgI3Ibt/OjbLqwefA76DBGGG/kA1FhuGgmWovyjKZmYdbeOvuJB1FGXQZ8bX9M3I7w4XDLhekXwKw==
X-Received: by 2002:a1c:ce8a:: with SMTP id e132mr302513wmg.12.1549922406276;
        Mon, 11 Feb 2019 14:00:06 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id c186sm762685wmf.34.2019.02.11.14.00.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:00:05 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 4/5] kasan, slub: move kasan_poison_slab hook before page_address
Date: Mon, 11 Feb 2019 22:59:53 +0100
Message-Id: <cd895d627465a3f1c712647072d17f10883be2a1.1549921721.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
In-Reply-To: <cover.1549921721.git.andreyknvl@google.com>
References: <cover.1549921721.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With tag based KASAN page_address() looks at the page flags to see
whether the resulting pointer needs to have a tag set. Since we don't
want to set a tag when page_address() is called on SLAB pages, we call
page_kasan_tag_reset() in kasan_poison_slab(). However in allocate_slab()
page_address() is called before kasan_poison_slab(). Fix it by changing
the order.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slub.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 4a3d7686902f..ce874a5c9ee7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1642,12 +1642,15 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (page_is_pfmemalloc(page))
 		SetPageSlabPfmemalloc(page);
 
+	kasan_poison_slab(page);
+
 	start = page_address(page);
 
-	if (unlikely(s->flags & SLAB_POISON))
+	if (unlikely(s->flags & SLAB_POISON)) {
+		metadata_access_enable();
 		memset(start, POISON_INUSE, PAGE_SIZE << order);
-
-	kasan_poison_slab(page);
+		metadata_access_disable();
+	}
 
 	shuffle = shuffle_freelist(s, page);
 
-- 
2.20.1.791.gb4d0f1c61a-goog

