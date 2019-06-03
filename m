Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 308EFC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02FDA27A91
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 14:35:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02FDA27A91
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F9956B000A; Mon,  3 Jun 2019 10:35:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B69B6B000D; Mon,  3 Jun 2019 10:35:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 770F06B000C; Mon,  3 Jun 2019 10:35:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 264086B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 10:35:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r5so27710911edd.21
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 07:35:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=92MHN8wjo68Jdi/zESAYI+eEzAZFAhJgQTZKiHaba2E=;
        b=Px9fp/MIn3Fx6qbXD2KtES5k85WXhBgI0belMTonz0gzgNCl1qd5syhIIWJri06D0k
         30lPwL9cKjDT5Olw9BT8h+VZ4hC9pthKBIaqSwyAulB1VO4izKCSPk5dsE1R/y9evlPd
         9nDRTj16RvzKd9m/jFlldcU+MhoACAmcQb1DKntvz19a4pBLLFGHdjNo2e8WjXxwofhE
         /x1XL6k9uyxeGabPHcoRglimyIFx42HekALRWA1zXJfvLAybLfxaavlcivGjCYvjJuTw
         1Pyub4NoDpLUeFeKpLskHKjKj/7STDisPyVlkNmQuLEEGQCgVJTbNBQsZDfl/LKNF9c3
         l1jA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVRK5/oppZVsBEJrubVnvibbYtHHvG3vtJrY86WIAtz/115+/n2
	kJlftmXUc1Mv7sY5xAdtCsi6h0ZFVXXWtiRtCo51HhteFkd/Vc5iDrkyrnuBgVi24ClTl4Xp1Nf
	78rveKd7TgU9uKwOP4LKBFyqdp7Pzg4PwcnRYjq+Hu+vL99n2oqOzS5bxZXLDLoUIDg==
X-Received: by 2002:a17:906:7fda:: with SMTP id r26mr7207631ejs.9.1559572513666;
        Mon, 03 Jun 2019 07:35:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyal81zi9lPDhXgweMksZ7S5msLw4Ox6W9bilqX43vthDcVpwL4HAuMHYhjy5hj4kCj71c1
X-Received: by 2002:a17:906:7fda:: with SMTP id r26mr7207558ejs.9.1559572512688;
        Mon, 03 Jun 2019 07:35:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559572512; cv=none;
        d=google.com; s=arc-20160816;
        b=h28q27CUcstVPhNzjq5jGRaKBrpiHSdUDkYwf6VJeRIPFIB8CKwaVKnup1T7eCkF4t
         Yrmyc+Pxw7Obb+3dOUoS6ICV8sArJnUtPlhW3pyq6YYmYpcSY841QFZUdhoU1zVodosI
         LAME5K2qp8vJ8Wa85bJYX3bwgZd0bLHrKunU13fCivV0b9tWXxDYsjC+2vp7J7jFNRT5
         c81sdHp4PbRUkg2SupKumkjXYTYpYPEVWc7A/7jUTTO/qmv8SPenJpgaoADDQ5+lYRK6
         /sf8LZ8WKEiwHAlPHQqVn72eOKE/BQm27wRp+DqV9cUpcCT9brqO3PkQYpAh/n+ahqHg
         kU+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=92MHN8wjo68Jdi/zESAYI+eEzAZFAhJgQTZKiHaba2E=;
        b=ElIJSCezNyhsN0r1ETfYsOPe/D002UzkNLbJBuO/bc3fHvAMIc8xrpMghttkZsFnBf
         Fq8pSTOEpfn+3L9HtrGmScSr8o0gBIhIZ04PkwwXEfUO41IDWo7fQwIBLg9+N+U9/mu2
         i8Fy2KV7eYJSvmy/HVcGDBln0rN4dz572S60m58glHNh9cZAixPNoFgTQr/YtOhKkINN
         YpXdtFVUyfvxDcq7fuDlsJwM5DUjrkQCapKKpSTT5iWfMfotaUf/aHcCYOzB6+EPuSwV
         it9ruY0l/VLz4hXI3BuKAzANIr/6zBuv/c2sCP7sXZkweU6VABZLJP0eYVG4eOAF5e3p
         x5gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r15si1833853eju.331.2019.06.03.07.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 07:35:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EC697ACCE;
	Mon,  3 Jun 2019 14:35:11 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/3] debug_pagealloc improvements
Date: Mon,  3 Jun 2019 16:34:48 +0200
Message-Id: <20190603143451.27353-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I have been recently debugging some pcplist corruptions, where it would be
useful to perform struct page checks immediately as pages are allocated from
and freed to pcplists, which is now only possible by rebuilding the kernel with
CONFIG_DEBUG_VM (details in Patch 2 changelog).

To make this kind of debugging simpler in future on a distro kernel, I have
improved CONFIG_DEBUG_PAGEALLOC so that it has even smaller overhead when not
enabled at boot time (Patch 1) and also when enabled (Patch 3), and extended it
to perform the struct page checks more often when enabled (Patch 2). Now it can
be configured in when building a distro kernel without extra overhead, and
debugging page use after free or double free can be enabled simply by rebooting
with debug_pagealloc=on.

Vlastimil Babka (3):
  mm, debug_pagelloc: use static keys to enable debugging
  mm, page_alloc: more extensive free page checking with debug_pagealloc
  mm, debug_pagealloc: use a page type instead of page_ext flag

 .../admin-guide/kernel-parameters.txt         |  10 +-
 include/linux/mm.h                            |  25 ++--
 include/linux/page-flags.h                    |   6 +
 include/linux/page_ext.h                      |   1 -
 mm/Kconfig.debug                              |  14 ++-
 mm/page_alloc.c                               | 114 ++++++++++--------
 mm/page_ext.c                                 |   3 -
 7 files changed, 96 insertions(+), 77 deletions(-)

-- 
2.21.0

