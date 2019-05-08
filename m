Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 938B8C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D54220656
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:38:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GFN6F1CF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D54220656
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C2C36B02BC; Wed,  8 May 2019 11:38:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8746C6B02BD; Wed,  8 May 2019 11:38:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78B106B02C0; Wed,  8 May 2019 11:38:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6BD6B02BC
	for <linux-mm@kvack.org>; Wed,  8 May 2019 11:38:10 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t63so22236628qkh.0
        for <linux-mm@kvack.org>; Wed, 08 May 2019 08:38:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=jQTDk5zUQiu0jSAANSS6F2tKehHuyoJNILpoLlCvpOE=;
        b=cX1qJS2z9dMO108ptssXWMPkRsomqTpDvXnh45/ZBgyCKKBqmDm0BqwDRi/y4x5Knq
         Rl8hkliK6ibfcnmChCGVltgviiLvyjQhDSpEVtmaReShzNYHDZGO7wzpQIofW/fkDvBq
         lSYAUAanSxwzEwd+qUCF5+zDwIgheLcOgv4e2uamg18Mu317edNrf51zzc+WJrLHNDY7
         rKRdqPgyFIczVzBGkS+BSxrzZsJi+62b+vEbv4NYb3MQIuyIjiz0c9GtzlmulSIajuwK
         k2JCiVIuXkFaMlOuI0iMOqLs0kl/7KMbxkiwCPdMUE15atlVLHdChfUhWSMIpCvGAE83
         8LCQ==
X-Gm-Message-State: APjAAAVCCdnzogQS0IZ/W7ra4ep+IKUbCvP8JG1sHc5rSwiGmQQUhujB
	zCmHEU1vmBMDmI0VkLt3hY8/0w8YSqAxQVClUGWHrX36Vlf/pszt5A676g2r0DRwqsck+LMz34p
	WiDRxBqOFLLWABWWR9u2aXaJLA5HyafiRMlQdPqdI6nrDGM1LUy0Krd3EYiuOh1Jnhw==
X-Received: by 2002:ac8:6a14:: with SMTP id t20mr6286923qtr.66.1557329890040;
        Wed, 08 May 2019 08:38:10 -0700 (PDT)
