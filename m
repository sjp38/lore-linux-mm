Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9457FC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 16:09:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66CA52075E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 16:09:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66CA52075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CF7A8E0005; Fri, 21 Jun 2019 12:09:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07FA68E0002; Fri, 21 Jun 2019 12:09:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8A8F8E0005; Fri, 21 Jun 2019 12:09:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8608E0002
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 12:09:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a5so9768509edx.12
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:09:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=LdsD9Ij+mX1BqCc+ySVhRljh0XbLfcEhaVLoZZeTfr4=;
        b=hyc5Ctczz6MihLvjIL88kuXPnGMTFWAuXqFwIVTPoS/Sfpt1SmG1eYNzjkKhM+2Gz0
         FhzaW+OgvcoL9k7qlY6mZSoCQlRPbETazzIP+4WSdldKDg5erDKjtoRzpbdAAv118g11
         SeYp1fcnF+yrg8opBFixiS98lqcJEWT6IvhoL7kNP/ux1mwB4nefKD+ZzpuvGDPpUrjg
         Q/1HWFiVCYujO//Bwq/N4aQ3UYWhWTKsniXEaqGAKWvyEcHH104eT17hUl0WRD47/0kq
         xsVmn1vnl14kDQVdQZE7xlwjkEekrjOX0OU5eu/lqBxRSGKrtDwfTg5c6ZguNTtLiLsW
         +kiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXh+EtGjfikmNAG59Vo5M1QM5OhMZza2DnSZV6hWtVUDfwJJINr
	uK5H7YclJPNOrvZht1ZuOpYMBvyNbBhrIh9lF+e3MFoDhuR6FvEFHWtR8pwgdnZTxNBsqD+0A5Z
	DOqP/KoHMSJ5kC6MPnz9SbUIthU+OAd92+ewAY+OAnnq/NYSQSokAbuXl6CSELNcHcg==
X-Received: by 2002:a17:906:b216:: with SMTP id p22mr13260567ejz.273.1561133372135;
        Fri, 21 Jun 2019 09:09:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLrqtDpwAuJxKVor3N378mzn1RJgsMMb2NBryQzBdpfKPKdmtGSFIC9EEjarDskZqYiReO
X-Received: by 2002:a17:906:b216:: with SMTP id p22mr13260489ejz.273.1561133371319;
        Fri, 21 Jun 2019 09:09:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561133371; cv=none;
        d=google.com; s=arc-20160816;
        b=CWSr77690E73a4dnt9SxYr434y87AEv1glEa6BiPkLrULp786oJewrY4+itGNFUlwy
         9ipxbUSeUEvCEin4hOfwI2se45MLTmF2Riva1+//wpFpjMmWfKplJNXrhIoFBBMXIs9G
         wEwFHFm34ec+mk93oLWLMZNJEQcjd+UG27nSfiTeq5J2KSGop6+qqGTrJvbrxOAP8lxy
         VXInNM+5nY8IfYTwWBOcmMquUeI2QmIZ93TJihfMxrGYlBF6U4sG7SNJvyG2AjKuLuWd
         fyodbzSVBz2mlVTn3hs0Tpx62ULNSNI19R+bdn+y8EyTWOSYZCx1YaY71Wb/bIEwWKXl
         kyEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=LdsD9Ij+mX1BqCc+ySVhRljh0XbLfcEhaVLoZZeTfr4=;
        b=G1cfjma9ygM65v3C7xdFpVNivZ9kyZ3vNhNXfnEjMNQ7CG9D/RUXWSLk8eLWSZyqdE
         dyMSGrHfskAQPK5lCyMmZrdC+EbkIOHQxP/D44qk4yfmvGX57uRdCLyAin21BdSj+iNf
         FCCYEexlYrVnCtQXgJufVgUVHEmfFs6hhiGqCnEKGcgmnKTufmx/iRvus8KPiT9OQi+I
         RadfDHMrQPTsJQmAM+kJd4LDsRmf/ecXpihDBifYYrkaTCWAcQ/S5o0qAZd0g8y336/a
         wj7LkDisE3GMcqhMSyxhs4zW7Wpfe8KijnLWwWZrKr23Tzzf2/K5q/lBGpj3VHGbhShg
         V8Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id pw14si2114355ejb.263.2019.06.21.09.09.31
        for <linux-mm@kvack.org>;
        Fri, 21 Jun 2019 09:09:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6A63C344;
	Fri, 21 Jun 2019 09:09:30 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.42.140])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 076A83F575;
	Fri, 21 Jun 2019 09:09:27 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mips@vger.kernel.org
Subject: [PATCH] mips/kprobes: Export kprobe_fault_handler()
Date: Fri, 21 Jun 2019 21:39:18 +0530
Message-Id: <1561133358-8876-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Generic kprobe_page_fault() calls into kprobe_fault_handler() which must be
available with and without CONFIG_KPROBES. There is one stub implementation
for !CONFIG_KPROBES. For CONFIG_KPROBES all subscribing archs must provide
a kprobe_fault_handler() definition. Currently mips has an implementation
which is defined as 'static inline'. Make it available for generic kprobes
to comply with the above new requirement.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Paul Burton <paul.burton@mips.com>
Cc: James Hogan <jhogan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mips@vger.kernel.org
Cc: linux-mm@kvack.org

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/mips/include/asm/kprobes.h | 1 +
 arch/mips/kernel/kprobes.c      | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/mips/include/asm/kprobes.h b/arch/mips/include/asm/kprobes.h
index 3cf8e4d..68b1e5d 100644
--- a/arch/mips/include/asm/kprobes.h
+++ b/arch/mips/include/asm/kprobes.h
@@ -41,6 +41,7 @@ do {									\
 #define kretprobe_blacklist_size 0
 
 void arch_remove_kprobe(struct kprobe *p);
+int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
 
 /* Architecture specific copy of original instruction*/
 struct arch_specific_insn {
diff --git a/arch/mips/kernel/kprobes.c b/arch/mips/kernel/kprobes.c
index 81ba1d3..6cfae24 100644
--- a/arch/mips/kernel/kprobes.c
+++ b/arch/mips/kernel/kprobes.c
@@ -398,7 +398,7 @@ static inline int post_kprobe_handler(struct pt_regs *regs)
 	return 1;
 }
 
-static inline int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
+int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
 {
 	struct kprobe *cur = kprobe_running();
 	struct kprobe_ctlblk *kcb = get_kprobe_ctlblk();
-- 
2.7.4

