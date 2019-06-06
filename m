Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.8 required=3.0 tests=DATE_IN_PAST_12_24,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AF95C468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:55:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 060012089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:55:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rdCdjwMg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 060012089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 835946B000E; Fri,  7 Jun 2019 04:55:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E58B6B0266; Fri,  7 Jun 2019 04:55:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D62C6B0269; Fri,  7 Jun 2019 04:55:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4330F6B000E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 04:55:44 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id q191so529073vkh.5
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 01:55:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=7sAcFhzm9//uuWPzvmk6JGPNvQAtroDUafFgbzLm/yQ=;
        b=fqXlNpijysyp7LfS5aCyKBBupEiGtYhCx2aZJszhlZYho4ZwI6Oz5fNmhoDLuYhv7L
         ztNGSXlHAOXTE3rUdLO9IdoSJbXFCIfbesnnENi2WNF9OmHWzbUzVFCv4zQzIB/75Fr4
         1YVaHYeBMEQfCcFySMcVYC2suYWrE8yxFRU3uNu16gM1bT9c3CBbjWhSVY2Q3dVuE02n
         3cPD4rwX8L0j1hB0kiQtWe9GLml+sMHQ6cowkOVhWy5UNN119ibolw4Hxvt2qDXPiif9
         H0pZKtl90lMR0a9d/bTRkMUaYFBqL/64XY8j/cxanbA4fWye/pgK8ub5LXIsQmBbSHZZ
         rUWw==
X-Gm-Message-State: APjAAAV63Ij1YHTOerK3lW3QtiRBb9yr3XZVl6tLoan5c8IARP5Q2I0g
	jNxgcDDVnHlyJyp3cVc3O28LwlssrbdDmACCIScAhChPxKjkI///kXhW4YNHtSAgu+/sEmFuMG4
	ghv9kTmoIV2anizD2MIe0ALYwgKQL8kwc9FpUz1fc4wYnsQhJPIw5AuQfcOnxJFW+OQ==
X-Received: by 2002:a67:c78a:: with SMTP id t10mr26043057vsk.91.1559897743909;
        Fri, 07 Jun 2019 01:55:43 -0700 (PDT)
