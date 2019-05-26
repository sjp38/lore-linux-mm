Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D9FDC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 14:03:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53A822085A
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 14:03:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53A822085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F33A46B0003; Sun, 26 May 2019 10:03:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE1266B0005; Sun, 26 May 2019 10:03:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA9CD6B0007; Sun, 26 May 2019 10:03:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8965C6B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 10:03:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p14so23391701edc.4
        for <linux-mm@kvack.org>; Sun, 26 May 2019 07:03:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eylvikXdybEsbZ5NWad3DwvJBhDEOYlVAp2XXhmXkJo=;
        b=XperZ8UIZCb9+gwW8o4qpYYfeWO6rBJ2TaOD6Muz73t1fK4cw9j9GqsvjO9yITLa9T
         Db0omikJH4XYGEXH5ZyYr7jLhLEsC+TVOEaeWk5GZvLJdeTyCcMo7Da127Ft+Yp8EtwW
         DQtpbLXJocaVGxv4RTGGl93ipHyQ3R+b3r3podfIbIZlE1zvInZSysuctbX1tzPF/fx+
         O90WX+OklA+qeKiKiHZgtRQBlcqnMFf++f6A7BbcwOga7jg0InPvDzeL7AmP+NmrrDTP
         nX+Btjr3zkF8QBmkAJ3xLfzbIMQ6fUQjcdZP+JlrLsSJjegAnVrO4xWECDy9JBo/4CyR
         u9Dw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUdM0pfms4Mbi7OwnNlKER4tfGNiAOOVOE6GdJHFLh75AR+vwAJ
	SUfr7Z5oC1Z1zwD1lq8FxZESB2KawgQOiju4Kc38DuM5ASIJ0s8Rpcmkjz6ddCq0wikqtrmssF1
	JWglR+QixsoYiJdfDeheTCRvfiOfy469zaaql6b2TlxXrAsfM29ERGXuf3h0zjCo=
X-Received: by 2002:a17:906:3713:: with SMTP id d19mr84123985ejc.194.1558879415039;
        Sun, 26 May 2019 07:03:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxD5mMeRyYELeCoPIiXuiBy51qfCroI7GvnkJAJCVLpSk4lOp+hjEsKR96LPyJjKxEBC2Ys
X-Received: by 2002:a17:906:3713:: with SMTP id d19mr84123897ejc.194.1558879414134;
        Sun, 26 May 2019 07:03:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558879414; cv=none;
        d=google.com; s=arc-20160816;
        b=MX4JrTFCaSGg15WwD/tNSrF8taiAZiAcxHnppBK03cRcrBNmMq5I0pgI1rd/NDmtC4
         1S8CcX7NGDJVLKDuq/61b6MmxzGCGPlYXBprA2gVytNg83EvvNT30rPrSeI9yFTuPItu
         z42mgQ34fcOcOEeNhI2n6X8PKuBVKDP1uslONBzFvpKPrXdhjJUe5YmeorpeBKTeFf1D
         tEkPDDxUj6uhAi+KRALMx0CHnreYSuo57d+uMoANHkmzjelIEP7Cmqg7gI0OwLWt/ggy
         KyJS2evUs61Y4xR1avCOZ+li8wXIYI78u52Z4KctcFGLnbNNqVySUx3gTzRAPqcPpbMy
         GS/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eylvikXdybEsbZ5NWad3DwvJBhDEOYlVAp2XXhmXkJo=;
        b=RE4ebF1+dwD3gn0fpYmmFGMA4Eus1lUJHK3ASs6mvzlxj9y0M5FdVApXrTuAdOhPNs
         a5bONm4WX1K/k9Ckw1VwijQlZYsC2jvhvDmiA6BAs18FLwrxQNtxhgAm+Q+Idx5aS6X1
         nuVhokuoYIf8j/x0wiW67ZAeQrRXdMVXEpwd543EiQUak02zoG32SAY+/52Cfq6RCAO+
         re36383ZHFFCkeGaUjLUdWZMC3rxOkwxscFk8HoKwR4chon2YSW3EEk0PUBVQtWZqxaG
         Kl6TXABjEcxaaA8p3UNbz4AfUJ3ZqAAqhV47ZREKtqh76l0xzpKVtfLA8H7z/+b3LvBd
         pEqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id h11si2883692edh.278.2019.05.26.07.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 07:03:34 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id CA53E1C0008;
	Sun, 26 May 2019 14:03:29 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v4 14/14] riscv: Make mmap allocation top-down by default
Date: Sun, 26 May 2019 09:47:46 -0400
Message-Id: <20190526134746.9315-15-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to avoid wasting user address space by using bottom-up mmap
allocation scheme, prefer top-down scheme when possible.

Before:
root@qemuriscv64:~# cat /proc/self/maps
00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
00018000-00039000 rw-p 00000000 00:00 0          [heap]
1555556000-155556d000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
155556d000-155556e000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
155556e000-155556f000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
155556f000-1555570000 rw-p 00000000 00:00 0
1555570000-1555572000 r-xp 00000000 00:00 0      [vdso]
1555574000-1555576000 rw-p 00000000 00:00 0
1555576000-1555674000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
1555674000-1555678000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
1555678000-155567a000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
155567a000-15556a0000 rw-p 00000000 00:00 0
3fffb90000-3fffbb1000 rw-p 00000000 00:00 0      [stack]

After:
root@qemuriscv64:~# cat /proc/self/maps
00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
2de81000-2dea2000 rw-p 00000000 00:00 0          [heap]
3ff7eb6000-3ff7ed8000 rw-p 00000000 00:00 0
3ff7ed8000-3ff7fd6000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
3ff7fd6000-3ff7fda000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
3ff7fda000-3ff7fdc000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
3ff7fdc000-3ff7fe2000 rw-p 00000000 00:00 0
3ff7fe4000-3ff7fe6000 r-xp 00000000 00:00 0      [vdso]
3ff7fe6000-3ff7ffd000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
3ff7ffd000-3ff7ffe000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
3ff7ffe000-3ff7fff000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
3ff7fff000-3ff8000000 rw-p 00000000 00:00 0
3fff888000-3fff8a9000 rw-p 00000000 00:00 0      [stack]

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 arch/riscv/Kconfig | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index ee32c66e1af3..8c067ebd3ae0 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -49,6 +49,17 @@ config RISCV
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_MMIOWB
 	select HAVE_EBPF_JIT if 64BIT
+	select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
+	select HAVE_ARCH_MMAP_RND_BITS
+
+config ARCH_MMAP_RND_BITS_MIN
+	default 18
+
+# max bits determined by the following formula:
+#  VA_BITS - PAGE_SHIFT - 3
+config ARCH_MMAP_RND_BITS_MAX
+	default 33 if 64BIT # SV48 based
+	default 18
 
 config MMU
 	def_bool y
-- 
2.20.1

