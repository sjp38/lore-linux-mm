Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EAD1C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:19:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCD3720B1F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:19:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="h8oRe74w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCD3720B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CAC66B0003; Wed, 26 Jun 2019 08:19:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 653D18E0005; Wed, 26 Jun 2019 08:19:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 542748E0002; Wed, 26 Jun 2019 08:19:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7186B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:19:49 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id t11so2619420qtc.9
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:19:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=2Fq0HjbifmsdupktcfAuEl6sSbOWTKpMU8wUfFApIcI=;
        b=n/LKFjEPexskHKqAnRce+LywkjWiB1gJNw/yPg/vZq+THXEEjKw0rG72cTKTreOsVK
         7fqy75/j4vHTAKABif+FIluxPOlenrtiDUWeEjOBcm31McOW685B5aSlc/9JaUuYfKwH
         TuMLrQUBjKrrfGlcFzi5VOKaqS0LQ/oa/OM/hr+WfRJWnce67P++HpnV0fNcY/BqT1an
         y6FY1Fbr2zyRO1edZrJlmBs4IxUCWX7jripbCjsfizC4X3Ke6FKF9YJoynKc8aGCUWK7
         YM+fquIU5eSqHMP5Kr+In/uthiXG5ce8jZNLnj4wLrsE0BHOWMedvfHmZIiefJID0yLC
         JCdA==
X-Gm-Message-State: APjAAAXtjaDTcb6r0PWgyXUlRiJ/ZWO2/I3KyR8YHlSwqHG2FSb2zdnF
	d5EsVnZ8ve6su62Q0btePpC0A1ftW1/PCJnuMeKEzVdCeoc8AwzkuJepKsY87Cok4KTFgMylYjK
	GZdkEBoZ8245gMeGIY4QqTHabXjWMBbnL1kn5qpxMYZtzdef1n0qeKfqKOGmPnuiX0Q==
X-Received: by 2002:aed:3e7c:: with SMTP id m57mr3452769qtf.204.1561551588950;
        Wed, 26 Jun 2019 05:19:48 -0700 (PDT)
