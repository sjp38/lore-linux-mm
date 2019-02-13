Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AD03C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DAF3222CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PL+qO4BS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DAF3222CE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6DFF8E0006; Wed, 13 Feb 2019 17:42:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1C648E0001; Wed, 13 Feb 2019 17:42:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0B618E0006; Wed, 13 Feb 2019 17:42:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 476CF8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:15 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id s5so1404387wrp.17
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=ktrl99/4+i4VLz6USppssXo49kPq9nmcbGTF0KLoSBQ=;
        b=WPqPFKDQV3JJ+TDgA76JEHkrzpGat3dtg9u+IKXuVwKRqYLoxlQ2MDIhujHE3tttJR
         Ia2oYZWMIx92JfL/An9A5b2PsIMNMqT/hZP8tAAxQ6b7mC0ge14PhM9ZTSUZ0Y5Ok1kE
         T8gn9LfnZxtbTWQWXtQhpGSBxDnUegi3nc88Dt3wKoWQs9iOh1Z54e8YzQSx4+byIOsP
         VRlkYqR7+cjDF6ZJ9MCZNT+xMafXDcmsgvIC3uwNYD4bwSj+p/UJ4E14nnijkqO6Pfgi
         WjattkpMq0QHOFoTPBM0dYp4/VDL5HWrVaUgGRprd0QmKzhJNuTrYjnJ3pyYKo34r/+y
         Olyg==
X-Gm-Message-State: AHQUAuaLe0zJ1LPEVl64ytkHFmehZjk73jrXEPuOWNPrm781hUcp1FQ9
	FEuNEHVMq4jAE9mG9C4M+fZWmtEHgqZjIwyiLrhah9O4li/A0xJeUrAecd1sjqHnlxQiZCrs27W
	9JlADs7FWLOUUJGY50cK9GBpGdRYXA35zBXp2Rr4qbSQONpUX26epQF2jR0iqebkKoWGO1ZhIOM
	gglNdh4SO6ucSLmJcnCy8XWbxs4FuBkLOyi98Mmr3nffbz5oRyOSlMRoL8H4yi2yvotZ2jGqQib
	qmhnkSs+9Jtk5mgLK81R+a8AGs2qBcxhfQ4eDoCnv3KKM9X61/Vvg9u2Lz6vQZYB8YCDPwvM5q5
	CrX+FEqG+YV73UwDdWT140j9hCdSk9RRc5y61SPEDtIaMFf/6If1Y/p06Ist7zEHEpj2zbvzaam
	W
X-Received: by 2002:adf:dccf:: with SMTP id x15mr265362wrm.309.1550097734818;
        Wed, 13 Feb 2019 14:42:14 -0800 (PST)
X-Received: by 2002:adf:dccf:: with SMTP id x15mr265324wrm.309.1550097733753;
        Wed, 13 Feb 2019 14:42:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097733; cv=none;
        d=google.com; s=arc-20160816;
        b=Iunf3gO/q1x4BCwtnFHWOlufww9Tpsw0uGcR4+TUvhZqFz6o2Cbuk6XWvKOAvxTeNk
         m2LP0Rdot2PEx8N6QB1pcDSFkbhkOQrlROvY2fwgW+y++Qs0YnwW77f2VMwF9mgO+K8L
         kVwMs6UtlgU39l5Ke+y6XA8FqNiyTa8ahvsO1+VOkSpChcZakrO/ykfMpKjst8NAWwGV
         tfItf7irbPCFQmAi68+VcqRUdpDy6Wn5lkZ0vt5WPnBT6XmMtZx4Tn2YiYKyw/JcxE8l
         cH5Jo6RHWjlcnYvhGmFlgi8sch9v1TiEtgMB/IXmoB4Qo+W2zab9j8uuoVQ8EKqyi4du
         ENtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=ktrl99/4+i4VLz6USppssXo49kPq9nmcbGTF0KLoSBQ=;
        b=lVk21soFr6NhkQ+bzJCdIYL/6gbeiyVKt9gk9iHVPTb9YwQ8YV8s8g95tQzgbJ6U+A
         ZvBe5qj9BcS4E/4DL/lprw+yOKItLT+uzZfOAc3C27rwYkHl3774otjeqESG3gB3xv3B
         rLCCu95sbywl0Hw3rcpxrpwia0PIKs+sgo79iCRAHWzoqFESJ47SH6fBXpVhXRHtGqwK
         AMaJO3/2A7uPuFD1QEt5zOFr/iobah9jL8atui3l4xxH+x0n54rMr8cFFsqLu/iY0+KR
         WKQz4/o29BYWZZSB/9qnqoPwD/H4qdlucdrqt81C3rvK/dISDACsruRZsvMC83hjGLlX
         ycSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PL+qO4BS;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 71sor369955wma.20.2019.02.13.14.42.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:13 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PL+qO4BS;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=ktrl99/4+i4VLz6USppssXo49kPq9nmcbGTF0KLoSBQ=;
        b=PL+qO4BSrqbTBZVvQdKVfuy3/R+TSzmQVsSmPWSD0nYfCQOw4/ftFDGqeAZGSDmsrD
         gp5dGhCLQjbXWBv2zPEel7ZGbFiiHXKIek08yxjbI/8bRXIXLDgV3glT33iw2UZwlzF6
         ZWtW7gYc5MVUhpPAtUuhRfoed2qyAVf+Nntc5wC3H4/s2pYobeRt0viKWP7Txq5JAUgK
         zb27BPlMpvk46SWw6eK2V2YyFXBJnAP8jjBEEB5li9V5UUDTFf3bDWz8iq6hJrbY/pXp
         KcT+ffr0v8t9+4SCEJMuLmWpGXbPjoJa2FgJQJ6vmf7fAQnr6F1cclKwU046m0j6BDC+
         kczQ==
X-Google-Smtp-Source: AHgI3IZgZPIjnSp/dGfR7iVH0dIRhuCCwStYtqJDhnVvkktzfFNDDUM47bqA//xCjlNKL+dEg6bIOg==
X-Received: by 2002:a1c:a58c:: with SMTP id o134mr259360wme.79.1550097733324;
        Wed, 13 Feb 2019 14:42:13 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.42.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:12 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 05/12] __wr_after_init: x86_64: enable
Date: Thu, 14 Feb 2019 00:41:34 +0200
Message-Id: <c5838cd211a1648f44e0c2f48ab5bcbc1387cb8c.1550097697.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1550097697.git.igor.stoppa@huawei.com>
References: <cover.1550097697.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Set ARCH_HAS_PRMEM to Y for x86_64

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/x86/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 68261430fe6e..7392b53b12c2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -32,6 +32,7 @@ config X86_64
 	select SWIOTLB
 	select X86_DEV_DMA_OPS
 	select ARCH_HAS_SYSCALL_WRAPPER
+	select ARCH_HAS_PRMEM
 
 #
 # Arch settings
-- 
2.19.1

