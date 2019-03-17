Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67E2CC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:31:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 270AF2087C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 16:31:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 270AF2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D03976B02F4; Sun, 17 Mar 2019 12:31:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB3B96B02F6; Sun, 17 Mar 2019 12:31:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCB846B02F7; Sun, 17 Mar 2019 12:31:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6627E6B02F4
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 12:31:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t4so5796733eds.1
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 09:31:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zQnpH8zaNMj9f8CSWUqk/1sf91xgKsQaG3Y3A4jkMj8=;
        b=dCYZYJbgae+lMDWU9oQ+PMTq6frVA5/9qjiC8Off7dXDPPOb7jn21r/lWwtvXHU8sW
         lFpA4Noysa6vtkxuXyW8wKk7M6zG2OKZxdz/EghAQfMXG0DGcp8WELBseoZ1N9aaLDy/
         fuNnSE9fbhpW/Il3emMns7jRFhXN/mRSppBDVrhJJ9mHyPBTqEcFvOOK1kxYWZrprzo2
         sddhiVUuI8eJl5jAuN+OM2yKMxJJroA2KN5yVeyvwC+JJdILyLFFXc3pOW6gywjXHGGg
         +l1MBS0lXX1XkOxA2wFZ44Ua9f3lWZF/raorVDjuHHLn8AwVgBNd65KUqdhvI5VYGuj7
         a35A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWMMfGYjERap5r/QEVt09Z87REeL7K1Qnybzo7vIY3DXziu1N0B
	Ol2V6W3sBIDV+/KWyxn6Jc0cfIZ7SiLjO/atnqrfC8az55wx7z7+bayyqpgPKKT30CSHIFrI//s
	v+/jQV1/mfjApucIuLptVBLuYJLLc3a0HoyW+MyxOOqgyB8WvZc+VuHaoDOOCW1E=
X-Received: by 2002:a17:906:33d5:: with SMTP id w21mr8503525eja.152.1552840281866;
        Sun, 17 Mar 2019 09:31:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzs02DOzq+eFRzn/AckrjtC4fL4V+o5cyqJhf4WmyckJeILFTt1fqhPlaeGlHJl4D/5+N4
X-Received: by 2002:a17:906:33d5:: with SMTP id w21mr8503487eja.152.1552840280629;
        Sun, 17 Mar 2019 09:31:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552840280; cv=none;
        d=google.com; s=arc-20160816;
        b=iOsGb5lI5PDfZSzibKeNcjSq4e9HcZWrTT71QZ38Ko/LmRIDk0HPVcCqjRsm/sXDWL
         pQJvcsTB+pcVkY5rP9MPlakvhOgTcY7vVO7D+4kbrkZfO13bR+DthJvz4oMUhkjhhxHl
         qIQCd9KGYDKAf3r9zTa1mNjBiboTqgyMpYkm0Y5VjqhyUxnF1d9ld2K9KnRRyRbajwor
         z5QCPn8wKj3mrIql1Qy38ni54iciTxIWkkOrZDepdpsRmsb4h+graaDHaBuTHL15OC46
         M5iXSroFCFCH+BrvGtFXYCKDeZxfKMp73zZlBeNI/6KieZmVlI/urXsLHhBlAXVq2uB3
         Zmcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zQnpH8zaNMj9f8CSWUqk/1sf91xgKsQaG3Y3A4jkMj8=;
        b=K0BSTWzIL32aGAYfjxbeSf60HYsR9u8kTJtwvmUEw9bUCGm14iaNYhpoLcoxpvISZZ
         sr29rIVsHmRUUqRK2cc9THUcz8/B6CI0toOUifZcAL9sWxo1ZjleO3U7CJtyH7icxbdF
         guQivQR73l6lBWmPcAF8q4kD9b+r5TnXV1o0sg9hN/XC6tX5ggIYGKffIDW+Q70XKP5d
         3uF462Z6IAsh86oAKPS8utUlASLsOMp6U3bcD3uyE90HcTp3dRYKmxpf4IGCACUkmt/T
         lIr8eyPlvudmeSX5ysXjnb3w6Bmi8Rs0daZowSGzD9wGuDtf53ASBTMLEv9Q0NUIhfUd
         dYqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id g1si1533841ejt.238.2019.03.17.09.31.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Mar 2019 09:31:20 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 129DB100003;
	Sun, 17 Mar 2019 16:31:09 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: aneesh.kumar@linux.ibm.com,
	mpe@ellerman.id.au,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
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
Subject: [PATCH v7 2/4] sparc: Advertise gigantic page support
Date: Sun, 17 Mar 2019 12:28:45 -0400
Message-Id: <20190317162847.14107-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190317162847.14107-1-alex@ghiti.fr>
References: <20190317162847.14107-1-alex@ghiti.fr>
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

