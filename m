Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90476C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F22B218E0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cM+Q7dAj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F22B218E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D60CD6B02C0; Fri, 15 Mar 2019 15:52:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D140A6B02C2; Fri, 15 Mar 2019 15:52:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8C9A6B02C3; Fri, 15 Mar 2019 15:52:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5356B02C0
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:29 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id g140so11441662ywb.12
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=eZ7BHJXyN3220x7rl2oUpgQUqTcJDNuGZqyhRO+ZCi8=;
        b=aQKvXj/9BVpkNNRPl2EZzFKL6WJmHMbue63nX2o6ITvWGt36LP/d7W1ceDtl1UzX9F
         WJWKLVH3/ONX9o3ykuvoJWM/teq+kzu5pazmAy4sOWbJHI5eefb+C9+PiEX6pun2Vzrm
         U7JQOnBO81R5UgmtQih/QOAXCfp4oXL7S7IcpX3T/jzgI6GW28mSktyzPrmQqYcv1kcr
         lqlVpsohxwl+U2XNN5fkEOXYQjMnenrFPPxOQ09fUiqpcr4IqxGF2aA7FSG+jA3YSfp3
         4OcSdaBPPOkworTg8QID8mN3yoNNHVwoXoiyvyS0e6bNoVhfhcH70QYhjQR8zOLCiUn8
         OwLA==
X-Gm-Message-State: APjAAAV8f8BsENYGJzYJNJwZezhAMG5UGI99LXU6zR2RBJLlutfN5pYz
	4oeRF6XVZVB0hskhlbTVoAOhNNKau2VfkF92VLFyQIrsZaYDbnJS55OqKiyyazyXN+yH8hABd5A
	cEzSgwgiAVPEbTZn3hkqkcbghtNVM8x5bVn1O6m7k4tO0y+6ljY3yE2UD/mCPO7hJTw==
X-Received: by 2002:a81:81c4:: with SMTP id r187mr4379853ywf.403.1552679549342;
        Fri, 15 Mar 2019 12:52:29 -0700 (PDT)
X-Received: by 2002:a81:81c4:: with SMTP id r187mr4379798ywf.403.1552679548367;
        Fri, 15 Mar 2019 12:52:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679548; cv=none;
        d=google.com; s=arc-20160816;
        b=oSsuQXsdZEwSdKeHMPksa5KURBOLoLzBnmJR2m+dpSAScGY2/C8T2RSmOR5dHY1ZMp
         KrV4+nIODQ4rbj/xsd7jdWUdTTeysV4eK7/0bCMwWogY2XfR/5eIrIa05Gl7utJRajFQ
         yKnn/KQqTG5OASBjq30arR+8IsfsTpVSi28XejNjyUWHz9f9T5jTn6xI3BE8VOwHXnJA
         9zxyccnf/YNuH+Q+JkZO3ugu5oIMXKP2wK4zyb/fHpOast9EPqwULws6C0Nm9A941EHY
         E+frg0WBFeEiAFQfNVsdf2xRoNwmESMN9CbefSgN1hd3Jyi7NrzYcWSw/TtxzIHktCL9
         Gnbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=eZ7BHJXyN3220x7rl2oUpgQUqTcJDNuGZqyhRO+ZCi8=;
        b=dH2nStoB9L2TD2U9EPGikwve2NJNrbkpsiAO8B5iCrnsKaOdIyt+Ui45KCARq7vpm1
         hqO7DeqkFJaDzzZLHwtDfSVbRQZmDjl1vuMqddCrZ6GNm7048dTkQNtHb5MU/SRqOXVq
         CeywsuXjvAV22fw0tB3FeZWrbfhoyG5FTz9CpqwuT6x+ZXJQUg6Zy85TrZnnfd0Q9eUt
         7PwnFBL6DujHdXe0lc3NXyGQcN+PzaJDJgMVlxmx24EJMDdi5Nd9ua5Byh89uEakCHoG
         VPG5TVRfFtAth1DZczpX6ODYlVBXMijZyl2FssAcvJOPaTo2FcS+pD8eXUQzyN7bDmjg
         cxsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cM+Q7dAj;
       spf=pass (google.com: domain of 3fakmxaokcjs5i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3fAKMXAoKCJs5I8M9TFIQGBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 205sor533146ywy.218.2019.03.15.12.52.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3fakmxaokcjs5i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cM+Q7dAj;
       spf=pass (google.com: domain of 3fakmxaokcjs5i8m9tfiqgbjjbg9.7jhgdips-hhfq57f.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3fAKMXAoKCJs5I8M9TFIQGBJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=eZ7BHJXyN3220x7rl2oUpgQUqTcJDNuGZqyhRO+ZCi8=;
        b=cM+Q7dAjoclAUX9rjqJjU67fQhDAumMVHtRttx9Zyi+ZIB2DGBobAtyISQHWCe9SMA
         PZHknNkYe0zmRuTP34LxQfpP1xwZBreBZ0NXH/qnk7oR3nj566n4N1rsgxomhNTEh0Ty
         SDOfq37fZf5Cao/sGRM/bhdUdzoFls7cguuH3/lWtp/1jJdgVLG8lRoWShZq4z4XO9vT
         iGHxQ7GSrXCjG8EjxrW3Y9yARtTuqQUdg+mDtAYxXQ4FY7FbCfCGcfBBG46s71wuDA8g
         bS9aqYheYMuj6UjyFgDP+dwDAvq3VA5uUamhfzLklNEwcMfGzHMrGe5/jZLh7MutPKEK
         1ixA==
X-Google-Smtp-Source: APXvYqz3F3hQJGqQ71GxABRK7OAGTM1YeC9p7knGv+mSIqj4Is7OoPrLZZdfGBYcCn7qYvsKmLT0kaCoS+EB48D+
X-Received: by 2002:a81:7acf:: with SMTP id v198mr2397024ywc.16.1552679548119;
 Fri, 15 Mar 2019 12:52:28 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:38 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <8e7bfcb3812ae2a1f558864f56eec71a8f78fa2e.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 14/14] selftests, arm64: add a selftest for passing tagged
 pointers to kernel
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, 
	linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, 
	bpf@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

This patch adds a simple test, that calls the uname syscall with a
tagged user pointer as an argument. Without the kernel accepting tagged
user pointers the test fails with EFAULT.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 tools/testing/selftests/arm64/.gitignore      |  1 +
 tools/testing/selftests/arm64/Makefile        | 11 ++++++++++
 .../testing/selftests/arm64/run_tags_test.sh  | 12 +++++++++++
 tools/testing/selftests/arm64/tags_test.c     | 21 +++++++++++++++++++
 4 files changed, 45 insertions(+)
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
index 000000000000..2bd1830a7ebe
--- /dev/null
+++ b/tools/testing/selftests/arm64/tags_test.c
@@ -0,0 +1,21 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <stdio.h>
+#include <stdlib.h>
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
+	struct utsname *ptr = (struct utsname *)malloc(sizeof(*ptr));
+	void *tagged_ptr = (void *)SET_TAG(ptr, 0x42);
+	int err = uname(tagged_ptr);
+
+	free(ptr);
+	return err;
+}
-- 
2.21.0.360.g471c308f928-goog

