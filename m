Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB6DBC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:50:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73F4920815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:50:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73F4920815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 243446B0003; Sun, 26 May 2019 09:50:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F3126B0005; Sun, 26 May 2019 09:50:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BBC56B0007; Sun, 26 May 2019 09:50:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3B656B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:50:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z5so23315940edz.3
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:50:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dEuG6Wupa95dC9izLwtsSW8dwaH2/9q+MhpkifLzt/c=;
        b=bGYHfjfDa9hTuqfjtecU388aaZNa5i8yQ/rJnYAVnl90n6z8p7nVmQv36tpCkHVBYv
         uqgR+pmUki9tYpTWO1EFTryNjs3NBwhyIrqosdQX558cma4sbl9x3iC84rp5yKz+ZIDn
         DxPdZYJAsMQ7xxqSjOvToweZxVVVPGvwRq9sSIWsyyg6hW9KXgMybdNPXTtfIvjzCMKk
         m6ln7nCwfYo30b3KsdhScTgxYGDmzSCr/JB76CXKqeDUtrwyCHjpBcC9Z5eHlpHr/38W
         s2W0xgaEsmviADnmtzyFRxsFDCcR21Gz+DOQ/M0r6+hqxcB5MbZugv0dpN3AfjNSyTDW
         2kMw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUPIbHRy+seJeTMBF6yk9zZKwYR7RlCtK4Jvm3nj09YyuydSH5A
	X5l+IMWDjZtHP6x4kk6P00PZL3NK7eD28HZg+AnthDWjS80HC9FOxrzUHvizBu+uPOwbgFOG8e6
	RZFWltVvFaH3XRdD2To7TTRlb8DFn5kgwcjTwlNZd7Ge9TNARQi1UbUKHluvGmAY=
X-Received: by 2002:aa7:d444:: with SMTP id q4mr12272138edr.302.1558878625212;
        Sun, 26 May 2019 06:50:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyka+Fdy2IN0+/iiJRqMYAana05bXvb7o9HnTwcJrxv6Xw0/vNWvxxh2flWlsDz12wVndHL
X-Received: by 2002:aa7:d444:: with SMTP id q4mr12272066edr.302.1558878624217;
        Sun, 26 May 2019 06:50:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558878624; cv=none;
        d=google.com; s=arc-20160816;
        b=hq6huGCwYV60FF+zcgJwDmbTPw/d1oDjgTYM67amdkPVkTceEwb8pS0Xf8kn0MhZb0
         xwie8YRNP+4byTPXUTaaQSD3AD9RzU1LTEGNwLt26Vb+suI0trisqUjN2LmKV5oWkPn4
         UzXR4pmW4iqtUUN5DqngC8oIi9uPKKIoSuScOk/Nt9MBjQ0igkEmUGfKKe9h67zIOdPh
         864w39ypZavZbylQXHng0ywYZ60aWarMEmD/AzcdbJtZJ1eJefyme8obTMYCqH1m9X5y
         ZReKO3uG5W/aWrbfm0se7rh/FNmGWST3vs/Al5YipIYV0+gFpdmTW/IkVNGUsdyGgMlK
         FrPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dEuG6Wupa95dC9izLwtsSW8dwaH2/9q+MhpkifLzt/c=;
        b=YYF3Z/vl5XFirJduBuXAhP8nRtmvOZRAJQu8S6nibAdUueKx8BEEYpHxX6csaB8AH0
         k4nI9aBrpaCPuoQkCmDcB2m2S/QQo6+JwrFJcmaum+QddMtoC1igNxVpFOawulm4YKKQ
         /bssT8aNQSHV2wI9dWd0RZm/y0+rEYJGTQd6xuThkj5GVr0edoWUfh7SHO4VgRQCkyNl
         c0ZVajmKIGIy8tVkik4Rk01dopKag6bT33R5PHjybeHBEhyzkBx/xLshh8N4fI+ZosXS
         n/GE6W0F1Ln35XJgC2DYKYCSCLdn5OMCcPtQndvi4Gbu98uBbaXJWk+7TkUCEoXfs9fa
         XP4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id a18si4593831eda.350.2019.05.26.06.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:50:24 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 7A7651C0009;
	Sun, 26 May 2019 13:50:16 +0000 (UTC)
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
Subject: [PATCH v4 02/14] arm64: Make use of is_compat_task instead of hardcoding this test
Date: Sun, 26 May 2019 09:47:34 -0400
Message-Id: <20190526134746.9315-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000123, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Each architecture has its own way to determine if a task is a compat task,
by using is_compat_task in arch_mmap_rnd, it allows more genericity and
then it prepares its moving to mm/.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm64/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index 842c8a5fcd53..ed4f9915f2b8 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -54,7 +54,7 @@ unsigned long arch_mmap_rnd(void)
 	unsigned long rnd;
 
 #ifdef CONFIG_COMPAT
-	if (test_thread_flag(TIF_32BIT))
+	if (is_compat_task())
 		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
 	else
 #endif
-- 
2.20.1

