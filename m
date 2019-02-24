Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FD38C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:34:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AFB0206B6
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:34:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d2Y9Cztq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AFB0206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E40B78E0161; Sun, 24 Feb 2019 07:34:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCA268E015B; Sun, 24 Feb 2019 07:34:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6C0A8E0161; Sun, 24 Feb 2019 07:34:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 810208E015B
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 07:34:52 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h15so5522817pfj.22
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 04:34:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=6zZP7jJIxHvkxThoQW962w7WsAbjwnHfV/pBRova8jw=;
        b=hQ2oipgAp+XRMyzBUa0yPAe3X8ZVr/4rmEOHh2zQ/S2IzuTBkeQsOEDu6eMrEmZ3pr
         VVBVEg6CoKF/iOaO9lUYozKwqEc+0o2F6z3fuI9PK8fTFfuMaVXS7TecpySMxWe2vt3i
         phd1LZsnii7Q3m8liYRp4USeXCjgmxvai1MeCppsnRVcfwWrALFoBNIeq4U5nd6SQC41
         nDrHlqAjFoOJ2WXqlijW8qGksqVgLa5W1H90OxjoBQPq5y4XKiD/VNEkUqp67ICmoxvW
         5Wsqjjr5gdhXH7Es5NWy2k9VBmFdd1Gpj0zKv5/kKCwOJ7rqzd9ngrpWcK2NEurhzhIG
         1kfA==
X-Gm-Message-State: AHQUAuYzgYdTYMWL2syvKUHbmyU+V4/oH4TDt6dCnzbYXCIt/nIspvcx
	WahTCUWCFUW3GqHkdicuQDiDC6UP8QzMn4Lnvw0ESsxScbFwYRyKeftJy5J7aXPh0I8B/rIfnFB
	qJAZK6Qh5rpjvOKisGhyrQQccBOKx4lkySF1NLDQrZd5llw+5DxVj891DQwqBI2aD9Ledw+9J5B
	HiL1cB7H7drZsZiO0hf322sbhPCgbXYs40oH6d0vOwBUJK0gOP4Cj3X6p/wTIgXR/mXyLqdh/tj
	wEhRg9p4yZklS31vjAlIMkwJmThHteI+AKN3zgCJd7Tlg0sNigUy2XlGtZszxPah/mDLZ8i0fQ7
	b/PudvPVWsLmC9necFLUj5MTzsZX1DazFo7De0BlzIAnlTjzm+Nl5gMfHFHUm1tARASd0drJV2m
	w
X-Received: by 2002:a63:81c1:: with SMTP id t184mr12447541pgd.228.1551011692200;
        Sun, 24 Feb 2019 04:34:52 -0800 (PST)
