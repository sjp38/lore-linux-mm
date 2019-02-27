Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1121C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A47B20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A47B20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1915E8E0019; Wed, 27 Feb 2019 12:07:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 102B38E0001; Wed, 27 Feb 2019 12:07:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB1748E0019; Wed, 27 Feb 2019 12:07:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 877568E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:55 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f2so7102977edm.18
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RVhGpLl0wO3KpwIPlXPvU+KYzfgn13jA2Mau1bulkRQ=;
        b=qb5oI9Mg1ZvYOvZDLb4KADWWDdKYgXPc7tjvoIV7mOSCHfnUToG9JVYDSHEXzY20E/
         B6OcMOLsDhkbMCLkHcR628XcK2yeIFsiyuUdag2ned5kdkJyCsKJcvgwswxPZA7LHWJb
         FGXbt2d76Hp4HzBzuziaEq9iJ2U9M+n7ADsqzPnn/c3uodp2Zc1b2V06mJ39rdn6wdv1
         9Sxweq5LALFnAvPK+sFYLVEVGc4TSdYhriVy1145AZpplIFRwWVuhvl312uddQ7FIQlC
         HIHR1A9xiJqbqQxN9NoEerHa/dIM4dwKlSsmac+i6Qj/0Dz9D8YtWOPoB7AH0eusVYAA
         SzNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuacVSndQ3jfrPhR+MTTQ/WB+LQEWmaCDWCElB6yZxkJHFWoOK9C
	cs2XDRDifEFzJNbAX/USw2gtNDzpFQIoyJYu686vYt4uXq+k6xY857p2WP6CvLPySvXKw5VOWdo
	YqQEGmNozY/iinqvAUJ4ADRVLEQpaKssY/WRF6kLPaE47SUvhLW21qnNCC5U2C1y8LA==
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr2306856ejf.92.1551287275024;
        Wed, 27 Feb 2019 09:07:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibu14cwnkgY1DgW434sqcEYHwD1PVjpP6zXH4tmr65aTCrLEsZRRXN5vvaaqzDw/Id9whPW
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr2306795ejf.92.1551287274029;
        Wed, 27 Feb 2019 09:07:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287274; cv=none;
        d=google.com; s=arc-20160816;
        b=FtJFwqV/qVbOZbpSeYCSckXCvP4kIcKvF/bEQHrH63acDU6Dsg8/N2R9NVr5XYL8O/
         wsW6vNovzsuU3YCE1OWM85aY5U3TqgZd03PYUksrTI61vMHBz3ud3PIgef+ddQuY4P8n
         P6f4PBL6cy+1sfkZbha+TS/sWHpCDg6flpRmSO9crAJ1G3GxyI2y0vt50KrwBmNmYVVh
         n0dW6nXYsSWUPPrsMVBN6gJOv+0gCtCWy/dhXJr6P3Jq9WcoIi4ZimSlFHAGgrv1Wuva
         dWB8Q7CbblQekRIRBttGfHjEJstoMFs2Hn+p10ho14prcdWKy6cr8EivmqFxxrY+FBK3
         ViAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=RVhGpLl0wO3KpwIPlXPvU+KYzfgn13jA2Mau1bulkRQ=;
        b=Hl3N/wRLTQFNdYRIRzKDrD5RIfh4Ix72mJ1bLECPH4vMD9a43dl5bPukQr77oFjFoE
         fLEXxQsjnHE3GVTT+iIx7ROJXO0Lazqzq4ZebrsbMdueMGKqcC3351M/vnvoG3meE0NY
         e2pbqmuqAn+gnOyk3i2Q4fD/tOBJ16RnofwBy5KdorjQjzIGTwwgcnJ6O7rfvVbOnFKz
         ZC4OtixVsyVRi39NTTmfe1TKIz/gvH0CTQUUO1MrP/ynBP0BqfiWytMAdktyBkVcuA+G
         jG8X9CDFiWgA4+HXci9B1TOMmffMUvGIyVJbq27SUOnXkZw52X2j2Mp5UQUW3Q/Lprtn
         2PWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s35si1396825edm.405.2019.02.27.09.07.53
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:54 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2B1321715;
	Wed, 27 Feb 2019 09:07:53 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C0CE73F738;
	Wed, 27 Feb 2019 09:07:49 -0800 (PST)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Guan Xuetao <gxt@pku.edu.cn>
Subject: [PATCH v3 22/34] unicore32: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:56 +0000
Message-Id: <20190227170608.27963-23-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For unicore32, we don't support large pages, so add a stub returning 0.

CC: Guan Xuetao <gxt@pku.edu.cn>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/unicore32/include/asm/pgtable.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/unicore32/include/asm/pgtable.h b/arch/unicore32/include/asm/pgtable.h
index a4f2bef37e70..b45429df8b99 100644
--- a/arch/unicore32/include/asm/pgtable.h
+++ b/arch/unicore32/include/asm/pgtable.h
@@ -209,6 +209,7 @@ static inline pte_t pte_mkspecial(pte_t pte) { return pte; }
 #define pmd_bad(pmd)		(((pmd_val(pmd) &		\
 				(PMD_PRESENT | PMD_TYPE_MASK))	\
 				!= (PMD_PRESENT | PMD_TYPE_TABLE)))
+#define pmd_large(pmd)		(0)
 
 #define set_pmd(pmdpd, pmdval)		\
 	do {				\
-- 
2.20.1

