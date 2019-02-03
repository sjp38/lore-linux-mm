Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50B47C169C4
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0BF4218D8
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0BF4218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=decadent.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56F018E0023; Sun,  3 Feb 2019 08:49:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51BC18E001C; Sun,  3 Feb 2019 08:49:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40C3D8E0023; Sun,  3 Feb 2019 08:49:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD8DA8E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 08:49:44 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w12so3804750wru.20
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 05:49:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-disposition:content-transfer-encoding:mime-version:from:to
         :cc:date:message-id:subject:in-reply-to;
        bh=OKgnfPZs1x522YtA1gVvrOy6dGcXxHe300kvm90O9Vs=;
        b=TM+MFu4g2b2k/EKo1iXZ0DDYrnmCAndTif4Rs5krOU0nNUh9OCceBmcJKJi19UYDL0
         JbzMEMJcs20u8U26NZs+ABC8CVu6kBI33BayYWUoJS5lC4zANArODtRa4LRiIyiWI0Z2
         M3/MQCUNlfug4acbkBZw/pmGn6TP0F8KFBCBg967gGF6Wy/qCsAlDn1FKZhcoBifi6XY
         CGK3QCnNTAtiQhLOjDdE445zV8T1dx4j8tPxbxFyNk8cr3nG8nWbj6WvmL76QA9A/UMd
         s14nrUm3U/XCjoUjqkOK2v9OYWBhyRcmubYCiekMcR6gjk7DaLOJB38eAmbUMpmtHePG
         W3TQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
X-Gm-Message-State: AHQUAubyra+xKqLQvAY2G2qyQE2Ff9I4oQxc7awaQVhKm8HJfQaLBo5s
	/eZ9ORlb+Xno3CBef2Sa/Xp5LuaCXtTMsKkFhAE+pT0LAER3atPXkM2ROjLkzA0BIWVL5D+1/2l
	I/8PLgBb+jpd6EkUBJ8NDVHFuzln1p6UDubeVlSuM6m9h/KQRDmuG9A5ShBgedQsdUw==
X-Received: by 2002:a1c:a895:: with SMTP id r143mr9308954wme.95.1549201784333;
        Sun, 03 Feb 2019 05:49:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ3tZ3w835v9WzIl2PXaX5iy8JLHaL3PgUsx/SOjlyzEN/t/QyNfO43Gsq6Jp4uttSmjd9J
X-Received: by 2002:a1c:a895:: with SMTP id r143mr9308907wme.95.1549201783206;
        Sun, 03 Feb 2019 05:49:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549201783; cv=none;
        d=google.com; s=arc-20160816;
        b=FThILP2hpgZcNQaxzhkPfqNJHfiTS3haA24mh/ctXNlZoV5aPpMJHF0GxbtO3uBvw8
         rOt5m1ACivJHvu4GG3y26SC9MO9qzmKmP17/no5U2gsfMio9pUWZWwhTqKxnkoRo1usD
         ms72WTssu4jjQ2aKbOolDV15CQi0inHzTfmF979su7nnXVle0dbHryhS40fo9QuwU9z0
         bs+HCz7A9awwAo2hlcKUI8jQJqS53qwTCiUF6tiptuFSKW6sKmBLXN0Fmr420bQ+HgLA
         GLp7x1+KOW0LvE9Af4IYPTpPX/cli8XYKB8y9rI8sD8SD6jY6BQPBgL85oArWzr7smbl
         2ofg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:subject:message-id:date:cc:to:from:mime-version
         :content-transfer-encoding:content-disposition;
        bh=OKgnfPZs1x522YtA1gVvrOy6dGcXxHe300kvm90O9Vs=;
        b=ZBhBcPQFJJOZmllKJW0eE6Jbet8YnPMjHCnA51erZ34FBacLdhruwEtyJEDvofxpt9
         BKKujbIEroU8AlO6UDZuHac/2FAhbMpOnj+5/TzKWoM66xxJGfztpAjgpGMHHyxHXz1p
         lEoQDX8olcPFWbxvIZ1XPSbfls1IDP0t5dZXU+zYxkF152yaEXseYTiKIEL498ccYM0e
         CLe52aDaLaKeV77XOnGcmib0fNVJ5mT/uaBFGNSLNfO+NuVTmkEvbsjAvM5DwsWe3+bn
         Uy040uB58u1Cx4Xfb/zFsi7tSk/OxErl/bETAnoLX82lhaFg7uzx243DgwUspT1Ucxat
         NHxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id n5si9529417wrh.320.2019.02.03.05.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Feb 2019 05:49:43 -0800 (PST)
