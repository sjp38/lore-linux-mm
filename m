Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1AC0C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:26:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADBF720872
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:26:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADBF720872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DD1A6B0008; Wed, 17 Apr 2019 01:26:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 464C56B0266; Wed, 17 Apr 2019 01:26:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32F226B0269; Wed, 17 Apr 2019 01:26:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D791D6B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:26:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o3so5263403edr.6
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:26:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jI/ny0pZOck4kyabjqWPla9k4gZ6U+crF7GP5DfyIb8=;
        b=JDcLfDwlv5Eh5NSO+h4B0OHPoxKhNdHY0YngWKVrOE/9KjNIsUhpFL9MKEzF9VoVvs
         NFYUCg6fjM7Zd3q/bun+WMT09toBBuTX4AsacMOkKc0QdaVyNBJMSL2ALmAVW9zjllMt
         a6HMVa+BNhxOULw8wj78kLMEOC6By3dBCe5J6yrVtmDkchMJNW/rOK7gJLUqwfLMlD0v
         UVoNiO8DUBwVtl5vyJRioW7uPYcAjTvn4ID6sxpwO5dPzlzgk4nDufAq+utjdyFWE6QN
         tz5oGeiVQjwPDSlFxkXF4vVPqAigIfXlHjaZub+nUmqYmZoRCd+IAzrBIU2dKvDzhBx1
         140w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWdSZ6mN+D9WEM41HE+X8vzvUeRPM0Vp7O1kI3IlU3kVTxoKun/
	mHALVSeVj9Z3TcsXZKCEl/YkRqZxKLL0U1s4wlhlSVMd9mIfteVCTY7+uRMnCPIgwrV4NixWuND
	KT4cL4LN6XGp7kmbbqJXHfDzz++J5kreGFgSnnFRs2QznpDc1MAEv50ztsRITh90=
X-Received: by 2002:a17:906:5a09:: with SMTP id p9mr47271458ejq.46.1555478771408;
        Tue, 16 Apr 2019 22:26:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzM5hC5G46DqlVTUy8wDxDMpnHB19JmlvjaRLx7QY5/7C96//ZeAc4RNDzQN7GVUIBya6RN
X-Received: by 2002:a17:906:5a09:: with SMTP id p9mr47271411ejq.46.1555478770363;
        Tue, 16 Apr 2019 22:26:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555478770; cv=none;
        d=google.com; s=arc-20160816;
        b=lFG3opUq/jGXyosgGZNdMVw+3j5YSJcJLXKRT3I2d0BMoonlGQUOgl9KRuB8bTNers
         Qwr3ZnJ/X6b+2hjbMt9dflg5cydVzY2BzLbXrWftzTEGjkTKf0O1ZgPYKLvtkHPY+tij
         CYLQstW57w3Klt2iLoAGJC+l1VrksyLDcTrv9Snlbe58jXNK29XFSoPM/d+P9wPoubAj
         mMrXa9nvJwSAmEaGRahPpP5OkSxc0oFAzJfM/QKypZMd+8g25abtb/KNMAlQLgQjCiP2
         cyMQC0LNYyWnHjXzl4M6Ah6nJdoJarrmJNPDq1frrD13hawiPmx6RWfohnfDTrIec89Q
         Lo9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jI/ny0pZOck4kyabjqWPla9k4gZ6U+crF7GP5DfyIb8=;
        b=NlLUQXPOrawLaNOcaXllL4I1LtP6LCXbTTBteKCGQLPc8S7K5a9ViDcQgD6vWqdrVV
         vhza/PUj0dwL3SXqpyRDPKYygB/Bt2v/1TFi0QYlrqqw1MmzWKXOcwpontBnaSqkbp9D
         VEwd/7qy97gdB15Am7BPQ/P7ACRaNca/oV4i52u1MI/gns4A3BmhpbXnEDnp8mgMbF79
         K43OeMsbmu2LiQ0DVcSEHQ9cdEB7+h/s1zW6pjbUDBlyLWip5qU+9XAKtJ4jZp3r826r
         mbDLm39EqtVfDA26SHXU+VgzkOm9y6Krc6+JTTFf9fKCUtqnFwqKzwYbfESC9efdV7fp
         0duw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id q40si3597444edd.219.2019.04.16.22.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:26:10 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 442A720003;
	Wed, 17 Apr 2019 05:26:05 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v3 03/11] arm64: Consider stack randomization for mmap base only when necessary
Date: Wed, 17 Apr 2019 01:22:39 -0400
Message-Id: <20190417052247.17809-4-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417052247.17809-1-alex@ghiti.fr>
References: <20190417052247.17809-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001919, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Do not offset mmap base address because of stack randomization if
current task does not want randomization.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/arm64/mm/mmap.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index ed4f9915f2b8..ac89686c4af8 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -65,7 +65,11 @@ unsigned long arch_mmap_rnd(void)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
-	unsigned long pad = (STACK_RND_MASK << PAGE_SHIFT) + stack_guard_gap;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
 
 	/* Values close to RLIM_INFINITY can overflow. */
 	if (gap + pad > gap)
-- 
2.20.1

