Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E6E4C48BD8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:19:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B09D20663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:19:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="syWBPxEF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B09D20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C21D56B0007; Wed, 26 Jun 2019 08:19:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAAF78E0005; Wed, 26 Jun 2019 08:19:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4C268E0002; Wed, 26 Jun 2019 08:19:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 840C46B0007
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:19:58 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p34so2644100qtp.1
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:19:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=OTM/dBWKP5pXAZwQDJU1YbjuxxUPU+6Vr1IAcbjuDVo=;
        b=VW9n7OkRHo3+bUwppd7bcdF1H+NTc7S+7XK1xZL3Jxs9v68FBBwuIcnF7WOpV0sp9W
         hfu9OTaIOj7Tz6xRmMqu65aIBlkmxBEQrSEzbRyytOIaK5pUhKLQ+um5ZN/uNg0Zy5it
         +/gA5/Rl5j9crPQ86TJ5nZ8WnkTJPHdmiOXjEnMmTYn3+XAHdDWk9b0ruf7we0pFZkSr
         5xIqU4pjVj8qUQVpbgEx1l5IVmDhL0O891Qj+fEBG87dTp7pChjZ0YAsIr2U4pR7zhUu
         MhXJwCeqB4LweA/RUz8ALDoR9ADo1sf21bNMjVWglKDj3VlCf3XdyoSi2vwX8jQvd7Qv
         72BA==
X-Gm-Message-State: APjAAAW1CRsUU3k9yMUslNkSurfguc7gYNH1dnSH5Cg4zwTqYwNQlTfc
	f4zQpjgOL3xoqFP+2BNEEprfwSks0VfFMhr7TLhGounLpCxmVP7qAye9EvybM1YD76JbchYPgJq
	2WZqH+2lgvp9mpOXw2AKFzgteUepfOqQvKG5yj5oeD+KrN67HhZwDSjWQEnc23VT3hg==
X-Received: by 2002:a0c:fde3:: with SMTP id m3mr3174935qvu.205.1561551598304;
        Wed, 26 Jun 2019 05:19:58 -0700 (PDT)
