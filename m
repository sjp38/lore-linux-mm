Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 086BBC46460
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:53:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C44BA214D8
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:53:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fJmSQTvd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C44BA214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 568886B0277; Mon, 27 May 2019 07:53:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 519166B0278; Mon, 27 May 2019 07:53:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BAFB6B0279; Mon, 27 May 2019 07:53:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 022846B0277
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:53:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 11so13209532pfb.4
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:53:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=r73YVNUogeQQh2OCQkJ87PCfKvjUOXiqppG1mlJY+tA=;
        b=rIngUfztVdyitlh61n7tkVXy7oGCd/lIlTcyqCLAprSODqatd9OlhlMD10/80OMGOr
         5FGwt57NLut8hiLLxJSnvjIzWvr/ahUoPCKcJKo9V5z6+ij4Si+QQUxWb/uMMAGiKmDK
         4+kbJowfmwFHtFWsFlwqvKqAQGDuQumECrddkmDHB2KPLj9qpGKhcK8UWUT0ktEp3hPI
         37rfiiaLHN/i8rccu+KuNxKnbKmOkKxgz7fXiBPI/OzNV9sTe9w4gOm4d8G0by5ICcRg
         Zr/lZKSbuxn299MMmS6wGe9aZP5Q/9IM61M1eepquhdZAEoTFi86uyCa4lu6s+7+hLtS
         SvYA==
X-Gm-Message-State: APjAAAWT5k5/oGUzwZkB/R842AEjq375kYeppd2UoHnd2gTrVI67xNOQ
	6Hi2g+7l/YxRz28x9lLgD/X7jlDwXo3ZkpGsqz6bZbtWqQq0Zk9G94/Qs/hdeTXQl9E8KtDGfDW
	iQGw0xNCFB85jLw3aOZGKBZ+RtC8c7upWqc1POFCMKKYBCh6+bvEiy4bcXTCmwh6Lug==
X-Received: by 2002:a63:6e86:: with SMTP id j128mr23346082pgc.161.1558958005675;
        Mon, 27 May 2019 04:53:25 -0700 (PDT)
X-Received: by 2002:a63:6e86:: with SMTP id j128mr23346046pgc.161.1558958004871;
        Mon, 27 May 2019 04:53:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558958004; cv=none;
        d=google.com; s=arc-20160816;
        b=LONM1e8r5KS+33lmzfMRhDwtzhgysaUt7x5fS1wiaLn6TUFDB5yQ/z3qvmhGkHEWIG
         U9TtQ5fwQCwXb9ykQXpTeB8AFbhnfrKtBYemawdSsyP4fpb+fngPaVR9YgW6mYo4y+Oz
         olQ+EoD0lfL1darb90L6NSz8E8moCESQ/RJu4SpEVdtYGP3RFGu2kHoMMrlaU46pTsat
         XHSiWQDOPIvUcN20QPwxJZGGSyNumQQOQHZK2iRnT5HQx6ehPX8Qy5IXjWXF9fvsj0Xy
         HG3K4OdiiCRVVVfPNnj+KUHSQjufeAESImX7DVNtqiTJf5Byj1amCB4VMUNk7LyIupFN
         iWQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=r73YVNUogeQQh2OCQkJ87PCfKvjUOXiqppG1mlJY+tA=;
        b=BjQPjZcKOz6Lku2nvBjQCwDIeriVEwesm7+BxZfGkhoJVrbWwF96tNb8hsRlutHXUY
         TdGMXnH3mqpuTBUkc/0SuTGVqdkob8JXv/TQeyWxwZpc9KH/mnez2q9LtNJ2b1kCcErx
         9M4JkodgNZ1Qro2A94f0u1aic8vwylDUbpdjn2l7+ckOcoqiwfjvZjY7E2XX8VrM1d6S
         sQmJuF3JVdjjnccUffHg1ZA7nXtF1hNRJ4Pj80ixPaVW4lhAmzQAmSOb81DBxgsWn2mT
         zxEp8x9yEdc9tg3AhVr+O3Ad0e9VQrpF6AtDC0dN94jhF6NAOutRipYQ+nZzNihQrXdg
         KYMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fJmSQTvd;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c12sor13321005plo.34.2019.05.27.04.53.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 04:53:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fJmSQTvd;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=r73YVNUogeQQh2OCQkJ87PCfKvjUOXiqppG1mlJY+tA=;
        b=fJmSQTvdW57gnQgvaTIRtL77R4MYePh8dHYlQIhgbJq0oCtiWcMLWEsKJquqlLdum6
         04ABXuyugiTd2nahfV/0nubkfTzEzY2cEc8dU90qoJKEAhwXEp3wd/49DaqK4Q0b8aQx
         cZyMC6VoT6L6xeBrOOATUcD1TM9UxytMuGQwLiQVAeqBCcOagTQpnANGedW4LLsvPbr2
         KarWScXsQWDN8zZmczmNxOD3oU50Dcq4bk9RcAgmPBeJBRfWiIyl69igDZWQCdulASWb
         yTT15wAEAI4YER2n2jZy2Wlc3RqEYww7Kc7Aed+hBuOwKuBCJwVz3E1En9BSXcYY6uoR
         K5BA==
X-Google-Smtp-Source: APXvYqzY+Buvm/j/t01cgDGpqZ3/3YHzji+C6RGkEgWdkRqdT+9SHLr222zOgVqgKjliD6UEkUoKDQ==
X-Received: by 2002:a17:902:b713:: with SMTP id d19mr66909393pls.123.1558958004675;
        Mon, 27 May 2019 04:53:24 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id e24sm9797738pgl.94.2019.05.27.04.53.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:53:24 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v2 2/3] mm/vmscan: change return type of shrink_node() to void
Date: Mon, 27 May 2019 19:52:53 +0800
Message-Id: <1558957974-23341-3-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1558957974-23341-1-git-send-email-laoar.shao@gmail.com>
References: <1558957974-23341-1-git-send-email-laoar.shao@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As the return value of shrink_node() isn't used by any callsites,
we'd better change the return type of shrink_node() from static inline
to void.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d9c3e87..e0c5669 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2657,7 +2657,7 @@ static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
 		(memcg && memcg_congested(pgdat, memcg));
 }
 
-static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
+static void shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
@@ -2827,8 +2827,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	 */
 	if (reclaimable)
 		pgdat->kswapd_failures = 0;
-
-	return reclaimable;
 }
 
 /*
-- 
1.8.3.1