X-Received: by 2002:a67:c78a:: with SMTP id t10mr26043038vsk.91.1559897743358;
        Fri, 07 Jun 2019 01:55:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559897743; cv=none;
        d=google.com; s=arc-20160816;
        b=jOi0yvnuhjcvy8U6E8HZRhq38l2c4SgqvhkCIJYqtfshD4Jg4gVAP7YBshiKM7TWE/
         fEb3vfTSvf68/yzyokav3gM1xXonroi0fsYYJY128QheB3g1/+D32lZPcGx6oRHvRn3g
         0rbCrZf1HIQzkMfRfVfs+Co6ceu3WEVM5Bo4YTJYWS99VUmsizYfwaQOB2eAqd5J/BNp
         IuB7Io/6r5JHz8vAJiPIdm/Zh14+Gl3j2d7FXzU6g3pkWneRgBIy0BoBnzOZss//X69/
         krCJ3W9QiRj0Non3YBgA+E0vxfA6jgLmzZYeK0VKQ/eJA78oQIbnmGwMpxPMw/pYJ2Ej
         t5JA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=7sAcFhzm9//uuWPzvmk6JGPNvQAtroDUafFgbzLm/yQ=;
        b=M2vMUECt0YEMy0cOpLrK9UP4+SpkOoDiTSYUYdIzPWYo6DmnUbdJyju/J0la6xmA4n
         lFpeefrg4oSunSy4ZOV5l/Wcbk4Bo02MNpntTX+DnMmgnHTsWFU7owBElhzKqw4oAlCd
         l//wHiBMpc4z0wYN0Ci5uiX1ldytXQWi0mUhOwggdzKs7FGIdnyBj/tWMJpPMGZ+zLkg
         AyLkvCSswXAGTLrUkT6pAiaSWvGhAST0Zq+pMZKdb2JHIqwdzobCxiY7z2lWcdL92FY+
         LGRNfy6CmevRHbOedhcmPuboc2cgLF8byEioqjvxmzKWdMstjCxXAVeRTVOLlBxuE6YQ
         hPug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rdCdjwMg;
       spf=pass (google.com: domain of 3jib6xaykclexczuvixffxcv.tfdczelo-ddbmrtb.fix@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3jib6XAYKCLEXcZUViXffXcV.TfdcZelo-ddbmRTb.fiX@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v128sor312634vkb.18.2019.06.07.01.55.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 01:55:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3jib6xaykclexczuvixffxcv.tfdczelo-ddbmrtb.fix@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rdCdjwMg;
       spf=pass (google.com: domain of 3jib6xaykclexczuvixffxcv.tfdczelo-ddbmrtb.fix@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3jib6XAYKCLEXcZUViXffXcV.TfdcZelo-ddbmRTb.fiX@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=7sAcFhzm9//uuWPzvmk6JGPNvQAtroDUafFgbzLm/yQ=;
        b=rdCdjwMg3gY0shibBU1Y00zUYQIbtOM1x+c+yT+bFe7iBq5B+DoGdkjBVtzSVU+VH4
         pP96pPCG+Y973PP3O/lWES1n/UCOKtZa3RNHsidIfwLMPCrenvyWFxRyRqzXyZsOsCjr
         qSODaba6lZJocr0BUenu+4ZEbh1HblpWCFTpj73QuxvyUjbyJLZFozdmYeqn4HCfWCGh
         /AMfOsdrVXar7zg8+8htj5UxeyZr5izHf4MgEsCAHA6hwcqCH0BBWjwFe+k9QgjrSEmp
         U+n4drC9Dr/6Kek1dfT2CT1N1chYQ3TylncKuorf8JsVOifT/sDp1sYcXeCWD0MPL07+
         5kBg==
X-Google-Smtp-Source: APXvYqxl2fR/kTIk2qghgxJ9BB+AYD6tf6ZHiB+nSiWLpCvBpXZOF6k/lSrBGI83j05i6uqHwLil+lUnGI4=
X-Received: by 2002:a1f:e906:: with SMTP id g6mr514895vkh.25.1559897742846;
 Fri, 07 Jun 2019 01:55:42 -0700 (PDT)
Date: Thu,  6 Jun 2019 18:48:44 +0200
In-Reply-To: <20190606164845.179427-1-glider@google.com>
Message-Id: <20190606164845.179427-3-glider@google.com>
Mime-Version: 1.0
References: <20190606164845.179427-1-glider@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v6 2/3] mm: init: report memory auto-initialization features
 at boot time
From: Alexander Potapenko <glider@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: Alexander Potapenko <glider@google.com>, Kees Cook <keescook@chromium.org>, 
	Dmitry Vyukov <dvyukov@google.com>, James Morris <jmorris@namei.org>, Jann Horn <jannh@google.com>, 
	Kostya Serebryany <kcc@google.com>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Matthew Wilcox <willy@infradead.org>, 
	Nick Desaulniers <ndesaulniers@google.com>, Randy Dunlap <rdunlap@infradead.org>, 
	Sandeep Patil <sspatil@android.com>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Marco Elver <elver@google.com>, 
	Kaiwan N Billimoria <kaiwan@kaiwantech.com>, kernel-hardening@lists.openwall.com, 
	linux-mm@kvack.org, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Print the currently enabled stack and heap initialization modes.

Stack initialization is enabled by a config flag, while heap
initialization is configured at boot time with defaults being set
in the config. It's more convenient for the user to have all information
about these hardening measures in one place.

The possible options for stack are:
 - "all" for CONFIG_INIT_STACK_ALL;
 - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
 - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
 - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
 - "off" otherwise.

Depending on the values of init_on_alloc and init_on_free boottime
options we also report "heap alloc" and "heap free" as "on"/"off".

In the init_on_free mode initializing pages at boot time may take some
time, so print a notice about that as well.

Signed-off-by: Alexander Potapenko <glider@google.com>
Suggested-by: Kees Cook <keescook@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: James Morris <jmorris@namei.org>
Cc: Jann Horn <jannh@google.com>
Cc: Kostya Serebryany <kcc@google.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Nick Desaulniers <ndesaulniers@google.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Sandeep Patil <sspatil@android.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Marco Elver <elver@google.com>
Cc: Kaiwan N Billimoria <kaiwan@kaiwantech.com>
Cc: kernel-hardening@lists.openwall.com
Cc: linux-mm@kvack.org
Cc: linux-security-module@vger.kernel.org
---
 v6:
 - update patch description, fixed message about clearing memory
---
 init/main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/init/main.c b/init/main.c
index 66a196c5e4c3..e68ef1f181f9 100644
--- a/init/main.c
+++ b/init/main.c
@@ -520,6 +520,29 @@ static inline void initcall_debug_enable(void)
 }
 #endif
 
+/* Report memory auto-initialization states for this boot. */
+void __init report_meminit(void)
+{
+	const char *stack;
+
+	if (IS_ENABLED(CONFIG_INIT_STACK_ALL))
+		stack = "all";
+	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL))
+		stack = "byref_all";
+	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF))
+		stack = "byref";
+	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_USER))
+		stack = "__user";
+	else
+		stack = "off";
+
+	pr_info("mem auto-init: stack:%s, heap alloc:%s, heap free:%s\n",
+		stack, want_init_on_alloc(GFP_KERNEL) ? "on" : "off",
+		want_init_on_free() ? "on" : "off");
+	if (want_init_on_free())
+		pr_info("mem auto-init: clearing system memory may take some time...\n");
+}
+
 /*
  * Set up kernel memory allocators
  */
@@ -530,6 +553,7 @@ static void __init mm_init(void)
 	 * bigger than MAX_ORDER unless SPARSEMEM.
 	 */
 	page_ext_init_flatmem();
+	report_meminit();
 	mem_init();
 	kmem_cache_init();
 	pgtable_init();
-- 
2.22.0.rc1.311.g5d7573a151-goog

