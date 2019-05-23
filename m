Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C0BFC282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:42:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0A2621019
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 12:42:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ertiE0SB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0A2621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D4EA6B0005; Thu, 23 May 2019 08:42:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35C926B0006; Thu, 23 May 2019 08:42:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 225506B0007; Thu, 23 May 2019 08:42:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id F06076B0005
	for <linux-mm@kvack.org>; Thu, 23 May 2019 08:42:25 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 83so5055866ybo.11
        for <linux-mm@kvack.org>; Thu, 23 May 2019 05:42:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=JQ1oCxUU1IPVRVLwTDKqVi9a5cWuQ5HVxcskTOhO4aM=;
        b=sENY8BlgenMFMGEuL8E/2Srd9YnIEF/Xs50+Sj02WDV842V4DbejEv0LtsnRNEsPGj
         OVyOr273a8MJB8exo4kSCU/otqVNlHxK+vfO1izeLvgYmOm5gGXh24rOMySxrEaAJxtn
         aBZnGB4mL99bs5lbrODNCsqnxnZO2JrrSD0ZCOZjaOm6q6PuOzxiv/QaxNP8Jm/saIlq
         K2wnm68Qm+Q9M9+mcsTLheQqgRCsh7KJV4TP3sWEx0I4iKudOdopUDufVXuATmoRsR+q
         TFAyGTCNydRL2BEj2CBETWY1MYlVbwJBjyZNB7mPpOZftyxgQF8+gVZVA8RsDu5drcpU
         7iOw==
X-Gm-Message-State: APjAAAUPL4jSJEgWXcOLgv3782xPcTMC1MPn5JvELEBM9V/GucSiJLqY
	B91XPxOPngya7bLBD+tzcAayLdbUqiLSof2xc1kYG6X1Z0rOJqv3KRXzGuE0/5BzcfCUg5Qpciv
	eWzQ/V0AC3U+B9W5D27m0B0JY72MhFGBexIgVhpQobp0KMVuEaoekNBkwco/APnczSQ==
X-Received: by 2002:a25:a28b:: with SMTP id c11mr18735405ybi.224.1558615345607;
        Thu, 23 May 2019 05:42:25 -0700 (PDT)
