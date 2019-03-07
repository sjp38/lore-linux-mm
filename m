Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54142C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:22:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EEB620835
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:22:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EEB620835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9844D8E0004; Thu,  7 Mar 2019 08:22:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 933DD8E0002; Thu,  7 Mar 2019 08:22:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FD968E0004; Thu,  7 Mar 2019 08:22:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5088E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 08:22:46 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 29so8014956eds.12
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 05:22:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zQnpH8zaNMj9f8CSWUqk/1sf91xgKsQaG3Y3A4jkMj8=;
        b=YniVI84WekRx4/kcJeoPkQycZwEa87h/IpG1xEA+E7G7LkB/q21/CU3rSHTyqXI0A1
         kl7vXuXZ6Ef0spafYxeawCz0Bup6no1O6XbvDrWysQF+AlF1BiFRVtb/wJOCg4NjENeL
         cI/TT7wgg/Fos1idAEXR/rfEg5ULaw3Hgj7Z0yAtB0fvjggNc0jGiaXZ3E06+WRyPCZ9
         L5K2u3X9Yi5q02TjIwegahEE0nWRfd1XePsVECksKeWy2/cTAdjYbXQoVfIyPprNFLgz
         BWTz155bE6lVM0IWQB6Tam4aWCOFMZCWGoDmwSB3K9NJezpUSjLeeWr+Lq4y7Mq2ytcX
         UH6A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXzy3B7epn3L8PJqJnpjnx3U6gcuVLkKZkHci5AqYZOYlDDTXDI
	siKz6YF7C+GBK1LVCXQvpimlYblaF0L76DQXYzcsZg8AkC47rRbnGPGC7fneByCw3noNm0B7zK7
	TNT7ka/Z3ML9gSp40fH6XgRoIwJeK2X4um7I9AcvXdQAsAhV053OIX2sycfYEUIw=
X-Received: by 2002:a50:b527:: with SMTP id y36mr28835312edd.83.1551964965404;
        Thu, 07 Mar 2019 05:22:45 -0800 (PST)
X-Google-Smtp-Source: APXvYqz+S2wmP8JtKFWyGUcXlfdvWYdHTjIN/8seFrCJe0E7E+3g/hI3ZtfY0+KK5TDv0NAAflkt
X-Received: by 2002:a50:b527:: with SMTP id y36mr28835145edd.83.1551964962650;
        Thu, 07 Mar 2019 05:22:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551964962; cv=none;
        d=google.com; s=arc-20160816;
        b=ZZm92n4CLsb3JJl0aTCbeN3fubCaf2sYmYlYifyif+zlRwVWdx7+lQ0kmRhrONeZeL
         HzYHrgMZyr692iWTI9y2EzTLSxc+zQXyWZYAWEhMIgbleMcvbUxDl3Gc/fZJyNBvknSo
         XRcrXDiAk5xQapu7UEK6lyhMRdxTA3CYHPvRQJSmGo9C3aNOu/jIuvHprpa6PkgJCNTA
         6K1KfzjLV7v1rImQLAwMatcBMyYriPSXmzDaExAdXdEs66/8ES7RBT41ewaPKT/YQcSa
         m3jR4W9OmyWLTA44JyAkKgLTXo17P5NyA8/ytHyFammkRizRvMBocquRodG/pJtDmZP7
         UK9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zQnpH8zaNMj9f8CSWUqk/1sf91xgKsQaG3Y3A4jkMj8=;
        b=MZPCkREyXEkYCGTMSBZ2Fw7s2f1Stm0fn0vtYCj6wUGmaNkatVKHM88yU7F+OQBNcw
         m3ZysoAu8VO2kolgSpbLqWRGJFo3l7tmdB9R4ZMLKjhB1Avq5uEhRdcj8t0ZBbA335sU
         gEIQBQgwkNFvdbo3GePIUZeinfU9HdMP31TVzAi9XfOh/2h+Z48Afo/MUpecUA+1LC8L
         +0w2Dv031yy5HWDMhQunQpiszyAfZP6TbiKNfmqh/CqeDqP9gulfmU/Trj9QgZogknZL
         mUjKqx3d1IJQIPdZShLERppW+wcMlIsRhsOXjYHrKLmHVlZqm2/AKZpJgCyh7nQcgEEb
         JTHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id h45si2034379edb.393.2019.03.07.05.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 05:22:42 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id B50F220005;
	Thu,  7 Mar 2019 13:22:35 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 2/4] sparc: Advertise gigantic page support
Date: Thu,  7 Mar 2019 08:20:13 -0500
Message-Id: <20190307132015.26970-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190307132015.26970-1-alex@ghiti.fr>
References: <20190307132015.26970-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sparc actually supports gigantic pages and selecting
ARCH_HAS_GIGANTIC_PAGE allows it to allocate and free
gigantic pages at runtime.

sparc allows configuration such as huge pages of 16GB,
pages of 8KB and MAX_ORDER = 13 (default):
HPAGE_SHIFT (34) - PAGE_SHIFT (13) = 21 >= MAX_ORDER (13)

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index d5dd652fb8cc..0b7f0e0fefa5 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -90,6 +90,7 @@ config SPARC64
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_PTE_SPECIAL
 	select PCI_DOMAINS if PCI
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 
 config ARCH_DEFCONFIG
 	string
-- 
2.20.1