X-Received: by 2002:ac8:6a14:: with SMTP id t20mr6286867qtr.66.1557329889276;
        Wed, 08 May 2019 08:38:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557329889; cv=none;
        d=google.com; s=arc-20160816;
        b=DgWneErgTe+tMpBw0SHtQOPz48nf6dbamJxD6W6Q4ZYtRVpcGgFDgZAjdyCm1ftssF
         5+XFjOEBlu+L0u61SQjve92XVzlJHP+lVYlwINVL4pK8uHhlpPLOBHGUA0neDsNzjqAe
         ulEI6J1g7gT2jGtfuAk1qNBS12L7Rhkd9ljVDyRllSwZYP9gCBQZ6hqnudnDNpJ3qFSg
         Tpy8jBFSIkBw+gOUg4AXTqR7qE24dBFWT08pHy2woGNT29rsIjdDa0GiiUw46pFM8b0j
         2Gres/MGjiV0pVCuPz+sw6lLMLOwI1vLQfV2FTf3rhzgB5wLCQF6UX319AD3+jAKNEvT
         Hc7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=jQTDk5zUQiu0jSAANSS6F2tKehHuyoJNILpoLlCvpOE=;
        b=nIL/MgjZC1PTci1O3WFEeiqF6sbQ0jl1JamMJUtrw4FGDdh95Zm7mVwSRpt0oOnxKG
         iAgg1yUgc9d2C4bXH+GVr5ZvAgHG5quer+gBTabhZWT0+4/FE13omqPeWw7lxuzxoPx0
         G870NMWPX7j9XP9qdF4sFDisuak+eRHizclCnTtpu9qasiqxRfntXPGRreomEgPCHyY0
         USCddcAoanyIiTM8XqDaf+etkqLsG3GAVCcgb+x97+tBeGsktW5aVE2S9D6m5WU+731u
         oSwJBaPWrvHJxfT+4gFm9u5HDqF/v4QeNglqc/rASA2RlWIWdv19zOX82szNxo47PV9B
         R4gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GFN6F1CF;
       spf=pass (google.com: domain of 34pfsxaykcakpurmn0pxxpun.lxvurw36-vvt4jlt.x0p@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34PfSXAYKCAkpurmn0pxxpun.lxvurw36-vvt4jlt.x0p@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d5sor23007495qtj.36.2019.05.08.08.38.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 08:38:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of 34pfsxaykcakpurmn0pxxpun.lxvurw36-vvt4jlt.x0p@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GFN6F1CF;
       spf=pass (google.com: domain of 34pfsxaykcakpurmn0pxxpun.lxvurw36-vvt4jlt.x0p@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34PfSXAYKCAkpurmn0pxxpun.lxvurw36-vvt4jlt.x0p@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=jQTDk5zUQiu0jSAANSS6F2tKehHuyoJNILpoLlCvpOE=;
        b=GFN6F1CFAn8rem5iUDqLjf1tfi+RrhFiRNeh/0F2po0axneRlVapHhrppUL/61zKqa
         fqziisUOusgcNBy3YbprB/0BuVtDJreqKdohUPF1WERb9r4bJ3xZCcu4ADVbVfVB6f31
         F84NdwY+v3XeVNLpl7AvM3G0VguBxS7GRXu8APDPhsMHavQ2PJ8+w+3zWDJS+PLRRpI7
         MxxjitSgkHRhSyhrDMur3ihTXAk0Ftgs1r521FXCwSoQzNtSD2nAihFYWbdWXr7fx4yF
         Imhr3H9U682NR/6wHUZ2sy0nXTUp9qrTit0Sb4OCZM0m8HJEcpSQjyQYjKYB1xsIZJFE
         IfCg==
X-Google-Smtp-Source: APXvYqwB6BG1aUc84ClZ+1GOpENtD9vu+DWDbF6HSE0y1Oiy+N+VdKRxD9HjOVUJUdCXtfed6Q5q6eop53c=
X-Received: by 2002:ac8:3fe3:: with SMTP id v32mr31243311qtk.307.1557329888814;
 Wed, 08 May 2019 08:38:08 -0700 (PDT)
Date: Wed,  8 May 2019 17:37:32 +0200
Message-Id: <20190508153736.256401-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH 0/4] RFC: add init_on_alloc/init_on_free boot options
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org, 
	labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org, 
	kernel-hardening@lists.openwall.com, yamada.masahiro@socionext.com, 
	jmorris@namei.org, serge@hallyn.com, ndesaulniers@google.com, kcc@google.com, 
	dvyukov@google.com, sspatil@android.com, rdunlap@infradead.org, 
	jannh@google.com, mark.rutland@arm.com
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
page allocator and SL[AOU]B is initialized with zeroes.

Enabling init_on_free also guarantees that pages and heap objects are
initialized right after they're freed, so it won't be possible to access
stale data by using a dangling pointer.

Alexander Potapenko (4):
  mm: security: introduce init_on_alloc=1 and init_on_free=1 boot
    options
  lib: introduce test_meminit module
  gfp: mm: introduce __GFP_NOINIT
  net: apply __GFP_NOINIT to AF_UNIX sk_buff allocations

 .../admin-guide/kernel-parameters.txt         |   8 +
 drivers/infiniband/core/uverbs_ioctl.c        |   2 +-
 include/linux/gfp.h                           |   6 +-
 include/linux/mm.h                            |  22 ++
 include/net/sock.h                            |   5 +
 kernel/kexec_core.c                           |   4 +-
 lib/Kconfig.debug                             |   8 +
 lib/Makefile                                  |   1 +
 lib/test_meminit.c                            | 205 ++++++++++++++++++
 mm/dmapool.c                                  |   2 +-
 mm/page_alloc.c                               |  62 +++++-
 mm/slab.c                                     |  18 +-
 mm/slab.h                                     |  16 ++
 mm/slob.c                                     |  23 +-
 mm/slub.c                                     |  28 ++-
 net/core/sock.c                               |  31 ++-
 net/unix/af_unix.c                            |  13 +-
 security/Kconfig.hardening                    |  16 ++
 18 files changed, 439 insertions(+), 31 deletions(-)
 create mode 100644 lib/test_meminit.c

-- 
2.21.0.1020.gf2820cf01a-goog

