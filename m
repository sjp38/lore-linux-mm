Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1357C282DE
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 09:15:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83790218D3
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 09:15:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amarulasolutions.com header.i=@amarulasolutions.com header.b="Vx6SC+WB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83790218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amarulasolutions.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF656B0005; Sun, 14 Apr 2019 05:15:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27F786B0006; Sun, 14 Apr 2019 05:15:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1498F6B0008; Sun, 14 Apr 2019 05:15:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D01746B0005
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 05:15:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c64so9710666pfb.6
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 02:15:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=nQJrrbue7c3N84Cd6mFZPA1Y1o7acbXS4cTb2nznlGA=;
        b=RUqVmvqj0u0lnQKVYDnxAmHpScVgKFjvx2CwxzJinNrvM/wn89zAa+bD9dp5zGaxtQ
         HD+H8/RwV7OiYvLDYMmj8kP0Ue5Vaf4AFzg4mfvE/lyIGEkHdHG5oI+RBIWO0bgwYj9O
         ZHXg+NRka277EI7wFPDWSMh4kXSEalUa48iCwpVFEPp6u/740insZ+M8h/iMlN9Vb5Yh
         SBJZo+82Zphe10HGwuHYyUG8/X/gTjDMLKUwpCQZhjdKhkMuf3zif/wBJqRQ6Pt8hIpm
         iOVNb0586TsMenXN7AtJaHrvoYBOJCLhawlVVDmdiXxjkQy9KsnL2qKntPrCQkVDorBA
         amEw==
X-Gm-Message-State: APjAAAVh5gvGFbYlZVN3fjtAuW3R8xdYBcxozv0fLHsSRk14/irEJQdL
	qlzTYfENHf1GIE7X28oWKJxJTGVzdoVxST9Zys6KHoP+ysrqrc2I+OJfmqqwp98oY6Dk/5+dOO9
	h7IrV/Y81h5fM8OdcD1UDeqY0bfdZJvygdROPlAhwoa52QsWTJU7zVLHehtKroD1RzQ==
X-Received: by 2002:a62:69c2:: with SMTP id e185mr67898830pfc.119.1555233337384;
        Sun, 14 Apr 2019 02:15:37 -0700 (PDT)
