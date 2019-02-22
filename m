Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BF34C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:54:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00E35207E0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:54:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ngTaPZFj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00E35207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A968D8E0103; Fri, 22 Feb 2019 07:53:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FCD08E00FD; Fri, 22 Feb 2019 07:53:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8738E8E0103; Fri, 22 Feb 2019 07:53:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 29CFB8E00FD
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:55 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t133so484371wmg.4
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xP0EP9+s7jJBuNL20aZNoIWDJO0QH7KitwsXHnWrFcE=;
        b=LB2PVQNc6yRtATHH0t12jbWnTs1K/uBRD5sSMxl4JH/5TRvUtr/3vlDF/1SYiNcLYz
         gyKXflPoPQN4N23UGjpmw3P2XH/HIiSJEOg+FxhOtQsISKiR1GUdJ8GcluNgUi63guCW
         A8frtC3A9st8v95r58OCDFdT6KyXE0ABpUUnFX5QHCAxRjtpNYS116x6nftWdpr78g8X
         pl8r4Q/Bt20M5a1b0anJ4IgUnSbhMRyEQPc8fBQdXFEsN1dbqD/1pgpFrrOTpI0FmdwH
         rmfkdwwLNepsqeeqDNoPYcS+TxyBmu8WiKd6mZ49JSEttL6K3NdjHIdBphSi9PdWYeNM
         GVcg==
X-Gm-Message-State: AHQUAubzOFcS4Fq9am3FmSyqW2BVEPS39cfHy7Mh5Uv/7ftQYfB6tKee
	la+9AvJOosSwkQWzvEcn2nbw6cHeXExd9IZgPDBoks+hDmk0J0t8LiYXCK6x0SSz/vRVLMZKHRu
	xEgqT07CBFlJP8LjBJYJY5eYvhX542qSMh0eJZo8WzkfXRfYtad+/7ZygRZeeDc3PXb8ySBtmZt
	Jmmv57YHf31JUFMBOsccz9iEnpTd/Ofl2ZeMb5/Ub3xVv4spz0gAajAYEMNqanMwxcibC1p5zY6
	knPgBPf18u29x1CBczdj8O81ILKosu6diltRHG423PpGpzE/b1WJSt2GldGLJpwc9ZCBd/Xqocf
	hO2zpNfL0m6EQWrcQNYe8Z9vUHqJlzMmtrs8t8Qd0oVttTfm0nZQEIgCBE3X0ZZLD0chuFsM0gy
	E
X-Received: by 2002:adf:a49c:: with SMTP id g28mr2764869wrb.147.1550840034702;
        Fri, 22 Feb 2019 04:53:54 -0800 (PST)
X-Received: by 2002:adf:a49c:: with SMTP id g28mr2764815wrb.147.1550840033717;
        Fri, 22 Feb 2019 04:53:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840033; cv=none;
        d=google.com; s=arc-20160816;
        b=s3kEaMiPxTazeMFZ2O3JM9wq+DZ+/Q2Tm/OiBgR9LKF2UM8Ozgdryj1o4dClZ6nMLg
         RPsxP2LBfZblv744PhXzu6v9xTY6LvaxNHmz6X3I3uwk40M1ZTSsoHk4YrIU71TkCct6
         cbj71kvRTWoFPZTNkGaZ+vY5XUquvEwPojVVx0WsO/PYMItcSXsT8pyMin6PzNPzm2dz
         prCmsZOg3AnFMiVJqxt591UZnc71mhNv/fFnzpV6KzxJAWaETkzZLm24GonJm/NvQSlS
         tpggItIezFq5UZLavqH7cgZtm4O3/r2n7uDR7zjmVeVDFuM8zmZyVwSYJeYaxw/da063
         Nz4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xP0EP9+s7jJBuNL20aZNoIWDJO0QH7KitwsXHnWrFcE=;
        b=mPruH/AEOgELi3+i67373M6LMc7Gh26m7IOFPPvC99vMJGDQ9m7hAYLYL0k+LjR7XX
         +1k+6ik3HT3cTu8Td8voG5203FAJ6GywPQ/Hug4+EpYyP7SksJm64IdZxy+zmoA/GdeI
         evnTXc3OSF/+ZXZidDDlHru9ufbb/LODp7Fi+jo8gzAhK9qQX2ACTZR93r+sq56nOeUE
         e8trR7vmKPnEfe6rC6qYBVrm1XAKAk/XNZhOgkGOejTvwI5hTvyKz6WDVaiofiL8tPVK
         BZbfAmkjCZj9HHDdVtKH3jJOiZV5QLHpuZY0clrZdxAK9bTVdwri56DPQ44UZOqiqC1X
         YQwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ngTaPZFj;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor871565wmb.9.2019.02.22.04.53.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:53 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ngTaPZFj;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xP0EP9+s7jJBuNL20aZNoIWDJO0QH7KitwsXHnWrFcE=;
        b=ngTaPZFjbMr8UVnv+XHv855CtRTNvKpoDmCRTtKsyfuCSVAX1fHkkeEopamnkFNUkO
         2AxeqdOMs5OS1aAzAdqqAMH6oIYxxx7HXZvCiuu5mGrP4+JLSS3N1MvyfwgLIUpYg7XA
         36WRCDQmvGeM5dFPaSlrAtGT6lqE+t1iYacqOuNf0WL0AvYMXookG0ZRXOCwQj/yAJ64
         Ava6JpCXLFI/teW898eqAG2k52RXgpD4kz9ufk+Lk99Zo8v2WsRFs8gVa3BZjwmle1GK
         pfRIrNVVanNCc8AEbJlDtvFhw5/QlKpS67K/2EsIOQEy8hvKVuwcPksCJr25OCE/XBBn
         QqYg==
