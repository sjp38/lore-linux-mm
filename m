Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A71B6C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6785621721
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="QQneGltV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6785621721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2F306B000C; Wed, 14 Aug 2019 16:20:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE3C26B000D; Wed, 14 Aug 2019 16:20:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0C3C6B000E; Wed, 14 Aug 2019 16:20:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0123.hostedemail.com [216.40.44.123])
	by kanga.kvack.org (Postfix) with ESMTP id ACCA86B000C
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:20:39 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4EE108248AA2
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:39 +0000 (UTC)
X-FDA: 75822151398.09.title90_5ab9c4cd444b
X-HE-Tag: title90_5ab9c4cd444b
X-Filterd-Recvd-Size: 5196
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:38 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id w5so348602edl.8
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:20:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dDjwUmcwSXAq578UY4c9Vj0FS6SCgLfjeiZG1PLwBhc=;
        b=QQneGltVZyDVKndymgf/V07Lz/mVu4xKZlufq/IsuBlC5+1QN4bp7NWpobW8CC1rIF
         qIF8ZHgfa3ZzNQCa9U+7EASFdi6fg9QrXsipXLij2jwCn91t6FCHDSnO4dCluu2ktfVm
         26tp0nC+Bvb3QHNr2PBbwL8HmhMnTo4N7ChVI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=dDjwUmcwSXAq578UY4c9Vj0FS6SCgLfjeiZG1PLwBhc=;
        b=sJwI9UMgia/djXr29jFZk1hQpBgG0AEqTsm0JkzBBGimTDDK0053h/LxOVr5WT9PFr
         ILa9zta6MkX/FEb9QOCVb6aF935YScHPqap2VN9G8sG6Sp/cz90syc4pBEoJezG3VeCD
         s+0TDwULKGbsCHAlngeeGhCfVU14EtQPmXo6vm1oAXV/giX6tnqvnoAf/Cgmf9HGN26z
         AbnlUsWPMQkR+0yLPJQaJoPna8MbFDw+lRjq2GlZ2oGAqvMcX8B3fMs7GzL4bdsYBw28
         QJmYEK7sX8Q0RJpCgeVMxc1nBp1LQcR+NvWlMS60+oLxH/rS8bG4BkXn8BgL99JxrI5g
         mbyQ==
X-Gm-Message-State: APjAAAXk8VCqirl6ZWXTKd5g0rGKT30CHMaxcRS8zk3+/GktwI6QLPmA
	smyeT6FMp5AZRmno/Q+r56RlrA==
X-Google-Smtp-Source: APXvYqzQoXvD/5/BVfPi68WzUkMpSm1CHWB0tkEH2JnEfPgw2NOD1Bv5GUgUamH3qvvNe7OEQP+Ihw==
X-Received: by 2002:a17:906:81cb:: with SMTP id e11mr1305807ejx.37.1565814037763;
        Wed, 14 Aug 2019 13:20:37 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id ns22sm84342ejb.9.2019.08.14.13.20.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 13:20:37 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 3/5] mm, notifier: Catch sleeping/blocking for !blockable
Date: Wed, 14 Aug 2019 22:20:25 +0200
Message-Id: <20190814202027.18735-4-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We need to make sure implementations don't cheat and don't have a
possible schedule/blocking point deeply burried where review can't
catch it.

I'm not sure whether this is the best way to make sure all the
might_sleep() callsites trigger, and it's a bit ugly in the code flow.
But it gets the job done.

Inspired by an i915 patch series which did exactly that, because the
rules haven't been entirely clear to us.

v2: Use the shiny new non_block_start/end annotations instead of
abusing preempt_disable/enable.

v3: Rebase on top of Glisse's arg rework.

v4: Rebase on top of more Glisse rework.

Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Reviewed-by: Christian K=C3=B6nig <christian.koenig@amd.com>
Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 mm/mmu_notifier.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 16f1cbc775d0..43a76d030164 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -174,7 +174,13 @@ int __mmu_notifier_invalidate_range_start(struct mmu=
_notifier_range *range)
 	id =3D srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) =
{
 		if (mn->ops->invalidate_range_start) {
-			int _ret =3D mn->ops->invalidate_range_start(mn, range);
+			int _ret;
+
+			if (!mmu_notifier_range_blockable(range))
+				non_block_start();
+			_ret =3D mn->ops->invalidate_range_start(mn, range);
+			if (!mmu_notifier_range_blockable(range))
+				non_block_end();
 			if (_ret) {
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 					mn->ops->invalidate_range_start, _ret,
--=20
2.22.0