X-Received: by 2002:a63:81c1:: with SMTP id t184mr12447435pgd.228.1551011691024;
        Sun, 24 Feb 2019 04:34:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551011691; cv=none;
        d=google.com; s=arc-20160816;
        b=TLefgWNPSCntLSCwOrjsY16Kzega75IZiuf04c8Fl+bpkA27LPK7rOCX4fLrdm5oFg
         231jYOLsH23V6CLTZ6uhK3VZUejz4l7ns44wCjFRCNl22XiiDw05Wkjj20ASOInlqn4P
         bhAuIVE6x3UBhgVAoXt21I/8ngNcypgHA6nDvH2aoufl8u7sGCAwTV0CZNrLF6qzlgvR
         I3wXxBTkUFdpm2Sud1+FLH+jP5mVQAM26aBH5ZCS6lAcQU2TU8w93Mj8ZV4ZRkVAF9He
         iIWVCh5WC2KlH8UbNYWnI9be4l88/IXPpXcyFW2nnVpYgrtiiQ57RbDL2+CV0a8SAXYt
         Q9Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=6zZP7jJIxHvkxThoQW962w7WsAbjwnHfV/pBRova8jw=;
        b=SDPda2KXL+Tk91JRBqQkigVxmF/lkJBvgFN8UHOuR+JpGKfz3IKbWQdWMrq1+F1O6Q
         5pg4xXwLhX3j0HuGWE/sugisBMpTvDGmDAS2E5GXLE8SErOO0COT/zB+QivMQyXlagQC
         uvgrlObsutOdjwqG4oujm0QUjlQkGxuD/yGNmgUadjJ+1ioH8ucqTXECnfri5r961ynt
         5aUgtqIAq4gewg/H/e48+fhSoT6M+fcwf3Au0z/DH0U096vxzGVCErXMAdqOebiT9DyV
         3Es0Q1TY8wCXrrcDVDKKnsrBl8OA8ngpejNRGwuKMuQLX4DIq4TtAePQWcgRcnrXpLTm
         lWHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d2Y9Cztq;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p85sor10741149pfi.13.2019.02.24.04.34.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 04:34:51 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d2Y9Cztq;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=6zZP7jJIxHvkxThoQW962w7WsAbjwnHfV/pBRova8jw=;
        b=d2Y9CztqZjtQy4UJJ2JLeCM2Nx1Rp0TIqG0sLvJJYN5BBmdxAbZAT0PO0MGPvOBgPJ
         cFZu9aubJse8xqxOe5l1Xl2/EALdbw0IPYh+iY2GImLvNo17BST6hP7RynsjNDzhyddH
         qhfJhKoAKpiJWnJVa0Oi8kx8W14Zsu9Ye++4TnFw3j7YP0wdp7mEHEnsoSYRSFEJBAq8
         R17q+wTIJus3kgWzBtoUF3/LA8pksbAMFTZIRJqyk3BMnu+WvqepNntYMwrzyM8gA9Lz
         nVlGBNhhPVlsG25Vr3nRF3eng/nAEOfwSucaWWiO2sKlf5YFM0rt/ikuWtVDmVvfA7tO
         Q3cw==
X-Google-Smtp-Source: AHgI3Ia8g+BD78ii73yBVfLkrh2EIZUmMEN2tSL9/vXwv/TCm70uYK4mRBtcqN5KpkpAfPfIcCdM4w==
X-Received: by 2002:a62:6e07:: with SMTP id j7mr13978322pfc.135.1551011690757;
        Sun, 24 Feb 2019 04:34:50 -0800 (PST)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id v6sm9524634pgb.2.2019.02.24.04.34.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 04:34:50 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
To: x86@kernel.org,
	linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andy Lutomirski <luto@kernel.org>,
	Andi Kleen <ak@linux.intel.com>,
	Petr Tesarik <ptesarik@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Jonathan Corbet <corbet@lwn.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Daniel Vacek <neelx@redhat.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/6] x86/numa: define numa_init_array() conditional on CONFIG_NUMA
Date: Sun, 24 Feb 2019 20:34:06 +0800
Message-Id: <1551011649-30103-4-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For non-NUMA, it turns out that numa_init_array() has no operations. Make
separated definition for non-NUMA and NUMA, so later they can be combined
into their counterpart init_cpu_to_node().

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Ingo Molnar <mingo@redhat.com>
CC: Borislav Petkov <bp@alien8.de>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Vlastimil Babka <vbabka@suse.cz>
CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Joonsoo Kim <iamjoonsoo.kim@lge.com>
CC: Andy Lutomirski <luto@kernel.org>
CC: Andi Kleen <ak@linux.intel.com>
CC: Petr Tesarik <ptesarik@suse.cz>
CC: Michal Hocko <mhocko@suse.com>
CC: Stephen Rothwell <sfr@canb.auug.org.au>
CC: Jonathan Corbet <corbet@lwn.net>
CC: Nicholas Piggin <npiggin@gmail.com>
CC: Daniel Vacek <neelx@redhat.com>
CC: linux-kernel@vger.kernel.org
---
 arch/x86/mm/numa.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 1308f54..bfe6732 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -599,6 +599,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
 /*
  * There are unfortunately some poorly designed mainboards around that
  * only connect memory to a single CPU. This breaks the 1:1 cpu->node
@@ -618,6 +619,9 @@ static void __init numa_init_array(void)
 		rr = next_node_in(rr, node_online_map);
 	}
 }
+#else
+static void __init numa_init_array(void) {}
+#endif
 
 static int __init numa_init(int (*init_func)(void))
 {
-- 
2.7.4

