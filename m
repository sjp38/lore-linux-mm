Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0C4EC10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 811F620879
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="baZX8c4F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 811F620879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 195498E0003; Thu,  7 Mar 2019 18:00:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11B9C8E0002; Thu,  7 Mar 2019 18:00:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFDBF8E0003; Thu,  7 Mar 2019 18:00:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB5D08E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 18:00:39 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h70so19602721pfd.11
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 15:00:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=BZiJH4Ow73tuiBV88Fygbaz1AoqkBYeF4+n2mjYnICk=;
        b=RAGmC1glg0rvLC8ZXqkXvMF+Vt1JHogzBr4s5M6mGF+IDmo0Ayb4Ac388A2/uwZ1uy
         z/jA0mgm3szjLGNUdN0+B0ataRt9mDPq9XnD04zcf0Q8VhQGinSxZbd7Wzs7TUlWHWmO
         IqIYjJBDluT2guwTGzTqgzl3CTdWIJ33KG3Fl/OtEISRjF0WVcWUPgm31w9fKfyEe3VD
         tpj+O4MJkdCe2LSiNPCF56Xe6TfclfxaX9xAzCyv62ubbRbts/+5Cy2BCVRdKQpsW+3Z
         EvR90ghqa616UHijWIO7cNUo3s8XVWBrEVK9PgXzLYahrXeL659N+Fv+LI+/O9FO38r/
         HmUA==
X-Gm-Message-State: APjAAAUz4ecmqIqot2KXniWmRDfgEmCQo6MKSPINr7VJFydJ4CthsJ7D
	XHebfLdLGv22jJHHnzoiVMZmvunKPWEph0HDbWHO1Ne34pwvuhQ0N+yOn6gaBo/xF15w5jENNFU
	mxKoYlEC7wqYoOafm2RwgdS34ljmXP8qtPKEjFbvmeKP30yNJ/f/hUX9XuD2qxGhgsJ0u7cXL8m
	6u8vhccFwtG3fEMbOr92TQVhFQD3lF/WEzuAYNcdYzKg2U0h/6d/HcJVHJzml2bmH5nzrvC/Vju
	Ya2xpRhqVqSpsCOOszzBtjpkgaGf4P0/DqKUI/8KOynOk8KBPmaTuNIvqq8u4EsCX2NqjWbVKf8
	VnKdH+PeEb3TBK1naWC/hQ5V+04m9anSEpJ5hFdpnEWfvNZjCq/wyy51aJySPDMB2rJ5wF4sRhB
	F
X-Received: by 2002:a62:e017:: with SMTP id f23mr15100682pfh.152.1551999639211;
        Thu, 07 Mar 2019 15:00:39 -0800 (PST)
X-Received: by 2002:a62:e017:: with SMTP id f23mr15100576pfh.152.1551999637902;
        Thu, 07 Mar 2019 15:00:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551999637; cv=none;
        d=google.com; s=arc-20160816;
        b=bdYEcQEah4t98NvKBLIYCpHoQOCRamOGa9hCIEr0yBCY3VsYEyY+fjOJvqgMkorah1
         BHFt0mo+rE4UFgMoX/kNT1gEoSI36V8WppbzjIXj89XkZmHaTX9nNHaf7eGkO2biWVsE
         I8jA4WsvMvVP5pgQSJbgL2byj+KUU/oWdL8XYtsthm9CQvdfEovTWeEmmsdYI82DlSa7
         70CTQA8ENqRK2DyH+oz/w87vZhlOMCdYqktP7YKVSdRNTy83xmJEuESidtCr2XcnQlCq
         bjr0XjjUb8BNZRyre1Si5R8K+lZxeU0MihuP0FXTqBxfb1YC83avj0JiI6g8ZbiHYLR6
         GfQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=BZiJH4Ow73tuiBV88Fygbaz1AoqkBYeF4+n2mjYnICk=;
        b=turSiGjwoNbl69wWmCfQOD4H8itj49od0qOnSIn1XVAv9/IH4DB34QaWITw8nyFCQG
         92eD50JI8ofFX34rcw+D5saZXOv+uU+8y4E5J1TtOF3Sw/pqewR/KslhMBVn63TFmc7S
         Z0osnIA2v1518EvDxE/13EJBEJLtMF15ypi8qJbyxUUklh14zgtF19LULPDQwWH3GsF6
         HsJikSG1BoNMJ9DT5SB2DbHBpR40m+oMfioKuJ3jFf0ek+wckvJYgtYQxVQwoc4l0ZuU
         kAtj2LYMzVhvcwhSxKTgeQzHqb2hTCk9gFjpryz1Zt1EsLVCbC8BUOkuFnmDVyLpmKab
         /d+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=baZX8c4F;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k71sor10026748pgd.19.2019.03.07.15.00.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 15:00:37 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=baZX8c4F;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=BZiJH4Ow73tuiBV88Fygbaz1AoqkBYeF4+n2mjYnICk=;
        b=baZX8c4FlLhpBJPoSRgY7Rp8YON53q0tykAHOZ5cFNIVg+FeYidnaWg0Xc9sGGNEWk
         LCBIUz5cj6+rxQHhInhFStRag16qQA+B2B6NEkHO4vD5bfljuKUoRiMMIT9luBOzntXx
         oSiY+uE4SBXvn9gG3Cr39R20AvM6bDAcTwPcNIwX0/bFBn8uYzDhezkh+hART3E2Ggcn
         jkW2WiGr/jXjr7Y+w2ejT8xwPRas/HzTE66VtqeSFoxNdoxI8UcHalb5OLBQEs7onBpU
         LywumicyLOtWGsmFRNxtchpqZJ6Aqyx+naQuORMV7O9k/HCsKJkM/QwmNSN65dhh/m3x
         hi6A==
