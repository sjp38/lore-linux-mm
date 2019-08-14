Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C3D0C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05EB52084F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="B5pmU59y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05EB52084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B1676B0008; Wed, 14 Aug 2019 16:20:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 962C26B000A; Wed, 14 Aug 2019 16:20:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84FCE6B000C; Wed, 14 Aug 2019 16:20:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 6202C6B0008
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:20:37 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 177868248AA2
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:37 +0000 (UTC)
X-FDA: 75822151314.03.jail72_54dfd65e6a51
X-HE-Tag: jail72_54dfd65e6a51
X-Filterd-Recvd-Size: 5707
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:36 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id w5so348513edl.8
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:20:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NGoYUnhBV7TeB+3l4wceLC9ZPh9ISIJNJOmyRzHIbHM=;
        b=B5pmU59ycnYBpryQhhG1Z3DbeM8Nqe5M8v1SwTte2yz8M8LB54A/UjWXYoWpYTn2Uv
         5wXLGfAUtYZN5x4CsUBfceRVwXq/4IjhgUmLTFyUKguhiSbuw71qyrATlnjMjT5+NMfu
         Y1nD5IwF07+NuCcwz0U1msvMGB0mJkgxThOFM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=NGoYUnhBV7TeB+3l4wceLC9ZPh9ISIJNJOmyRzHIbHM=;
        b=E+EXNXNackfES+SAnfMDRuOBA2XFFRc/aLranGNQdUPI2k7py4ZqEebF1Z8OgaSRcG
         jRauxy8o+zP0Q+6O+o9dJnzOIW0OaNB7SaLajpO/q+fJML0F7yX6dEVfCpsm087p8w6L
         gq6nPQgta/HudU7I8E0X0KCJbt0Rlmth1K51SBkKb0Jk2O8Cx0sF+y3Ib3GnBJVhOry7
         dqsoRhjoiS7z0a39Gz1leeuCrDkuzBYQL5bQLNdPbqUIasNBRZpvo1zWQe+QtK2O5BxC
         q+s6UJOpusQ4XfXA5Pa8iibPpxU9l74320v8iiXBNGaGNn0wF8irRy2Wprbaxts3N+qU
         dXTA==
X-Gm-Message-State: APjAAAVP+XBYLbcjrYJlBeGWolqc9/vzDBAESXr8JE0+VKOzgIt0MgPZ
	HawN8c2k5ggyEYNK4ZnmftxC8A==
X-Google-Smtp-Source: APXvYqwaJ7x0tLnRLHwbItm2wgIoNWmNw2/2hrhii9cO7U6X/gWZx95a1UP7+c/DHPfmXSg1sNEoMQ==
X-Received: by 2002:a17:906:1e85:: with SMTP id e5mr1324797ejj.200.1565814035124;
        Wed, 14 Aug 2019 13:20:35 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id ns22sm84342ejb.9.2019.08.14.13.20.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 13:20:34 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	David Rientjes <rientjes@google.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 1/5] mm: Check if mmu notifier callbacks are allowed to fail
Date: Wed, 14 Aug 2019 22:20:23 +0200
Message-Id: <20190814202027.18735-2-daniel.vetter@ffwll.ch>
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

Just a bit of paranoia, since if we start pushing this deep into
callchains it's hard to spot all places where an mmu notifier
implementation might fail when it's not allowed to.

Inspired by some confusion we had discussing i915 mmu notifiers and
whether we could use the newly-introduced return value to handle some
corner cases. Until we realized that these are only for when a task
has been killed by the oom reaper.

An alternative approach would be to split the callback into two
versions, one with the int return value, and the other with void
return value like in older kernels. But that's a lot more churn for
fairly little gain I think.

Summary from the m-l discussion on why we want something at warning
level: This allows automated tooling in CI to catch bugs without
humans having to look at everything. If we just upgrade the existing
pr_info to a pr_warn, then we'll have false positives. And as-is, no
one will ever spot the problem since it's lost in the massive amounts
of overall dmesg noise.

v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
the problematic case (Michal Hocko).

v3: Rebase on top of Glisse's arg rework.

v4: More rebase on top of Glisse reworking everything.

v5: Fixup rebase damage and also catch failures !=3D EAGAIN for
!blockable (Jason). Also go back to WARN_ON as requested by Jason, so
automatic checkers can easily catch bugs by setting panic_on_warn.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 mm/mmu_notifier.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index b5670620aea0..16f1cbc775d0 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -179,6 +179,8 @@ int __mmu_notifier_invalidate_range_start(struct mmu_=
notifier_range *range)
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 					mn->ops->invalidate_range_start, _ret,
 					!mmu_notifier_range_blockable(range) ? "non-" : "");
+				WARN_ON(mmu_notifier_range_blockable(range) ||
+					ret !=3D -EAGAIN);
 				ret =3D _ret;
 			}
 		}
--=20
2.22.0