X-Received: by 2002:a25:a28b:: with SMTP id c11mr18735372ybi.224.1558615344933;
        Thu, 23 May 2019 05:42:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558615344; cv=none;
        d=google.com; s=arc-20160816;
        b=HdI46M40XHJS6XYgoffcrpIH3EpyTrNQNJoVVhIB7+CYvQGcZZP6NwXnF+8YBGC672
         0NIvDSB/o8sbNrCGJIrXiSB49L0pvtN5ik50AAH5uE4y0qa+PykxzTPJypYiVtMnW+NG
         z1t5AF0MHXdTlqmwyyj80w/6Fc4YJNt3PS+Jg0Ce8SvAqOs5lQwutPjF6EmHTZXncQQ2
         oDwW4WZjXprORWdhZVITsMRB+c3OIri57SvelqOB4JOAbmnpsmMTSwP80q1Qrhhm+AbB
         3vLAiPOi8MF5lc+oWkRwh+WRTh6uUptYiY4SJa1Yp5p+OSpIUaOBBy2WwC82FlQqzukj
         f6Mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=JQ1oCxUU1IPVRVLwTDKqVi9a5cWuQ5HVxcskTOhO4aM=;
        b=xpbn4eZAHS/sIaA5Luq2QdFGpdbAJamipiMKm+MCHu3854m0EUX/VAPiAQaHqnGp2P
         SD3v36Yp/WQ5qYuA9tHCIk7rd3K2wIH8nUxwV583TEOwHWllh44r1FkI7crXv4kxhqli
         t75wXVhKr9xflHUWxBuMx7UiPZZyWoKCSQ7EbQorlj2clKor4VaGSzGDgrHOQjyJZxzU
         WSmvf0NzRpH+YuZ9tIXQy5GediUq//FuOhjkqYeWxnkCisljLwYjAOVW0LYFOwDlamet
         iDFeVfrMTPDtOcoVX7B5nm2rMfxf2m1OcqVcwTykxDwihUbZ/TnzfKmvxlICmCNuuogj
         YY0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ertiE0SB;
       spf=pass (google.com: domain of 3mjxmxaykcoejolghujrrjoh.frpolqxa-ppnydfn.ruj@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3MJXmXAYKCOEJOLGHUJRRJOH.FRPOLQXa-PPNYDFN.RUJ@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e19sor9694445ywe.90.2019.05.23.05.42.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 05:42:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3mjxmxaykcoejolghujrrjoh.frpolqxa-ppnydfn.ruj@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ertiE0SB;
       spf=pass (google.com: domain of 3mjxmxaykcoejolghujrrjoh.frpolqxa-ppnydfn.ruj@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3MJXmXAYKCOEJOLGHUJRRJOH.FRPOLQXa-PPNYDFN.RUJ@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=JQ1oCxUU1IPVRVLwTDKqVi9a5cWuQ5HVxcskTOhO4aM=;
        b=ertiE0SB+mfT4MEk0SFpNz/YKadHtLe1893I517U4tFeM8uM4swKr9G/SikceY0rCZ
         UDv4kifx0Bx26JjS24LlGhSYfY5dn5hLUvIS+argIdWCUpj1zPlvl2vgcVT7VlYsMIBc
         TbZHChjMXWT1nZTF2UxhG3QQeuTGjHcBqomUaPOhXB56N+mygLlEEWcHWhxicHOP9S1B
         5KxHPYzkoVGX7YeFgoThDuFVkgEJqn+ZZYDjNKrKzE9PsO+fkj2QIaVmmjg9RyHD6UE+
         GLNEbVFhskq2fbM3GBHi68kjqbHgC7bL3loysl7MiurRFJlygTNNkqpkXQbKQ7K1eIxr
         EB9A==
X-Google-Smtp-Source: APXvYqybh08sHeGZRRlBZ+rEKGpK9UKViuwmqgzYonb7VhrGAa6y78I0qkN7CYW3hhy3qjCkZr902YQaq1s=
X-Received: by 2002:a81:5987:: with SMTP id n129mr46582349ywb.193.1558615344476;
 Thu, 23 May 2019 05:42:24 -0700 (PDT)
Date: Thu, 23 May 2019 14:42:13 +0200
Message-Id: <20190523124216.40208-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v3 0/3] RFC: add init_on_alloc/init_on_free boot options
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, keescook@chromium.org
Cc: kernel-hardening@lists.openwall.com, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org
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

As suggested by Michal Hocko, right now we don't let the heap users to
disable initialization for certain allocations. There's not enough
evidence that doing so can speed up real-life cases, and introducing
ways to opt-out may result in things going out of control.

Alexander Potapenko (3):
  mm: security: introduce init_on_alloc=1 and init_on_free=1 boot
    options
  mm: init: report memory auto-initialization features at boot time
  lib: introduce test_meminit module

 .../admin-guide/kernel-parameters.txt         |   8 +
 drivers/infiniband/core/uverbs_ioctl.c        |   2 +-
 include/linux/mm.h                            |  22 ++
 init/main.c                                   |  24 ++
 kernel/kexec_core.c                           |   2 +-
 lib/Kconfig.debug                             |   8 +
 lib/Makefile                                  |   1 +
 lib/test_meminit.c                            | 208 ++++++++++++++++++
 mm/dmapool.c                                  |   2 +-
 mm/page_alloc.c                               |  63 +++++-
 mm/slab.c                                     |  16 +-
 mm/slab.h                                     |  16 ++
 mm/slob.c                                     |  22 +-
 mm/slub.c                                     |  27 ++-
 net/core/sock.c                               |   2 +-
 security/Kconfig.hardening                    |  14 ++
 16 files changed, 416 insertions(+), 21 deletions(-)
 create mode 100644 lib/test_meminit.c
---
 v3: dropped __GFP_NO_AUTOINIT patches

-- 
2.21.0.1020.gf2820cf01a-goog