X-Google-Smtp-Source: AHgI3IYWY7Ghxi/h12hQKyhtNx7Svt8SN9NDulSxokwzQOKjvHqoGwEA6m30t17PvUiKofsiFVoIUA==
X-Received: by 2002:a7b:c457:: with SMTP id l23mr2410289wmi.2.1550840033285;
        Fri, 22 Feb 2019 04:53:53 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:52 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v10 12/12] selftests, arm64: add a selftest for passing tagged pointers to kernel
Date: Fri, 22 Feb 2019 13:53:24 +0100
Message-Id: <8c08cda0dfdef1b062695241a6f6594487eaa3cb.1550839937.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
References: <cover.1550839937.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds a simple test, that calls the uname syscall with a
tagged user pointer as an argument. Without the kernel accepting tagged
user pointers the test fails with EFAULT.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 tools/testing/selftests/arm64/.gitignore      |  1 +
 tools/testing/selftests/arm64/Makefile        | 11 +++++++++++
 .../testing/selftests/arm64/run_tags_test.sh  | 12 ++++++++++++
 tools/testing/selftests/arm64/tags_test.c     | 19 +++++++++++++++++++
 4 files changed, 43 insertions(+)
 create mode 100644 tools/testing/selftests/arm64/.gitignore
 create mode 100644 tools/testing/selftests/arm64/Makefile
 create mode 100755 tools/testing/selftests/arm64/run_tags_test.sh
 create mode 100644 tools/testing/selftests/arm64/tags_test.c

diff --git a/tools/testing/selftests/arm64/.gitignore b/tools/testing/selftests/arm64/.gitignore
new file mode 100644
index 000000000000..e8fae8d61ed6
--- /dev/null
+++ b/tools/testing/selftests/arm64/.gitignore
@@ -0,0 +1 @@
+tags_test
diff --git a/tools/testing/selftests/arm64/Makefile b/tools/testing/selftests/arm64/Makefile
new file mode 100644
index 000000000000..a61b2e743e99
--- /dev/null
+++ b/tools/testing/selftests/arm64/Makefile
@@ -0,0 +1,11 @@
+# SPDX-License-Identifier: GPL-2.0
+
+# ARCH can be overridden by the user for cross compiling
+ARCH ?= $(shell uname -m 2>/dev/null || echo not)
+
+ifneq (,$(filter $(ARCH),aarch64 arm64))
+TEST_GEN_PROGS := tags_test
+TEST_PROGS := run_tags_test.sh
+endif
+
+include ../lib.mk
diff --git a/tools/testing/selftests/arm64/run_tags_test.sh b/tools/testing/selftests/arm64/run_tags_test.sh
new file mode 100755
index 000000000000..745f11379930
--- /dev/null
+++ b/tools/testing/selftests/arm64/run_tags_test.sh
@@ -0,0 +1,12 @@
+#!/bin/sh
+# SPDX-License-Identifier: GPL-2.0
+
+echo "--------------------"
+echo "running tags test"
+echo "--------------------"
+./tags_test
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
diff --git a/tools/testing/selftests/arm64/tags_test.c b/tools/testing/selftests/arm64/tags_test.c
new file mode 100644
index 000000000000..1452ed7d33f9
--- /dev/null
+++ b/tools/testing/selftests/arm64/tags_test.c
@@ -0,0 +1,19 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <stdio.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <sys/utsname.h>
+
+#define SHIFT_TAG(tag)		((uint64_t)(tag) << 56)
+#define SET_TAG(ptr, tag)	(((uint64_t)(ptr) & ~SHIFT_TAG(0xff)) | \
+					SHIFT_TAG(tag))
+
+int main(void)
+{
+	struct utsname utsname;
+	void *ptr = &utsname;
+	void *tagged_ptr = (void *)SET_TAG(ptr, 0x42);
+	int err = uname(tagged_ptr);
+	return err;
+}
-- 
2.21.0.rc0.258.g878e2cd30e-goog

