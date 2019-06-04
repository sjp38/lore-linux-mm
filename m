Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EE3DC28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:01:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC2832463D
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:01:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="FjD0vS90"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC2832463D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB7A96B0270; Tue,  4 Jun 2019 10:01:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B693B6B0271; Tue,  4 Jun 2019 10:01:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A56C86B0272; Tue,  4 Jun 2019 10:01:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 813866B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 10:01:09 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id h198so3678621qke.1
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 07:01:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=HA9nmzXQ1v1EpP1te6eSn7ZdKChVSouT7677WSi9nIU=;
        b=UuP4xtNU89sMPCj8IfT8r2MpvKm876lo4vDMkolCUChm0NGjCds3sMG0TjY6No3A48
         XrvH5yrN6kvZ59SRaEQYAJQQxw4XclXPSR/HG4gc8DdssKAwxK+rMGVXAkm78Eb4YzjO
         SVA/SIKeV6Qm5XFcQhu/NvS6j/AZTqmsBReHXGWUaMzjFtS2zNK2CqCMQVyGOCCirAIJ
         knoc092jk9utdVmVVP80vAMcOOJTGrBJyA7RJZZiuNtsThng+pjp4no5aGGwiewryOud
         ICw6ScE8QGjL6j7NcjW1x7ZvfE/4YxH5tfuFQllcrqOLmiUmUTbEqlNBl0qXL3g7nAnc
         0u2w==
X-Gm-Message-State: APjAAAVdCRqlwCWy100vhFtQaPS6Y06XdJPqvWSwG2JElgbuVP+apLCx
	PV0V08+Yf1mg0aL5SRKzfJ7arWUpopxkORwxo3yzg1jm8qhhfMWfbh+V3kp2mJrjz4fDs6pXyFl
	GW6LRfdkaBTDGtRy+o6V+nMqUW28s1so4JO+ZGLo0SUsVIlK1BsftgsKeMS+JjREcaQ==
X-Received: by 2002:a0c:9305:: with SMTP id d5mr11591577qvd.83.1559656869097;
        Tue, 04 Jun 2019 07:01:09 -0700 (PDT)
X-Received: by 2002:a0c:9305:: with SMTP id d5mr11591468qvd.83.1559656868039;
        Tue, 04 Jun 2019 07:01:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559656868; cv=none;
        d=google.com; s=arc-20160816;
        b=hZmYwDJTL+dyIbvt/Salwk1ldIOF6MlFek9gZnleivrNM0U4PqGpvrR+WZ30DLpK0H
         rvbaAobuJOhbhePACUAOHW8rMuMVOYV9RwpNIgtYFoM6TEGhyV7TBMLC6JbW6iGSuGA4
         ARDBCY8G38CbBT19J4p9a12/+A4MWJuglMi4B597khhPAs220I0Adkmz8/NcOiP1TFwh
         Vm80p2A4Ij4ItQ6cM4ws5R0f0X8JIOsxuPqVJx7Lg9TJ0+qy43DXqXEuvJRAT65DC08Y
         u74gxiTibb6+MAEsJsYdTelBWXyjhTzGO/g8IZVb3eYorZGt+vPk1erWXNbU5iJVa5k5
         DSVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=HA9nmzXQ1v1EpP1te6eSn7ZdKChVSouT7677WSi9nIU=;
        b=YsVMgwPpi23hZ3HVZUXJjvTwFHv8kyivSXWBL/qyagLTvURbwJk61f3+2OfaMiDLpP
         6NLtIkfurqF3iqnqLPQ61Y0vEqvu8fia3wCiCI4UQWW0/YiwbQKEBbS8hHmz6wskXjum
         S9X/0rRFiBnkzPbMRd/mojtjVHMoUajfB8sD8nHpeO0vbBTftygFsM90gDn5D2XF4OXV
         q5uJxyWDM18V0JgGzH01r4SC9qoe3EoB+eGUEz0Q0C/gZ4dZhgey213tr/iTN72ldO0j
         FvTWhtxhp/zSN7q0JuoPJMU9/1pngugYZahAc8XYo+BDoauUeDTMCq51UwdX5LPAnmpY
         jyiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FjD0vS90;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d11sor3765644qvs.33.2019.06.04.07.01.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 07:01:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FjD0vS90;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=HA9nmzXQ1v1EpP1te6eSn7ZdKChVSouT7677WSi9nIU=;
        b=FjD0vS909bew//7s7kZ4U68BxVAcYNK5lIoo28VJ0iR1cKCHo5uwPCWhKdZwvb5R3h
         l+JLi7kgdhHQ1mXfsVZvplZ78xwVC8/ftBcb4Y1CP7AfT7ECrvsLzhzJmhjoXKQ+9YfW
         jkK1KfkjNxpW1xSRKQnYK4mvUMqCOfcP73zC3WHA+ooGIl+psI9Q4jqvA7bBCK7mH9Ef
         w3/bC3nfoSs3iDZfv8dHX2070J87acrVGFg6U4tChzCNpv8wZEvISzXrFjF4d2cH+dQg
         CW65qtmF/xSV9/UwnhEaWAjNq9r1a+ZARBE5OytTmcBx9/3tgsvUzYwtXDaZM5w9ZTBz
         LD/w==
X-Google-Smtp-Source: APXvYqyaYFcOVCNNE4EgaFXVtcyiuzl8/nFtl+bPshTs3JbBCrjCSlVZ/oa+7ymTOAx0gJHRKZE4qg==
X-Received: by 2002:a0c:be87:: with SMTP id n7mr8195030qvi.65.1559656867510;
        Tue, 04 Jun 2019 07:01:07 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id f189sm2340295qkj.13.2019.06.04.07.01.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 07:01:06 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: rppt@linux.ibm.com,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org,
	hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
Date: Tue,  4 Jun 2019 10:00:36 -0400
Message-Id: <1559656836-24940-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit "arm64: switch to generic version of pte allocation"
introduced endless failures during boot like,

kobject_add_internal failed for pgd_cache(285:chronyd.service) (error:
-2 parent: cgroup)

It turns out __GFP_ACCOUNT is passed to kernel page table allocations
and then later memcg finds out those don't belong to any cgroup.

backtrace:
  kobject_add_internal
  kobject_init_and_add
  sysfs_slab_add+0x1a8
  __kmem_cache_create
  create_cache
  memcg_create_kmem_cache
  memcg_kmem_cache_create_func
  process_one_work
  worker_thread
  kthread

Signed-off-by: Qian Cai <cai@lca.pw>
---
 arch/arm64/mm/pgd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
index 769516cb6677..53c48f5c8765 100644
--- a/arch/arm64/mm/pgd.c
+++ b/arch/arm64/mm/pgd.c
@@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	if (PGD_SIZE == PAGE_SIZE)
 		return (pgd_t *)__get_free_page(gfp);
 	else
-		return kmem_cache_alloc(pgd_cache, gfp);
+		return kmem_cache_alloc(pgd_cache, GFP_PGTABLE_KERNEL);
 }
 
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
-- 
1.8.3.1

