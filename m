Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34B40C072AD
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:05:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB3782082E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:05:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB3782082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CA0F6B0003; Fri, 17 May 2019 17:05:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27BAC6B0006; Fri, 17 May 2019 17:05:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1919D6B0008; Fri, 17 May 2019 17:05:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E492A6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 17:05:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f9so433956pfn.6
        for <linux-mm@kvack.org>; Fri, 17 May 2019 14:05:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=YfCe+COKqa5ggpfmtNnL5GsxQst1Dnz2S0SoF3Ga0Dk=;
        b=H9NxQh8nfiGGOBlfMW8ygijrTQx/DeEVYV2N52fWCcLU3tPXoxbXJek0AR6Ohc5g7b
         MgYEV9oyfP/IjTkdyyDoTG4eh6RykRLq52GJT4R7qYoU89ABCIN3jnbJ6TQNboCJlYZK
         71RsqG2Xc3qCLWgZIVUaTTV/6pQm5THvBiX1XGTHcB3DpJewjc/paQuwf+0rDZgk6thf
         jFakvaB7/vzqSR5P2u6vV7ldR/rXqv7ObkBveWKnhJsw4EJVGT5xwu186Jgx6V1qLgp1
         Ju0e2r/wlEWSI1Fj5RhFPOTQ+S4Gg7drzUO8p8X/bt3CQgWlrh4vT5jQ9Un1rvqAjcq5
         72Ow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWhRyEuvPFPzPYptCgaajnbJu4b5YLREpJInWmJC/KJpA+anpdO
	Rg1Ft4MkwPAk6uNPDKpv45ZWfPHdJLN6ONdxMnT+GCA/16CzS9g0U042TPO/znKxn7BM0EMeoig
	/pOe3fiSd4b8yuP/QTkTK5yGgc/rzIWGNsAj7A2okvWXLccgBm20A5Q4jjD3/F9RRpg==
X-Received: by 2002:a62:e803:: with SMTP id c3mr17831493pfi.58.1558127111537;
        Fri, 17 May 2019 14:05:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZPZ41G6EXxvzI6Ffr+sG4Oh9lhAShJFzf4+NFy//qh3SoSfnMdFSCslNxiWjn18LBXNXZ
X-Received: by 2002:a62:e803:: with SMTP id c3mr17831389pfi.58.1558127110483;
        Fri, 17 May 2019 14:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558127110; cv=none;
        d=google.com; s=arc-20160816;
        b=xZBm01t93JMbmwEOr5HeV2WwGcOVgvQLznEUUHokAVkJxXnp6iO6NKqbIpP6y8AH/H
         v4cgSd2VXFy+gNOMHH1XO7xPeSeKAuAC3kfKezKdZ0oVt7j8DvLObfVWOWrsjQZAfoql
         PkQznhGSmgzkJlnE2DUqq3dBf1a4V3V91C2i1iJ1qz/f+Sw4Zx9lB2IwrmwE3YdcB6j8
         ArVWlykAhK7RyhFD3vAPa3+hHaL3iaImR9D+d9jmlnbAXlK733MGWMYRK9yxZVqbXe+e
         COqD8J4EnHBHbj8RUGSDVv/+gC2ONpxXuQ8v0u2gyxYay65ibJs7snRiBbgQ2mucN25j
         mKig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=YfCe+COKqa5ggpfmtNnL5GsxQst1Dnz2S0SoF3Ga0Dk=;
        b=vWi2NNkRrwIeR98nuvqjjvQ77zsEtlIXHqoUvL0snT23V+p+LKZisEWdhyVPHlanKr
         VXdluJ0Wm/35LoGdPg7V0ISIABpgMIk9fk4jzfDrF+Dvky2yWmjRyqsH1S5X5xfPzBAE
         9qGSKsJngu15IhPp4RUn+ps6+rNWJ+vTgzoJAJX0gC0FVP/GOOr1y3uKhPIeifGe5Y+l
         QnIcXILFNYGlffePQDjwJt6g8s7qHpO+eXl0EjEqdq1iXHXQGojeFZEvmeO4YhbVU0vy
         /kVQnPd3pBZwSqHHHQjVNsF+i5v7WMvn4LtzdlkyTJ+O9Rzi8pXurI4W5lteJ9CyYaTn
         VMBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p1si8618089plo.212.2019.05.17.14.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 14:05:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 May 2019 14:05:09 -0700
X-ExtLoop1: 1
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga004.fm.intel.com with ESMTP; 17 May 2019 14:05:09 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: peterz@infradead.org,
	linux-mm@kvack.org,
	sparclinux@vger.kernel.org,
	netdev@vger.kernel.org,
	bpf@vger.kernel.org
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 0/1] Fix for VM_FLUSH_RESET_PERMS on sparc
Date: Fri, 17 May 2019 14:01:22 -0700
Message-Id: <20190517210123.5702-1-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Meelis Roos reported issues with the new VM_FLUSH_RESET_PERMS flag on the sparc
architecture. When freeing many BPF JITs simultaneously, the vfree flush
operations can become stuck waiting as they each try to vm_unmap_aliases().

It also came up that using this flag is not needed for architectures like sparc
that already have normal kernel memory as executable. This patch fixes the usage
of this flag on sparc to also fix it in case the root cause is also an issue on
other architectures. Separately we can disable usage of VM_FLUSH_RESET_PERMS for
these architectures if desired.

Rick Edgecombe (1):
  vmalloc: Fix issues with flush flag

 mm/vmalloc.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

-- 
2.17.1

