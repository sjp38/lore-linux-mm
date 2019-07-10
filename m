Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1996BC606CF
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 10:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B141720665
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 10:26:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uuNcOFBP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B141720665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08CA68E006D; Wed, 10 Jul 2019 06:26:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03E3B8E0032; Wed, 10 Jul 2019 06:26:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6FE18E006D; Wed, 10 Jul 2019 06:26:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B33018E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 06:26:44 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k20so1203368pgg.15
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 03:26:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=85BGws/O2/x8Hh97uEaqbM8uDSOfynBf5b84MXFpylY=;
        b=cWKz53Fx2/513wPeGn9YWgggXBoh6ylPUFW2wMEUHuxLJwlV/0DTVqTQq/gvIuifXk
         7xA34Fwamc3cUDD/F2fiXcbIlkKlSCRnNKim7C9VBR+YzCrImQi4K0apq7RVAGlkbap2
         cwWn/29jYQzTk5AFCfAQIpXiBgOWYefwW1FycHKOFL1ruug/XJ2/SWhjEVipp+5tD7Ak
         TqS74iGmrPjYic6InmDlbQmG7wnKjGA56ihqrNlAWoTACbyUcgC/+QkezVB2BB7uIYwu
         Nc7acs+YYV8MiYnOypAtAtMEWX770uqaSiDpKNMuXu/DpKQwJpks0V+Xue7Rm45AhtNI
         Y5pA==
X-Gm-Message-State: APjAAAU88CjOLzNyjtEKnZnEqv9OWiiLNVrYAh30T5Vz5gaKAU+JeeGs
	ZGGzGCeQ+Rm1/9sX5fpk3LE1OJ+ALieTL/ZN9k2baA4vtjohaBkYdeZHGwB6wRBsnhcTgyI+u6f
	USwJuvRD20btkhjUSKEGNezB8lZf03jAWxfSo/jxqIigkY0kZByy4jPASEFyC/TU0Gg==
X-Received: by 2002:a17:90a:d14a:: with SMTP id t10mr6092084pjw.85.1562754404335;
        Wed, 10 Jul 2019 03:26:44 -0700 (PDT)