X-Google-Smtp-Source: APXvYqyp/acXT9PUFOWKYnSnyfI+ObcfHDsVWEh9a5ooMagR00iidpFsB8sPMRd26yvBPWq0t+bQOw==
X-Received: by 2002:a65:4244:: with SMTP id d4mr13840826pgq.419.1551999637002;
        Thu, 07 Mar 2019 15:00:37 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::2:d18b])
        by smtp.gmail.com with ESMTPSA id i126sm11864806pfb.15.2019.03.07.15.00.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 15:00:36 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org,
	kernel-team@fb.com
Cc: linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 0/5] mm: reduce the memory footprint of dying memory cgroups
Date: Thu,  7 Mar 2019 15:00:28 -0800
Message-Id: <20190307230033.31975-1-guro@fb.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A cgroup can remain in the dying state for a long time, being pinned in the
memory by any kernel object. It can be pinned by a page, shared with other
cgroup (e.g. mlocked by a process in the other cgroup). It can be pinned
by a vfs cache object, etc.

Mostly because of percpu data, the size of a memcg structure in the kernel
memory is quite large. Depending on the machine size and the kernel config,
it can easily reach hundreds of kilobytes per cgroup.

Depending on the memory pressure and the reclaim approach (which is a separate
topic), it looks like several hundreds (if not single thousands) of dying
cgroups is a typical number. On a moderately sized machine the overall memory
footprint is measured in hundreds of megabytes.

So if we can't completely get rid of dying cgroups, let's make them smaller.
This patchset aims to reduce the size of a dying memory cgroup by the premature
release of percpu data during the cgroup removal, and use of atomic counterparts
instead. Currently it covers per-memcg vmstat_percpu, per-memcg per-node
lruvec_stat_cpu. The same approach can be further applied to other percpu data.

Results on my test machine (32 CPUs, singe node):

  With the patchset:              Originally:

  nr_dying_descendants 0
  Slab:              66640 kB	  Slab:              67644 kB
  Percpu:             6912 kB	  Percpu:             6912 kB

  nr_dying_descendants 1000
  Slab:              85912 kB	  Slab:              84704 kB
  Percpu:            26880 kB	  Percpu:            64128 kB

So one dying cgroup went from 75 kB to 39 kB, which is almost twice smaller.
The difference will be even bigger on a bigger machine
(especially, with NUMA).

To test the patchset, I used the following script:
  CG=/sys/fs/cgroup/percpu_test/

  mkdir ${CG}
  echo "+memory" > ${CG}/cgroup.subtree_control

  cat ${CG}/cgroup.stat | grep nr_dying_descendants
  cat /proc/meminfo | grep -e Percpu -e Slab

  for i in `seq 1 1000`; do
      mkdir ${CG}/${i}
      echo $$ > ${CG}/${i}/cgroup.procs
      dd if=/dev/urandom of=/tmp/test-${i} count=1 2> /dev/null
      echo $$ > /sys/fs/cgroup/cgroup.procs
      rmdir ${CG}/${i}
  done

  cat /sys/fs/cgroup/cgroup.stat | grep nr_dying_descendants
  cat /proc/meminfo | grep -e Percpu -e Slab

  rmdir ${CG}


Roman Gushchin (5):
  mm: prepare to premature release of memcg->vmstats_percpu
  mm: prepare to premature release of per-node lruvec_stat_cpu
  mm: release memcg percpu data prematurely
  mm: release per-node memcg percpu data prematurely
  mm: spill memcg percpu stats and events before releasing

 include/linux/memcontrol.h |  66 ++++++++++----
 mm/memcontrol.c            | 173 +++++++++++++++++++++++++++++++++----
 2 files changed, 204 insertions(+), 35 deletions(-)

-- 
2.20.1

