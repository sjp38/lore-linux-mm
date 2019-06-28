Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35A21C5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 09:31:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E38A120665
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 09:31:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CR3gJDc6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E38A120665
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B2B96B0003; Fri, 28 Jun 2019 05:31:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7630F8E0003; Fri, 28 Jun 2019 05:31:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 679FC8E0002; Fri, 28 Jun 2019 05:31:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 47FBC6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 05:31:37 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id z42so781726uac.10
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 02:31:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=yltp3Nr5hoDNAZ2OFPn4NI5Rzn3a2yDgIbIXrha4iaM=;
        b=eyn5QL+5upP4lutFA+hEFWHiRcJnFTyc8vWENpTWRY022zzVFH+LT4UPMl7Mi67Yzd
         1BR0TgLi9DHSAERCFgW0R6GF65b6NccJgDsWtn/c04PWz7GvX0WN4WO+jw4Yfw8aSwws
         kOR7DYXJ1k7P1e2OMD56ckcoiPV4DniRCRJPX/4t8s8qyv9qOq0Vk7v8hRl3fRS+KrIc
         007PUkWz86oEhmQ3IPpipsM+jwYIDsYmxas9nD950DfJ8Uf5mf4qoJ+j3b6CsI+WDgVy
         BoCx86+Fi4iBvDro3Am5VxOwezR67w5YlhxjNtVk5JiLwSGn0p7u00EoGb5p1tvO2+E6
         pTSA==
X-Gm-Message-State: APjAAAWrDXxwZ/PSSrCije7YprE5Y1hlKm/DYF7R5dwaRkdy8ahBXTJv
	v2UaBPMJWBzf46yGalP6idOj4heATiDlpWA1vua7FJVVUdj6r8+k55sRsSZU26HSS1vs3pKZSud
	20IXKkzG766k76wK+53R1tOtclwC5MLvTP5ybeFJrRgF3YmIKcU48HtpCu2mnM5PQCA==
X-Received: by 2002:a67:dd0a:: with SMTP id y10mr5092488vsj.93.1561714296921;
        Fri, 28 Jun 2019 02:31:36 -0700 (PDT)
X-Received: by 2002:a67:dd0a:: with SMTP id y10mr5092455vsj.93.1561714296154;
        Fri, 28 Jun 2019 02:31:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561714296; cv=none;
        d=google.com; s=arc-20160816;
        b=Ic2EjQlXlxyeexeu+T6AkoOn0RbIFtYTPvwxe32p9CcMu5pWsQHainGDwaigs4834r
         O5CMugOGzFbroii73IcJw1l94AQVjeF/u7/UpL0cZeuv9/K796NpTE6a8nOSERAtZnxO
         sDjAtntNjYpOPd0ArfhOkYcYCppyI6s1fHPccvkoSMC3uJtChggfldQsI11a+9FaCyPz
         lu0rNNKr7OhaaSA7DwF1okaK5/ta4pmcaAnCX7+G5O+dua2yzlQ8S6MPxAVB+qe9AJNd
         FJ8DU1m0pt3JEkzg59PO1soSxjjgaCFox34LhOdlV6TBnfObsgGbK7HPzXKrF78kZ+aC
         T+aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=yltp3Nr5hoDNAZ2OFPn4NI5Rzn3a2yDgIbIXrha4iaM=;
        b=SlaWB2hgtokoUkBXhQ6J2V73wMJxUgfL3vdjgdmnXObszEU7ibBXXp4z+jCFJ8Xcop
         TAmMWcCQBA2jc9GPWE5CurReA424QAsNuRlwrtFgzeMe/8TJ64AkrIY/Kli2PAM99jBl
         FpaATurz4eV9+H8TkyAOXkFXM/+wLRikwP7UFRs9s814dlfpd9ab/PoWuA6rNHV/hEhT
         MH+qqdZQHxJ6ngnufGd2YsKFzbDitGZzC540QAwlCqx1+qETjIFRfnM1NoUCKscTEtjb
         wPLdTOar8JoIMwzjE0cyxSBc5fUBUvFd6J6b5eR8SUtyGu90JZ8MOwkAiB47ukGFLV1h
         UnrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CR3gJDc6;
       spf=pass (google.com: domain of 3d94vxqykchoejgbcpemmejc.amkjglsv-kkityai.mpe@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3d94VXQYKCHoejgbcpemmejc.amkjglsv-kkitYai.mpe@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j142sor487699vke.43.2019.06.28.02.31.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 02:31:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3d94vxqykchoejgbcpemmejc.amkjglsv-kkityai.mpe@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CR3gJDc6;
       spf=pass (google.com: domain of 3d94vxqykchoejgbcpemmejc.amkjglsv-kkityai.mpe@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3d94VXQYKCHoejgbcpemmejc.amkjglsv-kkitYai.mpe@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=yltp3Nr5hoDNAZ2OFPn4NI5Rzn3a2yDgIbIXrha4iaM=;
        b=CR3gJDc6z07Wkkp9RjMwVFQC4vw0FiFVhhdFCWnKVWL5Udpul5ft0d9yYfYyL0KRwe
         YvRi1l9qjXnTB1P0zT35j66EcCqiwt6K3lfL4hLf0IxNBq2QL1KE2AMHzxaMEf2pgvsa
         571ff3tO8S3tYjKNFZVANKIKaZn9uaXtksbv1SzPsNibM/a44Z0owTk9AjxE3nwh3fF9
         zQk8l8HyUsb1klLlMbqWf3aQOJZep/CGW7FwnLbg6WnsVIJkgt+uSVwepXRg/npeC29A
         uo2u96SMp7B/7q8EsHK9npvcHWfcoiwa2m0AVxrdmIMyzWADc776p/OtlxIbNBF1gmvZ
         ASqA==
X-Google-Smtp-Source: APXvYqzAImN3IyFkxzATucMUrAj64yrEoBQxTycRYblSPKjSiOfq+yF5DcKQlNTMfZ1GTbPhBbh9+vm2v60=
X-Received: by 2002:a1f:728b:: with SMTP id n133mr3319864vkc.84.1561714295487;
 Fri, 28 Jun 2019 02:31:35 -0700 (PDT)
Date: Fri, 28 Jun 2019 11:31:29 +0200
Message-Id: <20190628093131.199499-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v10 0/3] add init_on_alloc/init_on_free boot options
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
 include/linux/mm.h                            | 24 +++++++
 init/main.c                                   | 24 +++++++
 mm/dmapool.c                                  |  4 +-
 mm/page_alloc.c                               | 71 +++++++++++++++++--
 mm/slab.c                                     | 16 ++++-
 mm/slab.h                                     | 20 ++++++
 mm/slub.c                                     | 40 +++++++++--
 net/core/sock.c                               |  2 +-
 security/Kconfig.hardening                    | 29 ++++++++
 11 files changed, 223 insertions(+), 18 deletions(-)
---
 v3: dropped __GFP_NO_AUTOINIT patches
 v5: dropped support for SLOB allocator, handle SLAB_TYPESAFE_BY_RCU
 v6: changed wording in boot-time message
 v7: dropped the test_meminit.c patch (picked by Andrew Morton already),
     minor wording changes
 v8: fixes for interoperability with other heap debugging features
 v9: added support for page/slab poisoning
 v10: changed pr_warn() to pr_info(), added Acked-by: tags
-- 
2.22.0.410.gd8fdbe21b5-goog

