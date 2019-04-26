Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 990FFC4321A
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D5FF208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qfcv0jVy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D5FF208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 332076B026A; Sat, 27 Apr 2019 02:43:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21EDE6B026B; Sat, 27 Apr 2019 02:43:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04C7C6B026C; Sat, 27 Apr 2019 02:43:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id D704D6B026A
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:22 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id p23so4901523itc.7
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=yNv4uuWY37+QDIo+8eJ5Cs1RQKFygWuhu/mUpTFc+50=;
        b=r+fuLtQaqCYnkGPj7mv+XlxKjEEp6a9cXsQXvS7FNd2wf59zsQjVovhLQ2W32L2XoD
         HUo44LRRWFk3B0H4PGkd1jmBnXDVFEo0bairyCpS5+1WwMwcMguXyPx2QQr1B/F81npE
         0y5FpBjbulxyMJYhl0fgnXkX0yq9JXbPOg7WP+jiCx8x7Rmq+Z89MJoSDGFqCzadJC/p
         lWHGXHsKLqomzUNh/kf/hMupiJ0W988gSU6B441uoU9da0e8nkStDwBSPJhRkK6C3ls3
         kfuOCzKKZnws/XqHe7d0sGo6MdnnrLxbU0FRIHO8jNsQ5ZXch5Gro5LFaAC73sshtGNH
         aRTg==
X-Gm-Message-State: APjAAAXwGlxWWh9cCAht/FQP9Kvx1rRteoLF9HNFjJ8K6Nn1Sa7fZO2O
	oDmWkrXy1OdGGDUxRF4XTSyvewy9oXUg6OwRV0tIfOBptni8I4+ipUKkEbjemdPMvA7cGL0LKRJ
	CFOtUoIXj89LXVR+z8HYMN7IajcEqKy1+4YJs5YPx4BTOeGgTMYl3wBfwv6T5iyjXvg==
X-Received: by 2002:a24:f8c7:: with SMTP id a190mr10805151ith.72.1556347402565;
        Fri, 26 Apr 2019 23:43:22 -0700 (PDT)
X-Received: by 2002:a24:f8c7:: with SMTP id a190mr10805121ith.72.1556347401264;
        Fri, 26 Apr 2019 23:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347401; cv=none;
        d=google.com; s=arc-20160816;
        b=wlN4H8Q48VuEb2TmuE5Mbr0lGmh+bGAJI/OuP9ignJhPRHzEPIMsg2aBIe1MX1LWML
         RKceN9IcrSLyJROyrLomulNpbOBRgKX7LysQbC9bfwkumVeP1D8LyQvXmFAI3AHK0ddt
         bbRWb9rYz86zej7GBmS9CbOn99BvnBTpFpkBPQkNYGpVUZi6we7DWxhz8etUTW9S+xAB
         n9qreGioHp9/j6XcbLWrsQzKeltYuNWBjgkokOF4hvzZMpOC+jsbqVxD+j07HgsKKY10
         0W0MUfBd4bHLwfooSv+/+YvOL/r/lw76pXGtMR2rcCURvp8zETSkNKEoWjJXR+0bTpE2
         XwYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=yNv4uuWY37+QDIo+8eJ5Cs1RQKFygWuhu/mUpTFc+50=;
        b=E2CkCn+DAMmsWvLzV5GP1rwODgXOTt1Muy81wbkCLDjuWlI41g/J65q8zZqWYVv9bI
         dZCkR049ikc4t4jOFnhmaDkoRFhTnpa/9ZEEUIAomkJNs2uv91KQYomOmF6RJum+3k6P
         AfB7pky09B9kQcP5oXcV7in1C7RYOxSfbm9dUczGdpwkEADXrDrHxVmOOWVcvRrWKCwZ
         cQQ1Wle/1W+IR3xiSYVF6TkHt5slW1uenknOSqQW4tcyWRHjVFXcvRmXRPdF18OLigy9
         zGfuUcY+qyQHt7CbrnA1Gh89gcNYPm3EiujhMYhDVnD9eAT6ko+FG8O3mU+A+DOb6O4S
         ivNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qfcv0jVy;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s135sor9184478itb.9.2019.04.26.23.43.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qfcv0jVy;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=yNv4uuWY37+QDIo+8eJ5Cs1RQKFygWuhu/mUpTFc+50=;
        b=qfcv0jVylRwgUSdFp0yVo6y3SoCAOjol9XbR7W5+lwraaEg2QoXyt+VrAjGp9wzdAn
         BOm9G9cC4mrsWbrKkWfeWua0CLcUhNFX2UYmr160CAGJNRPhpKunjycWCJnpjaUptQXK
         FymoezD52jYoCa9vw1d8DrTtNcDpUD3gesH2ZoYEwsgq0bZE6tTukM9zPOscjJPRRiHd
         0d0EQKT1ASnMLtYxkgiq4MVCWAUZf/kjKC/u6ibFbPlbEhDhs/jBfSTvPAadE2T4MBPs
         yoHMRLVUDfJJ0O31Q2uS3OPiszz2lAVHUHfzcDpTk8KxpsBn4aqr0vTCALbdk7a/EPYd
         2uWQ==
X-Google-Smtp-Source: APXvYqxCgMCnuubydaHXfJIDthz2u46RkKoNrhpM9xg9spe5Zm1Eq7YBRg8tloTlDMLwvkBDrQMPvQ==
X-Received: by 2002:a63:7f0b:: with SMTP id a11mr44847434pgd.234.1556347400564;
        Fri, 26 Apr 2019 23:43:20 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:20 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 11/24] x86/kprobes: Set instruction page as executable
Date: Fri, 26 Apr 2019 16:22:50 -0700
Message-Id: <20190426232303.28381-12-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Set the page as executable after allocation.  This patch is a
preparatory patch for a following patch that makes module allocated
pages non-executable.

While at it, do some small cleanup of what appears to be unnecessary
masking.

Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kprobes/core.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index a034cb808e7e..1591852d3ac4 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -431,8 +431,20 @@ void *alloc_insn_page(void)
 	void *page;
 
 	page = module_alloc(PAGE_SIZE);
-	if (page)
-		set_memory_ro((unsigned long)page & PAGE_MASK, 1);
+	if (!page)
+		return NULL;
+
+	/*
+	 * First make the page read-only, and only then make it executable to
+	 * prevent it from being W+X in between.
+	 */
+	set_memory_ro((unsigned long)page, 1);
+
+	/*
+	 * TODO: Once additional kernel code protection mechanisms are set, ensure
+	 * that the page was not maliciously altered and it is still zeroed.
+	 */
+	set_memory_x((unsigned long)page, 1);
 
 	return page;
 }
@@ -440,8 +452,12 @@ void *alloc_insn_page(void)
 /* Recover page to RW mode before releasing it */
 void free_insn_page(void *page)
 {
-	set_memory_nx((unsigned long)page & PAGE_MASK, 1);
-	set_memory_rw((unsigned long)page & PAGE_MASK, 1);
+	/*
+	 * First make the page non-executable, and only then make it writable to
+	 * prevent it from being W+X in between.
+	 */
+	set_memory_nx((unsigned long)page, 1);
+	set_memory_rw((unsigned long)page, 1);
 	module_memfree(page);
 }
 
-- 
2.17.1