X-Received: by 2002:a62:69c2:: with SMTP id e185mr67898748pfc.119.1555233336218;
        Sun, 14 Apr 2019 02:15:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555233336; cv=none;
        d=google.com; s=arc-20160816;
        b=wBxxInYpyMRRKHqWk4MUtpO3KxtmN34UcAL1ppwTJVBgIN3XpW1NpL3v/HxZrDuJft
         8OHqKn0ATPgK1/hz0n3wvKu/r8UC+txxH3hyBhXvxKhai5c3H8mvcD3LQcMKQYUQIgBX
         xYgOh/bXbNVczeus1/eFHmDTBdVKrF1rhcNv6Enmm41xrFajNZAOvE49aJMOyY3YlnSz
         vqROlRGkCn5b1zz8IjnV3BLRI7Eax/YhySnazbWMn2uhto+CGFTqG5jbD6YnF2DTT9LE
         jy9uDkghhnZO3HCTd+3vChu0qVWdbYlO/CHI1xHRsuUcxuZLAN0jLh7a5gxAVogCYJKl
         EFwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=nQJrrbue7c3N84Cd6mFZPA1Y1o7acbXS4cTb2nznlGA=;
        b=Lo2mSPVMeSbuMSk4RzwXjz+S1nJRGYLNMbxGeVNeD1T0eE9Hkdp37pwe2UBbJ3c4MZ
         z01vKZ/RvBYAl6eV5DjytCfQiRCafRJ6oC5yZPSF1thascppFUajK7Jhs/gQ1TyU+0lH
         rW4KLpNsbof659WgRVCMuc+CZ1vrAJhU3JtEWCCyImFpVwzqr2+CW1EQTX7JWqDFKzvw
         HNey1qNK0DMGcEJcYS7OB1Jy67UOwFSwg2sNDV2pUK+5A3LSJxgoUQ/8ShjiT9O5DJN0
         o/H6otnIFhZxL0dlfsBrHCcqbxUq1ZxPctJaihwVhP2tMpqrHGXa69ckjIEosiaM3nwO
         IKlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=Vx6SC+WB;
       spf=pass (google.com: domain of shyam.saini@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shyam.saini@amarulasolutions.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s10sor49575799pgl.67.2019.04.14.02.15.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Apr 2019 02:15:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of shyam.saini@amarulasolutions.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=Vx6SC+WB;
       spf=pass (google.com: domain of shyam.saini@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shyam.saini@amarulasolutions.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amarulasolutions.com; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=nQJrrbue7c3N84Cd6mFZPA1Y1o7acbXS4cTb2nznlGA=;
        b=Vx6SC+WBX6kmXBT4OP7H4eDk8pZHoU/6bnBya6zmdqnkmojK/Kyegi8oINArN7IYSn
         +1/yKPRCgEiPL2mbV0UVrKN/5WOq6lk9U0eM7lknJ/LesMvOvavOIaIHTDuaUm2Sal0B
         6L2RJwK2Dz0nII5LmzT4mcUBTnjEOkw+KlIkA=
X-Google-Smtp-Source: APXvYqzJvZI8cg4NBQ48Y2+PvRZTxzZuXgdmiA69lcI6ZO8t6W2tPumqwfHBphvyyz1mE1fpT8Y3Og==
X-Received: by 2002:a63:3188:: with SMTP id x130mr61423347pgx.64.1555233335889;
        Sun, 14 Apr 2019 02:15:35 -0700 (PDT)
Received: from localhost.localdomain ([42.111.19.105])
        by smtp.googlemail.com with ESMTPSA id g10sm31344767pgq.54.2019.04.14.02.15.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 02:15:35 -0700 (PDT)
From: Shyam Saini <shyam.saini@amarulasolutions.com>
To: kernel-hardening@lists.openwall.com
Cc: linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	keescook@chromium.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	intel-gvt-dev@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	netdev@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	devel@lists.orangefs.org,
	linux-mm@kvack.org,
	linux-sctp@vger.kernel.org,
	bpf@vger.kernel.org,
	kvm@vger.kernel.org,
	mayhs11saini@gmail.com,
	Shyam Saini <shyam.saini@amarulasolutions.com>
Subject: [PATCH 2/2] include: linux: Remove unused macros and their defination
Date: Sun, 14 Apr 2019 14:44:52 +0530
Message-Id: <20190414091452.22275-2-shyam.saini@amarulasolutions.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190414091452.22275-1-shyam.saini@amarulasolutions.com>
References: <20190414091452.22275-1-shyam.saini@amarulasolutions.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In favour of FIELD_SIZEOF, lets deprecate other two similar macros
sizeof_field and SIZEOF_FIELD, and remove them completely.

Signed-off-by: Shyam Saini <shyam.saini@amarulasolutions.com>
---
 arch/mips/cavium-octeon/executive/cvmx-bootmem.c | 7 -------
 include/linux/stddef.h                           | 8 --------
 tools/testing/selftests/bpf/bpf_util.h           | 4 ----
 3 files changed, 19 deletions(-)

diff --git a/arch/mips/cavium-octeon/executive/cvmx-bootmem.c b/arch/mips/cavium-octeon/executive/cvmx-bootmem.c
index fc754d155002..44b506a14666 100644
--- a/arch/mips/cavium-octeon/executive/cvmx-bootmem.c
+++ b/arch/mips/cavium-octeon/executive/cvmx-bootmem.c
@@ -45,13 +45,6 @@ static struct cvmx_bootmem_desc *cvmx_bootmem_desc;
 /* See header file for descriptions of functions */
 
 /**
- * This macro returns the size of a member of a structure.
- * Logically it is the same as "sizeof(s::field)" in C++, but
- * C lacks the "::" operator.
- */
-#define SIZEOF_FIELD(s, field) sizeof(((s *)NULL)->field)
-
-/**
  * This macro returns a member of the
  * cvmx_bootmem_named_block_desc_t structure. These members can't
  * be directly addressed as they might be in memory not directly
diff --git a/include/linux/stddef.h b/include/linux/stddef.h
index 63f2302bc406..b888eb7795a1 100644
--- a/include/linux/stddef.h
+++ b/include/linux/stddef.h
@@ -29,14 +29,6 @@ enum {
 #define FIELD_SIZEOF(t, f) (sizeof(((t *)0)->f))
 
 /**
- * sizeof_field(TYPE, MEMBER)
- *
- * @TYPE: The structure containing the field of interest
- * @MEMBER: The field to return the size of
- */
-#define sizeof_field(TYPE, MEMBER) sizeof((((TYPE *)0)->MEMBER))
-
-/**
  * offsetofend(TYPE, MEMBER)
  *
  * @TYPE: The type of the structure
diff --git a/tools/testing/selftests/bpf/bpf_util.h b/tools/testing/selftests/bpf/bpf_util.h
index 2e90a4315b55..815e7b48fa37 100644
--- a/tools/testing/selftests/bpf/bpf_util.h
+++ b/tools/testing/selftests/bpf/bpf_util.h
@@ -67,10 +67,6 @@ static inline unsigned int bpf_num_possible_cpus(void)
  */
 #define FIELD_SIZEOF(t, f) (sizeof(((t *)0)->f))
 
-#ifndef sizeof_field
-#define sizeof_field(TYPE, MEMBER) sizeof((((TYPE *)0)->MEMBER))
-#endif
-
 #ifndef offsetofend
 #define offsetofend(TYPE, MEMBER) \
 	(offsetof(TYPE, MEMBER)	+ FIELD_SIZEOF(TYPE, MEMBER))
-- 
2.11.0