X-Received: by 2002:a0c:fde3:: with SMTP id m3mr3174884qvu.205.1561551597661;
        Wed, 26 Jun 2019 05:19:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561551597; cv=none;
        d=google.com; s=arc-20160816;
        b=X+CUARGhUIjYjUDbk2Cu3YdU64SqW8OqsWp+Hn5ulNXxhB38S5Wzf7kk7mKmL8Kh7x
         xwsbgtD1mOUrO6Ru5aW7nAvT9Y8mOw2re5LnOJvrrw94TfHyWrVGfxoWtFvfQEDnMHJ7
         gxbU/NI055BJy8QBCjQqec5Snvp5Qh20InUMNTmx+F7tvG89RsHMqIEec7YXh5FVJDnO
         fcGcdL4hYrF0j0Vhzx6ZT+lJ42ocl8tljEVo+T6/sdG2Wir9v7kpcrc6QMne7vlac1AC
         LAO/FN390LRJxZV0J6XD7Fuk5TPdfRHfADUhS9NW/9JkaGRM35Smyvtv7wYiVbQNnYRN
         uHaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=OTM/dBWKP5pXAZwQDJU1YbjuxxUPU+6Vr1IAcbjuDVo=;
        b=xQhJTZhCwHjtc8vITRWHTsDbHcbdyL/wg8Jm2eM3utQ5+pDrw4W5N0iOhPRtM66PTW
         mk872R0/BRqv78KiS7dwJYc9AJSwqVZiS5AfP8PES6mCXWKS2wiP+xH7zch1L03tB30g
         PhmYr5pa70J6gpOwK4f5r/blvXjwmkb8bYHml4dNg7oV8TNCIQR14LGTZAj2025HUYm3
         AWnDVi+lEwc49a+AH9brLULEPVa2rsGIAKf3IzeXKw29uxyBlNc9Lx/JNFTiz9spy06n
         h9lCjduFu70/7oWm00TjLbkYe4Ue2TnrlZ3fINl4UMzB1ExuFVXbWV2vmkiCdP6cDh0y
         B02w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=syWBPxEF;
       spf=pass (google.com: domain of 37witxqykco4wbytuhweewbu.secbydkn-ccalqsa.ehw@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37WITXQYKCO4WbYTUhWeeWbU.SecbYdkn-ccalQSa.ehW@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c19sor24257244qta.34.2019.06.26.05.19.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 05:19:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of 37witxqykco4wbytuhweewbu.secbydkn-ccalqsa.ehw@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=syWBPxEF;
       spf=pass (google.com: domain of 37witxqykco4wbytuhweewbu.secbydkn-ccalqsa.ehw@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=37WITXQYKCO4WbYTUhWeeWbU.SecbYdkn-ccalQSa.ehW@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=OTM/dBWKP5pXAZwQDJU1YbjuxxUPU+6Vr1IAcbjuDVo=;
        b=syWBPxEF/AbUhjRgTsNM2BYGj8YN2ayZPfWd2w0N+baqMKNfmYDs3psuZ0fJjnmvMK
         8B80Kl55p65EioVsUup+/eJYiZoERn8ga+Ns6c8t+e2zM7fUtewfGAHKbcaepfj3mAsr
         QDYudk4+4uSvXCjPULthVBmohV475Bm8+ZhVje7oM5PmZGgjo7DE2HsqOMPOW4xrVkTr
         suPz43xTls29ETSlHXpdKVUnGVPjARGFKxRIeJ1NGVFoH/UeP6mtPjuDCmrixyWKwNuX
         dNHHr1RlVkLXy0tuKRZLLgBhBdhseNxqCUhMQXCsW1fuymDJCTA4whMM/PyKBDoZy05/
         Qsdw==
X-Google-Smtp-Source: APXvYqwJ6l1H8lkFtTKpfdzkClk7tEj5d/8h25zPgByAql9o2QQ6HmyKzhgUAkYCGmo80dn12sSTVp6qisQ=
X-Received: by 2002:aed:39e5:: with SMTP id m92mr3381054qte.135.1561551597192;
 Wed, 26 Jun 2019 05:19:57 -0700 (PDT)
Date: Wed, 26 Jun 2019 14:19:43 +0200
In-Reply-To: <20190626121943.131390-1-glider@google.com>
Message-Id: <20190626121943.131390-3-glider@google.com>
Mime-Version: 1.0
References: <20190626121943.131390-1-glider@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v8 2/2] mm: init: report memory auto-initialization features
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
about these hardening measures in one place at boot, so the user can
reason about the expected behavior of the running system.

The possible options for stack are:
 - "all" for CONFIG_INIT_STACK_ALL;
 - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
 - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
 - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
 - "off" otherwise.

Depending on the values of init_on_alloc and init_on_free boottime
options we also report "heap alloc" and "heap free" as "on"/"off".

In the init_on_free mode initializing pages at boot time may take a
while, so print a notice about that as well. This depends on how much
memory is installed, the memory bandwidth, etc.
On a relatively modern x86 system, it takes about 0.75s/GB to wipe all
memory:

  [    0.418722] mem auto-init: stack:byref_all, heap alloc:off, heap free:on
  [    0.419765] mem auto-init: clearing system memory may take some time...
  [   12.376605] Memory: 16408564K/16776672K available (14339K kernel code, 1397K rwdata, 3756K rodata, 1636K init, 11460K bss, 368108K reserved, 0K cma-reserved)

Signed-off-by: Alexander Potapenko <glider@google.com>
Suggested-by: Kees Cook <keescook@chromium.org>
Acked-by: Kees Cook <keescook@chromium.org>
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
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

---
 v6:
 - update patch description, fixed message about clearing memory
 v7:
 - rebase the patch, add the Acked-by: tag;
 - more description updates as suggested by Kees;
 - make report_meminit() static.
 v8:
 - added the Signed-off-by: tag
---
 init/main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/init/main.c b/init/main.c
index 66a196c5e4c3..ff5803b0841c 100644
--- a/init/main.c
+++ b/init/main.c
@@ -520,6 +520,29 @@ static inline void initcall_debug_enable(void)
 }
 #endif
 
+/* Report memory auto-initialization states for this boot. */
+static void __init report_meminit(void)
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
2.22.0.410.gd8fdbe21b5-goog