X-Received: by 2002:aed:3e7c:: with SMTP id m57mr3452730qtf.204.1561551588444;
        Wed, 26 Jun 2019 05:19:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561551588; cv=none;
        d=google.com; s=arc-20160816;
        b=uVjiQLez+CZvZSjzLGJAt1Wnq1SEklB97U/YRgp77NyN6tDgENdECVn9H8UJA/tDbd
         LGIS5gXSAdVIBm9URAUwmFs4YFSf895GE3+vKO08qVy2AUZbvCwjSi4j15qHQRu5eE8f
         R8CrPe6WEkcwZKIVWts3zpQbVUnQB0HP0zAEGNDIdVhHMx2wLoOgODqfhSIfNx6uMvAc
         owu/aSa5B3Oz/zubbftVcA4SI7jcBjplktWqqlXdUOc2Zq2/c/W/Y4pkuyaOB/xx+ikm
         2tbUlxIfjvfWQYWaolSqutX8aBA83yC6eSM3bhWSM/ptPuc1t9cvPSN2uu7Has8sA4JS
         CNHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=2Fq0HjbifmsdupktcfAuEl6sSbOWTKpMU8wUfFApIcI=;
        b=RstOai1X0fRaBx6r6XSDY3I9U88+BIBu7mEdCof08tezhH2dufLS8LI/ZvpK8LyyEl
         IWbu/esJb/liQzHZ7moil8uAbSmZutMJl6JXSvlAFmomoI6DPLiC0HSp/NjKWxzMTdkZ
         0CFob6h+zmYUsUt9q1pGuK0mP/9i+3Zoh4M3JemPvndKiVKizD5IhFXsK5xV6v5egkj5
         Q/W5QjT3zg3tZrOdrSPwGJUxLMWrSL/cXuDRHh94F4ePZXddAHi9okcty0GBOxJNd9+n
         SaPBJXzmJxAVvdxb/vDm5alvEV3i+riCDssQQfqAFIXVF6b0XmL4Z+QAdnezE7QptHQd
         OHWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h8oRe74w;
       spf=pass (google.com: domain of 342itxqykcoqmrojkxmuumrk.iusrotad-ssqbgiq.uxm@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=342ITXQYKCOQMROJKXMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n24sor15299643qvd.2.2019.06.26.05.19.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 05:19:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of 342itxqykcoqmrojkxmuumrk.iusrotad-ssqbgiq.uxm@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=h8oRe74w;
       spf=pass (google.com: domain of 342itxqykcoqmrojkxmuumrk.iusrotad-ssqbgiq.uxm@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=342ITXQYKCOQMROJKXMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=2Fq0HjbifmsdupktcfAuEl6sSbOWTKpMU8wUfFApIcI=;
        b=h8oRe74wvAhFNxCVSSLhgtaf8DdDRcvv2LUELZFKlhxIfMWHkB06yNG7SNT3CIncbO
         xrYAcYPkEKjnBbVe2WkkxpRSyACn/8q3L802S7S92zdmpj8B19KqEVJcOM2de/TNEknR
         +94Tt3chS1BA9EQxdCUwN45Wrz3UQ2wxYNt9NaVvGQq71AgKto3OiuqHn7RxyjdL02P3
         kTB2Ww3CiDQVdnviX+kBmfbmKcALIJ+dol51U9jzsfedTnn6SYA/TwGSVoVw9zlhWnSb
         4EeKQMkev9uTpqQzluNSwGkO5ukTgZfcxz/SaVb7HtKHx/CIH57gzcebuKUlYjgHmyus
         M3AQ==
X-Google-Smtp-Source: APXvYqwCAtzX9p5b1vV/t1GUdeUyS8l0gHd33EslOH8hxFCkdYOBd6HFsLdwDix1xDg/zZ5Qa9VT7wjTypQ=
X-Received: by 2002:a0c:d249:: with SMTP id o9mr3328284qvh.196.1561551587948;
 Wed, 26 Jun 2019 05:19:47 -0700 (PDT)
Date: Wed, 26 Jun 2019 14:19:41 +0200
Message-Id: <20190626121943.131390-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v8 0/3] add init_on_alloc/init_on_free boot options
From: Alexander Potapenko <glider@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>
Cc: Alexander Potapenko <glider@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Michal Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, Qian Cai <cai@lca.pw>, 
	linux-mm@kvack.org, linux-security-module@vger.kernel.org, 
	kernel-hardening@lists.openwall.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Provide init_on_alloc and init_on_free boot options.

These are aimed at preventing possible information leaks and making the
control-flow bugs that depend on uninitialized values more deterministic.

Enabling either of the options guarantees that the memory returned by the
page allocator and SL[AU]B is initialized with zeroes.
SLOB allocator isn't supported at the moment, as its emulation of kmem
caches complicates handling of SLAB_TYPESAFE_BY_RCU caches correctly.

Enabling init_on_free also guarantees that pages and heap objects are
initialized right after they're freed, so it won't be possible to access
stale data by using a dangling pointer.

As suggested by Michal Hocko, right now we don't let the heap users to
disable initialization for certain allocations. There's not enough
evidence that doing so can speed up real-life cases, and introducing
ways to opt-out may result in things going out of control.

To: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Lameter <cl@linux.com>
To: Kees Cook <keescook@chromium.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: James Morris <jmorris@namei.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Desaulniers <ndesaulniers@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Sandeep Patil <sspatil@android.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Marco Elver <elver@google.com>
Cc: Qian Cai <cai@lca.pw>
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com

Alexander Potapenko (2):
  mm: security: introduce init_on_alloc=1 and init_on_free=1 boot
    options
  mm: init: report memory auto-initialization features at boot time

 .../admin-guide/kernel-parameters.txt         |  9 +++
 drivers/infiniband/core/uverbs_ioctl.c        |  2 +-
 include/linux/mm.h                            | 22 ++++++
 init/main.c                                   | 24 +++++++
 mm/dmapool.c                                  |  4 +-
 mm/page_alloc.c                               | 71 +++++++++++++++++--
 mm/slab.c                                     | 16 ++++-
 mm/slab.h                                     | 19 +++++
 mm/slub.c                                     | 43 +++++++++--
 net/core/sock.c                               |  2 +-
 security/Kconfig.hardening                    | 29 +++++++++
 12 files changed, 204 insertions(+), 19 deletions(-)
---
 v3: dropped __GFP_NO_AUTOINIT patches
 v5: dropped support for SLOB allocator, handle SLAB_TYPESAFE_BY_RCU
 v6: changed wording in boot-time message
 v7: dropped the test_meminit.c patch (picked by Andrew Morton already),
     minor wording changes
 v8: fixes for interoperability with other heap debugging features
-- 
2.22.0.410.gd8fdbe21b5-goog

