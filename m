Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CDE9C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4013B22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:14:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4013B22387
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3FDA8E0005; Wed, 24 Jul 2019 02:14:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEF528E0002; Wed, 24 Jul 2019 02:14:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB7E78E0005; Wed, 24 Jul 2019 02:14:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0528E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:14:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e9so18441693edv.18
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:14:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KNvQCbzGXI/XoQciu2chauD/yJmJpreVXpqKbZidQGg=;
        b=RSq0cTMYPyzEap1TNK9LKlmUpSsWEggq5M97iLxTNzZECNMnwTvGv1QvxnWHDiq+my
         rl/YUef5N7qswiNbsgb2jKxRllvIWA3A2QKUSZ7VBs7EzeVt8eiRYS3q/jnHqFtM5+3Y
         3Fpr0vPR7UZveByf5NeQTxIUk2qpFI2dmzm9DL4j9eZH1JQRkCl/wg1p3fMIr1DEC1BM
         8PIoO9vdFSkYG5j9BFYWXPoHMzZn+DbE7lkoU4CoB0ohvnGjSiFT/JkBkTMEJ+QYEsCz
         OMbUaYGpPE1jNqhl629XX7ODL3GkW4UkN17cXY3T1fEsk3XMTGRnnnpQ5lu5RpQ6O+kb
         U7HQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAX0FO+0P4fwl/hfDc/sq/jbNVXfufCZ7XPhLucHPdM4PWtYy4bH
	5gEXaOUG467ELN2LDfyEAi6eveYSFTiYVLh7svn2Vsj26STyzPpS76yEaZ7k5D91m+3wVrm2mGU
	eLgauKiwZfYWS8vrlT2vfd3LKQKqahwkWhPVZJlXq44ON/bUJY7GNz+Z43DEci7I=
X-Received: by 2002:a17:906:27c7:: with SMTP id k7mr61522881ejc.91.1563948860086;
        Tue, 23 Jul 2019 23:14:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfd64nXQ1CO5yoXY3vUD9KBPb/TzoX+cdrx09+RZ017StIg7uwLbPt1++OhE7+pZwHVIdi
X-Received: by 2002:a17:906:27c7:: with SMTP id k7mr61522836ejc.91.1563948859203;
        Tue, 23 Jul 2019 23:14:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948859; cv=none;
        d=google.com; s=arc-20160816;
        b=EOGkim58hskW0gje9yINcxamLy0oshpJm+NZaA0j7FLHyJD4AVAi5qcK/wzMOMh0pm
         m4ELDzd71CsYxrtKqh9fGmIcyfRxPlD+bjVcdJrVkIczZXnJrkSwWFPen6ejUHe+ubWH
         /pg4GabU7nqRNKIGvtY5p4RsRxuaLKvdo67m1sL1TGV2EGRxNVrwcS45yZSPa2atLq5P
         PMnUH5vyOg9LWUfO5bv4HAHBMJkhqDwDSTEAl7V4TrJpwMxsNMlcb5V64qjdcvhxkl+M
         DYR+tuXs4dzCKP7TW8p/Oc+X0ksOQYwQqwNtOdT0lgWH1LmaYeSpdWoXcyg0g+Rfvjxy
         whsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=KNvQCbzGXI/XoQciu2chauD/yJmJpreVXpqKbZidQGg=;
        b=AoJzaeoGRkH6zAGeGDksNPbfLbbGlUL09/dapC+M3I1MhW8cZk2tbsFM+PYQ5XlCkP
         IA8c5GUmqTF3tcHvJifBJmXuJqa+0VgUrx4PJU1IYFwmEIXivMsvjc09U6nGexrnkTaS
         npR3Ot2GnuV1v5vWs8KKCGRipx2VIbf+y5iCpJFbucEw4PmkdvrpMsa7agoBhFVUtXx+
         0kYT8DDsz/lWFVLKWqvnV7I6k8yJWUZ0zjAXVSL1J837ovXkD64R+1JZCxI+XGYC9otW
         wQ1+ZGRC++KlDQ0qpDElb0TUftLqBesK1/1OE+NjpRtgwsaYoyJcBbNLdCXZYoMmIhAH
         xxHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id z2si8764419edz.118.2019.07.23.23.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:14:19 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id D50ADE0004;
	Wed, 24 Jul 2019 06:14:14 +0000 (UTC)
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
Subject: [PATCH REBASE v4 14/14] riscv: Make mmap allocation top-down by default
Date: Wed, 24 Jul 2019 01:58:50 -0400
Message-Id: <20190724055850.6232-15-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
References: <20190724055850.6232-1-alex@ghiti.fr>
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
index 59a4727ecd6c..6a63973873fd 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -54,6 +54,17 @@ config RISCV
 	select EDAC_SUPPORT
 	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_WANT_HUGE_PMD_SHARE if 64BIT
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

