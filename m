Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C461EC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 19:07:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85FD3214C6
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 19:07:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Qez5sgL7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85FD3214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 246646B0003; Wed, 14 Aug 2019 15:07:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F7806B0005; Wed, 14 Aug 2019 15:07:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E5E36B0007; Wed, 14 Aug 2019 15:07:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0066.hostedemail.com [216.40.44.66])
	by kanga.kvack.org (Postfix) with ESMTP id E38286B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:07:23 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4C9D58248AA4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 19:07:23 +0000 (UTC)
X-FDA: 75821966766.27.tank67_5d8d975c51449
X-HE-Tag: tank67_5d8d975c51449
X-Filterd-Recvd-Size: 3314
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 19:07:22 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id u190so19809096qkh.5
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:07:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=zyoIBpx7/gJHmaFznO/SH+g+uzVx91CUA54PVlAZVQY=;
        b=Qez5sgL7Apb/YnWIWGP6n/H3UhluSnVb84n0he9o4TL9RE8ltVbcBfNG/xA2RN5PRe
         CxZlUXpa5olpCIqZCzTY39l5YnAKrhvzrPMnVAuAbXwhSL5bcAp4E+u2sPHlZ13XSgeZ
         XgIB1ZyqYnq7G1H/nZESNIKSaalDfqsRMHzKwhxU/uhBupDEKxl3ORnPAA7CLoKlPmD4
         zzkgESxXZ0pCsLJFpadok+GE8Seg79IG4xy/rAqcWrj46ZPU1ENXgUpX7TTzTzywxMkR
         SCld4EdYriuaE7RMeuBBkbe8yiMPW6mCqcKo6QcF9sdZaac4mnFNqJY1DTERJOFkBv3i
         L33A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=zyoIBpx7/gJHmaFznO/SH+g+uzVx91CUA54PVlAZVQY=;
        b=ZYTgtxFa4nZ/HgsdQVh0L10Nkw2aKB52Wvzv5AzKDSjJmVzLpWvp++KITgmXb09uW1
         5j1ZN8KQQa5ocL4f6bmoAnpnehBZwFKIXaxZ9K3yiDGJ/xI6Oapl1FaW+xvR5MGWr6bM
         fIkGrW7FmAl+IBxi71iyKAJFODjdWISLAAkLKiHDXP8teHhcntBDJLKQnpZHKPzrYUcR
         hpA8GnzhWPAUNrTPP79/bct/l59YUPvjfdM0xg1b/mPNBU6nj/euyG+MuZ7EfKKkkYWy
         K/IPBj4ABWy2XgxPUu2tccDxfaNRcAY2HEe9CKolsIg0CiWswFfRY336UxkGFNLQg9CV
         7gdg==
X-Gm-Message-State: APjAAAVKIuWrE0MewWfPLSHL44mbvH5RUfC7/OzwvqPNNt45brgqmwiN
	ypDy1US+y8Bh94iHZ5/OrnSx0w==
X-Google-Smtp-Source: APXvYqw1P6cMwe1NTa1gC092e9XveAA2gGUcbg3V1W2zUhtNyuO6/ml0oHYwyBVlorz5snc/utKykA==
X-Received: by 2002:a37:a16:: with SMTP id 22mr959766qkk.85.1565809642155;
        Wed, 14 Aug 2019 12:07:22 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id o33sm312969qtd.72.2019.08.14.12.07.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Aug 2019 12:07:21 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/kmemleak: record the current memory pool size
Date: Wed, 14 Aug 2019 15:07:11 -0400
Message-Id: <1565809631-28933-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The only way to obtain the current memory pool size for a running kernel
is to check back the kernel config file which is inconvenient. Record it
in the kernel messages.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/kmemleak.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index b8bbe9ac5472..1f74f8bcb4eb 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1967,7 +1967,8 @@ static int __init kmemleak_late_init(void)
 		mutex_unlock(&scan_mutex);
 	}
 
-	pr_info("Kernel memory leak detector initialized\n");
+	pr_info("Kernel memory leak detector initialized (mem pool size: %d)\n",
+		mem_pool_free_count);
 
 	return 0;
 }
-- 
1.8.3.1


