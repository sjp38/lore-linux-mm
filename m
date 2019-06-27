Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0457CC48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:03:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADC3E2053B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:03:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iBxY0ZFg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADC3E2053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46C208E0007; Thu, 27 Jun 2019 09:03:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F64F8E0002; Thu, 27 Jun 2019 09:03:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BE778E0007; Thu, 27 Jun 2019 09:03:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 092258E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:03:25 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g56so2304493qte.4
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:03:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=nkuGlh1b+gHriNiPX/Ra1Bh+mzhPWQ4oquwmkvO30T4=;
        b=e9jkHvzPh5yXvVpGLG+qwwSjCevy6Zg3lCm4tWUe5vZDdJPCMDW3WIiSc7sMoU8/uu
         rW3YOHsZh/Z5lbTvSMsw3M/Pg51mmRojTI5IS4AXw+DBuP2HD+nyTr1S/NGExgHjRyfC
         37zwJYfJ3YAk2vAp65G7TUhYBumvcjtB3FDI8HVxPNH64q0C/KxhP18xZp/bjV35bCpd
         K2QDmZr3uMwLsbu2+mSCdHoYHjOoXIHjipSm99oeY/iSyXKusBEUOw1Owq0o1awBO0Ip
         pY2KvhltQqu6kx/93z8soJE9ND95vkhY+8JXLXBWVWKGAZHGLpU2CzzbCEwQ65mqH/Y+
         0t2g==
X-Gm-Message-State: APjAAAX9RuLE8EYfE9Jw0BwZRQfJI7xndMpD+rrubL4U++4pARSlWNl/
	uCKufWRQw53aeLHlulC9erGI46sYLpOrEuKHtZW/kEKZ5iBAuoZXHU97Dd0zYnuXfeKbjiOLfI6
	FLQkSzbP7tGM8KBDCwHEx10sxvqk0mFylNAR4If53Vi77qAc3L5nSzqGwL09D/ZT+tg==
X-Received: by 2002:a05:6214:3a5:: with SMTP id m5mr3007717qvy.7.1561640604730;
        Thu, 27 Jun 2019 06:03:24 -0700 (PDT)
X-Received: by 2002:a05:6214:3a5:: with SMTP id m5mr3007664qvy.7.1561640604060;
        Thu, 27 Jun 2019 06:03:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561640604; cv=none;
        d=google.com; s=arc-20160816;
        b=s6bwDIGbSvBLARYIv3dsXYLAjAgLqZgkouBqcZq1K06WZEk0xkdEuuP3mydw4lhTwJ
         5DdJo14aPdSBU3sWAPxpLcsUqPojsCvyAN7f0veXjNE9PTFoLsyef88+8AGGoIFGeEik
         ByXuOEIOniAFCEEJbazOJKyNLJc7NKyhOf+Xew3KV9cCMek2wOAY771fXZon9eXLHjNo
         i+FdPcW7N+MHukGf+te8heQW6P78EZX/400TVlfWwPwO3/rIIkMJP6BiWAIUbwdcT9Oy
         lEqL6rS4KcfoEInuS4Qhbzc9ANM4izGAeE3ajE/xYvTkwNfiHUaL1VRMANRIofXD44KX
         3kiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=nkuGlh1b+gHriNiPX/Ra1Bh+mzhPWQ4oquwmkvO30T4=;
        b=oN2NeU+1XxfddlLjIxTjxMkpJ7jHJcsCCIdPLNOIVS3cb6Ff7WInSpHSn23757K9rR
         oIeNPLOIPI41yBQ0l9+YCn6QGGycBog3uStrujt3hgrc/UMhho2ldR0B3HIykDQzcNHZ
         m7Y8uI7xuxo1SBmJO47sLHHy+xskI+GkfLsjxrIPeaRfqBFD4I2BUN18SSiDI7BierI1
         hMDUn4C9ckScqMzngUxrG3vmXEMoZo6NntvXaCjgWVF4gstKmYDnQqKUuGT9CZYe6oO7
         rQO625myK0B+8E/2ABnVgT33TazUvk2sN5YkqMfT1A0buEBoK6LllhTs4ErX2QQDjggZ
         8QAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iBxY0ZFg;
       spf=pass (google.com: domain of 3m74uxqykcfo8da56j8gg8d6.4gedafmp-eecn24c.gj8@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3m74UXQYKCFo8DA56J8GG8D6.4GEDAFMP-EECN24C.GJ8@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y187sor1327860qkc.24.2019.06.27.06.03.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 06:03:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3m74uxqykcfo8da56j8gg8d6.4gedafmp-eecn24c.gj8@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iBxY0ZFg;
       spf=pass (google.com: domain of 3m74uxqykcfo8da56j8gg8d6.4gedafmp-eecn24c.gj8@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3m74UXQYKCFo8DA56J8GG8D6.4GEDAFMP-EECN24C.GJ8@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=nkuGlh1b+gHriNiPX/Ra1Bh+mzhPWQ4oquwmkvO30T4=;
        b=iBxY0ZFgO84nGjeC4loAOGtpGOs9Yd+fQ6I8SutqbHSeU1rnf5JzTtlDWjLJJd0/Nr
         zxHj+IuFkHMyvyWAC33SPbFZGoTK8algV818k/Q71cVpkVHuMBWJKC2ksgxr8pUJEAaP
         dutE+V9ZPEuAoDr2MSkkEBS313KEVD9qNR/3caN6hxA6tFWKop/qr1X7z/Lboo8tZQwW
         I254YFH5T0q6XJAe0Tm+VeVcDZaaB1k/+ZUj+rUz7ui9QpYJ0gGlpps4Mr8zWe3VA6HN
         icTzVRARAhzNdo2Mw8haBEcLFFm82kBhXJPRKv+9+EU9hoEDndfPYq5OKewAgDwKnu5l
         kK2Q==
X-Google-Smtp-Source: APXvYqyb2fwdKxY/0wj7U997eReOnW8Kj1pQxO+Xnu7fYid+NvlrsgBAglMJ1qJ5NwkNSnI/uio1IDG6JGY=
X-Received: by 2002:a05:620a:35e:: with SMTP id t30mr3084826qkm.1.1561640603625;
 Thu, 27 Jun 2019 06:03:23 -0700 (PDT)
Date: Thu, 27 Jun 2019 15:03:14 +0200
Message-Id: <20190627130316.254309-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v9 0/3] add init_on_alloc/init_on_free boot options
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
 mm/slub.c                                     | 41 +++++++++--
 net/core/sock.c                               |  2 +-
 security/Kconfig.hardening                    | 29 ++++++++
 11 files changed, 224 insertions(+), 18 deletions(-)
---
 v3: dropped __GFP_NO_AUTOINIT patches
 v5: dropped support for SLOB allocator, handle SLAB_TYPESAFE_BY_RCU
 v6: changed wording in boot-time message
 v7: dropped the test_meminit.c patch (picked by Andrew Morton already),
     minor wording changes
 v8: fixes for interoperability with other heap debugging features
 v9: added support for page/slab poisoning
-- 
2.22.0.410.gd8fdbe21b5-goog

