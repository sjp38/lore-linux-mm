Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96313C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 09:45:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AFFE20840
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 09:45:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nZ1uAEh/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AFFE20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDC0F6B0006; Sun, 23 Jun 2019 05:45:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8E2C8E0002; Sun, 23 Jun 2019 05:45:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7C938E0001; Sun, 23 Jun 2019 05:45:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A297D6B0006
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 05:45:38 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e16so7134341pga.4
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 02:45:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wnbjux+HxNYOkFaRKhTh2OlBlr6Yjq4h8O9uCggPaW0=;
        b=anOvKpOq4VC8KxuRalCPSS8OS4/LP645ZGFxRunmAjRiu9pVCdZ+YnKT+dqpvoirjY
         AGzwkqPYPMOm4LNiVLPuueFmVFoe/NFLiWC1Sn6dmmH/IQ34e6Z2bLENjva3he4zF4CW
         fhJxC8R9ARwtFKuHoV8dZPB9B8mi7Dij3yJPf6Wox8lzy/42ntGYIiJohUISZx9IGr0m
         N/5binFOfAFlSRtF4l3A/NtMQboZCuFaKPBiY1fvjjYVet3lDBId87nAZECn0F3DxR95
         4U5YkLCdBW+qxP0lGNTkyScZDKjPXqTKf3cEXgRl9WothSfpoH4w9OZ93dD/l/SnOf3U
         b4WA==
X-Gm-Message-State: APjAAAVLEw7elqyw8m7lDxhyXwnls/9/Wy2WeOZDuOGg1b69W28WxgoX
	ypNXtegBWzd0lG6+R4Jr2c7DwaZlyFRg9ZX5wQ0TULZTsLjeNiXct6MFg3Laf9CaDzfRjJ2RWUC
	Iv1yQW7HzMN72AxZ/xfpExLtyoxdfANk+zroFLEFeQZbRNNRoEfFTvPDaMV0Lm+MMnw==
X-Received: by 2002:a63:6183:: with SMTP id v125mr22719393pgb.221.1561283138175;
        Sun, 23 Jun 2019 02:45:38 -0700 (PDT)
X-Received: by 2002:a63:6183:: with SMTP id v125mr22719323pgb.221.1561283137140;
        Sun, 23 Jun 2019 02:45:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561283137; cv=none;
        d=google.com; s=arc-20160816;
        b=vIanlroz1O6nAduVY5XA6cxMhbfzRqD0ufi8ws3TQ9mUIzb23qQ/61fMSTEDDj+40H
         G0am9+gWje6kjGBxZymR1At5ZU5t3x5A3+GSvZAYmfQgy9raw2za0PixhRCYzuhXY+N2
         JeSOSt8zTLPfHhSmm2pJWZ63yvjf0QHCSPYwxxHppdylD/thnpway3NDbXNVCGoAdcTX
         RYbKGWkeyG20EUc9ta8TFk9YWxdk1xphlswXC9kSoiB+Ew1tnTKREIIxYDPyX9V9MIl7
         buf1Ew0oJEEdvuaGUO+O1Kn05DfAYTx0NafaN1uMw146tHtSkjPKL3rSrrhFd9wrdC+Y
         +qwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wnbjux+HxNYOkFaRKhTh2OlBlr6Yjq4h8O9uCggPaW0=;
        b=de26r/qWl5TI4sTzB0MyNEPDFIdR0SmrxPxvZHlIV0rdRND9YDwPH8r1Bu9y0aoQwc
         TrQXXBjEscYmcuUp+1JtdCFr3PChaYY9yJcCDeEZTk057Z+hYKmfA2IbSgNfkL/xW/3I
         tUa1+Al1J135pgEbBu9JKCETPW+5qmuAwMnqcg9xUEupcHS3A2Vntios64Q5UPqRZeaM
         AiTNjW8u5Qv0Bj5pbkJFcUxCb42yowFeb9L5Ieb/2RJFNqNp1ybctDyHLAY983THrDWv
         trgXQBPscXxwdtbz8snbZIHV8vy4YzcwNAbi8q8yHe/bQVW9BIqkEpmHhDCmj/Byocxn
         eRDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="nZ1uAEh/";
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g95sor9159079plb.67.2019.06.23.02.45.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 02:45:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="nZ1uAEh/";
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wnbjux+HxNYOkFaRKhTh2OlBlr6Yjq4h8O9uCggPaW0=;
        b=nZ1uAEh/l/iH3XHgJ4JMzpVgG2BAjVP+Z4uP0nLctfLAj7AD/MmtA4UP0ovGBefyCX
         oi/eiKdn5rkb+cERs9Q8dHLJnb+ghuSMilmtfbCoNwrAS8IHMPARnfgHf8n9HMnua6zS
         +dxXBrDAzpJmAl2a5WPEl0+v9WftLVMpwR+Ki8qD5BEfrZHM6Z+MwQFgDagG17N4lc1g
         5g3hUt3k1Vuvyww7G6od0qdoZYGYGxV4ZJ+E/1RRGg0hnv1OCHh2088YsdWh7C6PTe+t
         pG1oasPj0r+b4PVWCRQ/vj3KXGeUaEOXaQbg+/rH4Dd4SeFUb1BicT4qR09j10i/WFg9
         yGJg==
X-Google-Smtp-Source: APXvYqy03K0Z/MbKC+X3ScMS1p5nrg83Wdw/gotWUEhNW5qLKL0hUnw5AV3nEp2FnFcsXPqkd+XVzA==
X-Received: by 2002:a17:902:7c03:: with SMTP id x3mr117368602pll.242.1561283136704;
        Sun, 23 Jun 2019 02:45:36 -0700 (PDT)
Received: from bobo.ozlabs.ibm.com ([1.129.156.141])
        by smtp.gmail.com with ESMTPSA id d26sm6181062pfn.29.2019.06.23.02.45.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 02:45:36 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Steven Price <steven.price@arm.com>
Subject: [PATCH 1/3] arm64: mm: Add p?d_large() definitions
Date: Sun, 23 Jun 2019 19:44:44 +1000
Message-Id: <20190623094446.28722-2-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190623094446.28722-1-npiggin@gmail.com>
References: <20190623094446.28722-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information will be provided by the
p?d_large() functions/macros.

For arm64, we already have p?d_sect() macros which we can reuse for
p?d_large().

pud_sect() is defined as a dummy function when CONFIG_PGTABLE_LEVELS < 3
or CONFIG_ARM64_64K_PAGES is defined. However when the kernel is
configured this way then architecturally it isn't allowed to have a
large page that this level, and any code using these page walking macros
is implicitly relying on the page size/number of levels being the same as
the kernel. So it is safe to reuse this for p?d_large() as it is an
architectural restriction.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
This patch is taken from arm64 but is required if this series is not
build together with arm64 tree.

 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index fca26759081a..0e973201bc16 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -417,6 +417,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				 PMD_TYPE_TABLE)
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 				 PMD_TYPE_SECT)
+#define pmd_large(pmd)		pmd_sect(pmd)
 
 #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
 #define pud_sect(pud)		(0)
@@ -499,6 +500,7 @@ static inline void pte_unmap(pte_t *pte) { }
 #define pud_none(pud)		(!pud_val(pud))
 #define pud_bad(pud)		(!(pud_val(pud) & PUD_TABLE_BIT))
 #define pud_present(pud)	pte_present(pud_pte(pud))
+#define pud_large(pud)		pud_sect(pud)
 #define pud_valid(pud)		pte_valid(pud_pte(pud))
 
 static inline void set_pud(pud_t *pudp, pud_t pud)
-- 
2.20.1