X-Received: by 2002:a17:90a:d14a:: with SMTP id t10mr6091995pjw.85.1562754403365;
        Wed, 10 Jul 2019 03:26:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562754403; cv=none;
        d=google.com; s=arc-20160816;
        b=lXzpTDIWLJ2YYdYXjLPqJ8KEHHWu0fjmN+N2qbVb1iZ2MHVs4mqb0+Ly6NAPlQ3Wid
         EG2RFwPacKa/3k7vYS+LeAVzriyGyloE1CeyQLAk0vxgtCbHTWqJ+hqUOIRR2tpHw0ys
         RYvPYqiHQhNG6M7BITOpGcjKaWwsFJ2f6FNJ1obJQkkgp5bgRYGlwequZ5ZP6g+r14Ip
         TWvkzzr8PzH6wyQJ68HpZ6pCrLrysXSqpPHWFwmCJKo/wl2HZoNdq28aRcGQ6Xn//sRN
         wamS/piMHk7tIec+/AojkkcKufaMT1lvsyVHpzFYwrzcbwIs5Y7BSfwqGGRGSzxSn/cR
         UDIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=85BGws/O2/x8Hh97uEaqbM8uDSOfynBf5b84MXFpylY=;
        b=gyXCgBs0b6fTFcF3tszhSphSamkz5+YobqX++zowS8m/IPjpYzX/DeDLiplTM19eKl
         uh4MjDlVORgzCxT3sTMtqlMkgc0Aidp33f6GhOLd/fawgHP4sRg6PBhPCFVPczs884In
         B2vR4VhNmX8r3IYLm50lt9F/vhl/Y1V4NfnbI61UcoxFtTVJsuLsRugOU0defBB4K/RV
         crx6QU1cqT/jLYAvdZny4f2l+1/EmKLGVgDcSSkRLbfQiZvbD4PEJKRrttwP+u0k5BDi
         0bhZ3OEjKDSuw16NMTnoHFprqLFVclPjMTSn93LVGGvQkfIDzc69fwps8pQ/Ngfzdo5L
         wFfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uuNcOFBP;
       spf=pass (google.com: domain of bsauce00@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsauce00@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor2318693pjv.21.2019.07.10.03.26.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 03:26:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of bsauce00@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uuNcOFBP;
       spf=pass (google.com: domain of bsauce00@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsauce00@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=85BGws/O2/x8Hh97uEaqbM8uDSOfynBf5b84MXFpylY=;
        b=uuNcOFBPSBE6CLV/X72nYWisfAXdtWj0WQ7usY4zK84QoNKtM0+XsWbFtr1qCxbLVu
         9x40rd6bAIY+pZeQU9XUsy4V/9iXFk62WFUE6p0dEKZeMDoH3uowZHMSqQpT/G1QwWjm
         HgfUe+MgvOuzCCDqPCIumx1NuzTTO9Jb+SZ11j4AsEK49TvvQjvXLBxyMtueqPC3neI/
         0o0wUC4sRffpTJylLjKG+g1WTkP0oGwIlq89lZasHKf2K4f5cDRwRKXJdDy8wqhP+AHb
         /6j6ziNaBy/87k7GFp/TotPUTNhV8sSD7x9drY+8CnT2CK8EbRW0nhHQb4JKQswIZWfo
         UbcQ==
X-Google-Smtp-Source: APXvYqyFtEN7ijsGT5VEadU8zygjMAvqFqbCiuu/hEw9S4jnvRnpL5hm84ehC5SIENU1gu4GFvccIg==
X-Received: by 2002:a17:90a:9a95:: with SMTP id e21mr5971516pjp.98.1562754403043;
        Wed, 10 Jul 2019 03:26:43 -0700 (PDT)
Received: from localhost.localdomain ([103.7.29.7])
        by smtp.gmail.com with ESMTPSA id g6sm1601983pgh.64.2019.07.10.03.26.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 10 Jul 2019 03:26:42 -0700 (PDT)
From: bsauce <bsauce00@gmail.com>
To: alexander.h.duyck@intel.com
Cc: vbabka@suse.cz,
	mgorman@suse.de,
	l.stach@pengutronix.de,
	vdavydov.dev@gmail.com,
	akpm@linux-foundation.org,
	alex@ghiti.fr,
	adobriyan@gmail.com,
	mike.kravetz@oracle.com,
	rientjes@google.com,
	rppt@linux.vnet.ibm.com,
	mhocko@suse.com,
	ksspiers@google.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	bsauce <bsauce00@gmail.com>
Subject: [PATCH] fs/seq_file.c: Fix a UAF vulnerability in seq_release()
Date: Wed, 10 Jul 2019 18:26:29 +0800
Message-Id: <1562754389-29217-1-git-send-email-bsauce00@gmail.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In seq_release(), 'm->buf' points to a chunk. It is freed but not cleared to null right away. It can be reused by seq_read() or srm_env_proc_write().
For example, /arch/alpha/kernel/srm_env.c provide several interfaces to userspace, like 'single_release', 'seq_read' and 'srm_env_proc_write'.
Thus in userspace, one can exploit this UAF vulnerability to escape privilege.
Even if 'm->buf' is cleared by kmem_cache_free(), one can still create several threads to exploit this vulnerability.
And 'm->buf' should be cleared right after being freed.

Signed-off-by: bsauce <bsauce00@gmail.com>
---
 fs/seq_file.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/seq_file.c b/fs/seq_file.c
index abe27ec..de5e266 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -358,6 +358,7 @@ int seq_release(struct inode *inode, struct file *file)
 {
 	struct seq_file *m = file->private_data;
 	kvfree(m->buf);
+	m->buf = NULL;
 	kmem_cache_free(seq_file_cache, m);
 	return 0;
 }
-- 
2.7.4

