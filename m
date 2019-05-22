Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02709C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:09:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B995B20879
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:09:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iLgVs9bc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B995B20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B48B26B0007; Wed, 22 May 2019 11:09:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD2446B0008; Wed, 22 May 2019 11:09:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 973156B000A; Wed, 22 May 2019 11:09:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3078F6B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:09:55 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id t13so510641lfq.8
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:09:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=XfLoVJNG3YH3XU12QY7rmjEpG+NwOFxkxi1NTXn+kzk=;
        b=ICVBNSgYEnZ0+afROBCRYeSUSmcfWWON1uLfMV4yULBUpvUH1Wd9lrFQvxEjOsdmT6
         zvSt52BOC/RCmDhdEaEHPeyyPfF2Noo4rG8k/VsTSNiaePy+lY+ooF8SA+L89xivlTfk
         h+pcIMeXldsQTttNoyQ9QydujZQiqwS1rXn8bAmQioc3/liuMaxA8Oxm/enves44R7nL
         bCHPwKLYOgLvrZRZt9M55X8zrwZ9yIvtlKwXA8F0/cY12jlKe4jwDbYOs4+0Caz/Yefl
         dFuDgCussrM8nyHPKRLIEOOnXord3HBGkESga40GldLZSszZHub17MI4sx5Epzqqa5mK
         e8ng==
X-Gm-Message-State: APjAAAXWy3JRfVbqS7RDHQZq//ZSoN7P9KeoudjDtH1Kkcd/OrwL7eHj
	trYpjZoHdvZHyLULhDY+30Mnyur0LeolaQlV6kEN+MLrI7o24p6tBOSUgRLxMA8p0q+jEeCpdXe
	AVC9dW81iZC1NwiIkKjXRkbHxYYgY92q9Oci5zSfNMHxFI08fiAcXp28l9glWHaAQlA==
X-Received: by 2002:a2e:85d1:: with SMTP id h17mr29509610ljj.1.1558537794658;
        Wed, 22 May 2019 08:09:54 -0700 (PDT)
X-Received: by 2002:a2e:85d1:: with SMTP id h17mr29509564ljj.1.1558537793640;
        Wed, 22 May 2019 08:09:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558537793; cv=none;
        d=google.com; s=arc-20160816;
        b=eLnWOot6rzX+RbJezEoBML0whcsajeefAHuqOXWU/lqpvAGzzCK48WlhRGEoVIzfEs
         3wBEO9fCvsWJo52UJRI21e+r6JM5JydNk5rYuVWlFZQFQan1JtPzZWDQ8pIdyLNB4T4P
         M41Qsf7VCB2N/dm2TGJnkUVFE9CIzNlr7jt5QmNadUZ8p2uz3Shu29RCdvKylmcrxWKJ
         I+df3qcSJ+dQn9CSuN4MEVYAUCEYKfI/83pc7qHBmAu55yB5KcSosRxgbLfaeu5jSLQ1
         6/TLeNRKH5gkJf3Iuum1/IxM5Zfc1lTf9B5wDn7wYsNsSejatjFt+/Ovo/uyHoMyBsEB
         j64g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=XfLoVJNG3YH3XU12QY7rmjEpG+NwOFxkxi1NTXn+kzk=;
        b=GYfrRHkDQjDzqnMtQX6hn4S6j1J4p3kWopG4R9WZWmNy8BWrJjwjm9WpWiPdoqK+4p
         4fnyEjCpHG6dJYIOGpeJN+xyg83k9AE4UxxgtSDi1wfV/RrP9n1wAYHzVZfIigqId50y
         ANT2wFekal6o/E7afkiJZf/gjeKBC3ig1KcdFXCZ1Y1sSjcfP/6ZE1KKGsPGxnXorB0c
         qLfxtfxHGXNWWmYkLmrDcM+6LC/7B19/JQy9lZAwo1Xmr7ibSjizzbK7hCya26RXcW+c
         LM/XzY1YMz0845D2dR/8wUKbmBtrDu4PUnyKuCDNbhrlS6RmhIKRPzvyzQASAjy0UkCJ
         t+TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iLgVs9bc;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w10sor6913755lfn.19.2019.05.22.08.09.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 08:09:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iLgVs9bc;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=XfLoVJNG3YH3XU12QY7rmjEpG+NwOFxkxi1NTXn+kzk=;
        b=iLgVs9bciGGSfNr7lnaGuHN02LQSefOJFB8jCzlazwdjUT9zwD+9AiHD7mJH+QgV98
         cgQi9kr2nQ2QSQGNirYGrvhwR5h1gGIjtJR3DfVwa61umhpH3Ef94m4SUmibVYaMECiz
         /F0K3Nj4OGjsuwFwPuGP0eMwTTre0PJrjW0GQB/NCao8IOA7XNg1vXoyyGLOmkBe+aKs
         F1M/zzYr0TP7k7R33Weoc4rYMBBm+pD3GczPbmGPhLn+g4mBM+UAfGeYRGKAyQg8nXG8
         gl25OHegvI+FFXUwNoQTVY9rlqo+XeEykTmOAu97rVBqmr76OxM1M8IzK2DDEn/ITVkC
         sQAQ==
X-Google-Smtp-Source: APXvYqyBoI7CHTOcBFOL7JPrYQSLJpWeJrCJebZpJdPWf/kriTBhBeULhSVwcS66AnUqV8yAuvhRlQ==
X-Received: by 2002:ac2:4471:: with SMTP id y17mr17527691lfl.23.1558537793265;
        Wed, 22 May 2019 08:09:53 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id t22sm5303615lje.58.2019.05.22.08.09.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 08:09:52 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/4] mm/vmap: get rid of one single unlink_va() when merge
Date: Wed, 22 May 2019 17:09:38 +0200
Message-Id: <20190522150939.24605-3-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190522150939.24605-1-urezki@gmail.com>
References: <20190522150939.24605-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It does not make sense to try to "unlink" the node that is
definitely not linked with a list nor tree. On the first
merge step VA just points to the previously disconnected
busy area.

On the second step, check if the node has been merged and do
"unlink" if so, because now it points to an object that must
be linked.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 5302e1b79c7b..89b8f44e8837 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -718,9 +718,6 @@ merge_or_add_vmap_area(struct vmap_area *va,
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
 
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
-
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
 
@@ -745,12 +742,12 @@ merge_or_add_vmap_area(struct vmap_area *va,
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
 
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
+			/* Remove this VA, if it has been merged. */
+			if (merged)
+				unlink_va(va, root);
 
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
-
 			return;
 		}
 	}
-- 
2.11.0