Received-SPF: pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) client-ip=88.96.1.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from cable-78.29.236.164.coditel.net ([78.29.236.164] helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.89)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0003ti-3t; Sun, 03 Feb 2019 13:49:39 +0000
Received: from ben by deadeye with local (Exim 4.92-RC4)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0006nA-CG; Sun, 03 Feb 2019 14:49:39 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
CC: akpm@linux-foundation.org, Denis Kirjanov <kda@linux-powerpc.org>,
 linux-mm@kvack.org,
 "Ingo Molnar" <mingo@redhat.com>,
 "Juergen Gross" <jgross@suse.com>,
 "Konrad Wilk" <konrad.wilk@oracle.com>,
 "H. Peter Anvin" <hpa@zytor.com>,
 "Thomas Gleixner" <tglx@linutronix.de>,
 "Wenkuan Wang" <Wenkuan.Wang@windriver.com>,
 "Robert Elliot" <elliott@hpe.com>,
 "Borislav Petkov" <bp@alien8.de>,
 "Toshi Kani" <toshi.kani@hpe.com>
Date: Sun, 03 Feb 2019 14:45:08 +0100
Message-ID: <lsq.1549201508.355567159@decadent.org.uk>
X-Mailer: LinuxStableQueue (scripts by bwh)
X-Patchwork-Hint: ignore
Subject: [PATCH 3.16 002/305] x86/asm: Move PUD_PAGE macros to page_types.h
In-Reply-To: <lsq.1549201507.384106140@decadent.org.uk>
X-SA-Exim-Connect-IP: 78.29.236.164
X-SA-Exim-Mail-From: ben@decadent.org.uk
X-SA-Exim-Scanned: No (on shadbolt.decadent.org.uk); SAEximRunCond expanded to false
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

3.16.63-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Toshi Kani <toshi.kani@hpe.com>

commit 832102671855f73962e7a04fdafd48b9385ea5c6 upstream.

PUD_SHIFT is defined according to a given kernel configuration, which
allows it be commonly used by any x86 kernels.  However, PUD_PAGE_SIZE
and PUD_PAGE_MASK, which are set from PUD_SHIFT, are defined in
page_64_types.h, which can be used by 64-bit kernel only.

Move PUD_PAGE_SIZE and PUD_PAGE_MASK to page_types.h so that they can
be used by any x86 kernels as well.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Juergen Gross <jgross@suse.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Robert Elliot <elliott@hpe.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1442514264-12475-3-git-send-email-toshi.kani@hpe.com
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Wenkuan Wang <Wenkuan.Wang@windriver.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/x86/include/asm/page_64_types.h | 3 ---
 arch/x86/include/asm/page_types.h    | 3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -20,9 +20,6 @@
 #define MCE_STACK 4
 #define N_EXCEPTION_STACKS 4  /* hw limit: 7 */
 
-#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
-#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
-
 /*
  * Set __PAGE_OFFSET to the most negative possible address +
  * PGDIR_SIZE*16 (pgd slot 272).  The gap is to allow a space for a
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -20,6 +20,9 @@
 #define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
 #define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
 
+#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
+#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
+
 #define HPAGE_SHIFT		PMD_SHIFT
 #define HPAGE_SIZE		(_AC(1,UL) << HPAGE_SHIFT)
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))

