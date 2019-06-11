Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D46DC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E83A82089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gDnBG4EJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E83A82089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 630326B000D; Tue, 11 Jun 2019 10:41:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BB616B026B; Tue, 11 Jun 2019 10:41:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 199356B000D; Tue, 11 Jun 2019 10:41:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B94656B000D
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:41:47 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j7so9750159pfn.10
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:41:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aoM0W68wUr2XaaE/a2NJlPCtCZVNUAc490vBn4tMbec=;
        b=JyV3iMWPw3sskBJ1nY6KENJnMWgj4s6U3JToqPEmdhBC7/6R5zjGCzXZMrTrhLx8l0
         TVfBMWlSORTF4YJzp1uzhTjdqimx9i+3GD/RG83jBN7V0IqJTQ6bHlalds74JisNLZXZ
         KVRyZS70+LTkii50yUglicKVIsjAs6htifDcEfau2Nl8KPoe/RDYcOZneCogdRwdIcUZ
         d0TKSV0g4C3/i+UT08Cedl5JeKp1zjwQtxm0ZPWQ94fskYNaqZJOZP9UzFOjrWHHlUiu
         zYUNO0nm/CC3QmECIxveISe37IqvP8HLg4O/4ha1R+55WUTqlhXp0xuy87lk+AWPqril
         qSZw==
X-Gm-Message-State: APjAAAUVgxykN7Tc7147+U8NiyPs82wCYfJ/Z43dQANLzfnZ41TV/UWh
	F9gN71Qjgqiz8QSDSO01YVPqYPE4nFlDqLQ/5QctPiwrLFZ9rzl3gPkPBTWnKxaVPipbsEnJVgG
	FFZhloe6Cs3VEUYhJClfan+Ku2sJPAL4SpTap99KMF80vKV5vo82zDmqUCih7pQE=
X-Received: by 2002:a65:620a:: with SMTP id d10mr20679645pgv.42.1560264107226;
        Tue, 11 Jun 2019 07:41:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkWPmDt7ai8x5lw9BsaR59Qgcgs0bsMi3DNxbQjvlsDlrsSsv4GxLqBj+zlWUPlJ3Xf+I6
X-Received: by 2002:a65:620a:: with SMTP id d10mr20679597pgv.42.1560264106526;
        Tue, 11 Jun 2019 07:41:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264106; cv=none;
        d=google.com; s=arc-20160816;
        b=VL3y3tiBRBnjrvQBZ6y/YkpjlIayxAFDaKpZ3SVW0yGSlWj/Sy82vBw3j7Bo/8n4wB
         RpLH45HVN+WxS2O992Ykd/7tXx3L9d4U9DmD8Yuak6OloNayeDNx9t01riMHcjiF48EO
         fOWn7o0R99chQLcl1Oah9pYXqAUkOFgNuWxt6J7uzaKtxsgOkA1MZDs6abGq02y2Nh2Y
         epfwduTUPgzqn5VpzodlIW1z1tuvbsvG3bPVS7/Zs8citZDKl2AO2anZKPFITTLY+WKl
         JQWa+6U62vEHkBlbaYIMWRVpG9BHCuzRK1z/vtRQfXRkO/ZeQPYGtkXaXqIybXCXGVAD
         JGAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aoM0W68wUr2XaaE/a2NJlPCtCZVNUAc490vBn4tMbec=;
        b=hVzvB8dMn1oTK3doqofSx06jcESndpiqRpnrPKAYdBz/ellC3nz5laHx953oU+Lijf
         Re7ZEFybuem9b3rocEfZaNrU3am6YmRaN7NWE1baYswJ45xA7mGoIRRQCJaFIFQTJrbs
         yuOPBJeedYgJpEKmnlbQ7jUNiJCxGJWOsbe7EIH+9XhWlP77b4XGy1s8j6j5pJ904nFA
         0ixxKLgW0bSqCfdJJZvjpLkjqr8Lwt95uHk+2vf7Cfd9VNFTWgNWiwSE0qOGWvFWU8gT
         2M+voLL3X8utKBXlr25hsIVUGLCcK/2bpSpds+EwnX/2Hq6Zy8Q3p5MYOqxOEYmVo50A
         +DYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gDnBG4EJ;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o17si12824022pge.519.2019.06.11.07.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:41:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gDnBG4EJ;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=aoM0W68wUr2XaaE/a2NJlPCtCZVNUAc490vBn4tMbec=; b=gDnBG4EJhorlcxzh8n3Q6192lS
	oxcv3q6eGknVP5wRVlITasIuZSJKr++EHCSVxOVhjVGn2cwkHjWGCmhBBQKUBElIcT9hruj4PtePO
	MHFxV+dlrAFJz1NPfBmMiKvrFq/MRfT7uYbat0vilb1MVShRUuxMpBhiL3YUJMzmll051/NWCIPfw
	fVxD5UZKDeeqxPGLKsBzgs99hbXHTDPXIDaEdBomeYM4pa2U55YSA/5KJVGWqy5P9EUg3aF1jdVmR
	NDp08Vb3hrxotUTnHlQuHiVKToQQT8DsKhT+zU8JUVij0alNbApDW3J1pFC6FZhCh8HRIB6gk/bsD
	CmmlBGzg==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahxo-0005R7-B5; Tue, 11 Jun 2019 14:41:28 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 07/16] sparc64: add the missing pgd_page definition
Date: Tue, 11 Jun 2019 16:40:53 +0200
Message-Id: <20190611144102.8848-8-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190611144102.8848-1-hch@lst.de>
References: <20190611144102.8848-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sparc64 only had pgd_page_vaddr, but not pgd_page.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/include/asm/pgtable_64.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 22500c3be7a9..f0dcf991d27f 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -861,6 +861,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 #define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
 #define pgd_page_vaddr(pgd)		\
 	((unsigned long) __va(pgd_val(pgd)))
+#define pgd_page(pgd)			pfn_to_page(pgd_pfn(pgd))
 #define pgd_present(pgd)		(pgd_val(pgd) != 0U)
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 
-- 
2.20.1

