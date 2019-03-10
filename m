Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 518E2C10F03
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 18:31:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D235F20657
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 18:31:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="OjAJMld4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D235F20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34DCF8E0003; Sun, 10 Mar 2019 14:31:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FAAB8E0002; Sun, 10 Mar 2019 14:31:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 212678E0003; Sun, 10 Mar 2019 14:31:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E85188E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 14:31:00 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k21so2694201qkg.19
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 11:31:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=YM0Wn0jbNjB6y9zmP7dH8GmfHqq62eVgozcbKGDoac8=;
        b=k/NdlHyfu04LpdrVaFtvhxomkJ0XtsA0Jg+T+EljDDYk5z4qJDk/7ztEaoEkdPHfQI
         ZqeysHc+yGxE06xNklEF+aOsaxw430vcGYG45wIKvTeG4oNKXwWtn4XwL6KHEMG0OIOV
         rBtDoosBv1XEExs5Rzk4fAd1SpLdsvYozLHZoFoeThb+7jUyr3xgcJSY3VIY6zzwsmHy
         BIrsw+U+REoq5nYjllXVCzTtm5GKWZBIYPUoIxAOVu2YVuPS2XgzQ3dsUc2jHrYDN6su
         nADILccuvhqg8Xf2qjoJ4GYmC91eXPsEaG7+MDzMu+ADCLqG1bED9IuAS/gL45GfQmmN
         WpHg==
X-Gm-Message-State: APjAAAV+L8RiM7dtc6FywbJ8xTNya0LI0dxcDD8IXxdVfuQfWT0MLXBV
	PNzJZwMXQZ8Z6PzQKfC2+pSzNwIZDHw2RS5w3AFAXG8Hp8sxHc0CrunY1coKAsAUFNNB0q8Vr8l
	YkKi2LmJ0a8DStKm/vvPr2teLtmrfiPyxaDGOCim7KEtBRU2oLyPlvCRRB6lD6ppYBQwo03x6xd
	EKaEJo1oIrPKx0SHARuRpIZUEgTs8vNBKiZPsOLFUwDnixhRkJ4GfMyNSJd5jd1IK0WU+Z13jRq
	HA2DyhzP13K6UsWJ1Yb7kmjq1Y29uWJyUNY1cAMfiP7tmJMm9nBrcz0RZbmzetuNMjnI0ZmjQvV
	gJiHIGrpEwiB3lsgAagsST3XMDwIdfHOQun/DAIA1WS8/xAidJcwMNdjBbK47wHu7Jj3LxVNCjO
	o
X-Received: by 2002:ac8:3f46:: with SMTP id w6mr23526341qtk.175.1552242660714;
        Sun, 10 Mar 2019 11:31:00 -0700 (PDT)
X-Received: by 2002:ac8:3f46:: with SMTP id w6mr23526313qtk.175.1552242659893;
        Sun, 10 Mar 2019 11:30:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552242659; cv=none;
        d=google.com; s=arc-20160816;
        b=xejKnqxsuXUEJiD3x0zakjiVNnRtyomVPJKuR13Gp+AJYioe7rx+yNC1tQdWN3IMrk
         bOyMteuFaAYYcLQWkSFy61l+PacveqWu1XM+8nVaQUDF4d8YaVlF00GvxKIM+VGR5xfh
         UkdiVKhSjtiO0keByAojqrseCj6FIo22K+iHFE0YAS88TNFHNAY10/Us74XxejVIKStx
         RjT6xM3yE/Rm6ISH2ZOBYzd2mTeG2c8/ZnAcREFbcL84sOozDxvYtlxddHfros1b0T3O
         EuwJ4WuxQfWKYzpRCiB7dTvRGBfr/YAXt89y7r0OpsvdapavjthaE0YDqYgNbhv2AmiR
         NqkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=YM0Wn0jbNjB6y9zmP7dH8GmfHqq62eVgozcbKGDoac8=;
        b=XUJIrrYCuGp0PHCOLX6nmJj5DFYRSdNehvqDUYLf/Pn0dVg4dv7ie1b6BKEzJ6BKJi
         quQUun6yf9U6O7kShbpXRT7522wMSiu/0nHrAg+JzQhdFcSXZCX1UHW9k2XvJnHxGkur
         1xBO76KRL8lYbo/ddBF8DEc5oQPSNhbwxKbnIABL0Wh+lUA0Gb/cbdvyoPMFFMAnyOiE
         NP7XVNLWV2ifmg1edkrbFaHOeynM3NMJqs1xI9HQshrAkhaLG5QzuUrEM7zYLJ6thpjp
         1NbenEpV4sh5hCIyWYHnnXofUV39S4y1QDe1wgzMQBPAFOEkY9NfiEYt4Rw0dyBwQ9lS
         DnFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OjAJMld4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x10sor1843904qkf.94.2019.03.10.11.30.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Mar 2019 11:30:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OjAJMld4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=YM0Wn0jbNjB6y9zmP7dH8GmfHqq62eVgozcbKGDoac8=;
        b=OjAJMld40/KT0JAIPx6soIHP89Ze06bD3MGxvBqLe0oL0B5vScTMZQDwEvoGkWyKlW
         V/WKCVRTYFZMJxGUhADvY53i+Xe5Esz2rieFZF5o+7VhP8Z7qV6djQmUAbRfsmiXnRrX
         mkayBOoOtusSvWAwZNV/lAU2/w/6TzNx4geFcwC2ho4gEhBFQS6WHpkelbNE9+vZGcMk
         aXvHLjAntJDwLvn1k1nGiG5y9SoATsC66EQU3RT27so82LXlLpTfU1HPWJpiTCrJHF2F
         mq4s8RtdFsw/KU/YvzIUZp9HGomr7sD9pb30prqzyfTxVFLPrPrJ0L+fFCzu8/X2xSSM
         8MZg==
X-Google-Smtp-Source: APXvYqzs6RndkrdSCNp7wEidhbaphcHOOi4/scuDQle7s3Fl1752DQ6Dc/9nQA5DkP+RbvDT0EZAUA==
X-Received: by 2002:ae9:ed4c:: with SMTP id c73mr1564173qkg.192.1552242659537;
        Sun, 10 Mar 2019 11:30:59 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id f7sm2042200qtb.35.2019.03.10.11.30.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 11:30:58 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: dave@stgolabs.net,
	jgg@mellanox.com,
	arnd@arndb.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
Date: Sun, 10 Mar 2019 14:30:51 -0400
Message-Id: <20190310183051.87303-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

atomic64_read() on ppc64le returns "long int", so fix the same way as
the commit d549f545e690 ("drm/virtio: use %llu format string form
atomic64_t") by adding a cast to u64, which makes it work on all arches.

In file included from ./include/linux/printk.h:7,
                 from ./include/linux/kernel.h:15,
                 from mm/debug.c:9:
mm/debug.c: In function 'dump_mm':
./include/linux/kern_levels.h:5:18: warning: format '%llx' expects
argument of type 'long long unsigned int', but argument 19 has type
'long int' [-Wformat=]
 #define KERN_SOH "\001"  /* ASCII Start Of Header */
                  ^~~~~~
./include/linux/kern_levels.h:8:20: note: in expansion of macro
'KERN_SOH'
 #define KERN_EMERG KERN_SOH "0" /* system is unusable */
                    ^~~~~~~~
./include/linux/printk.h:297:9: note: in expansion of macro 'KERN_EMERG'
  printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
         ^~~~~~~~~~
mm/debug.c:133:2: note: in expansion of macro 'pr_emerg'
  pr_emerg("mm %px mmap %px seqnum %llu task_size %lu\n"
  ^~~~~~~~
mm/debug.c:140:17: note: format string is defined here
   "pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
              ~~~^
              %lx

Fixes: 70f8a3ca68d3 ("mm: make mm->pinned_vm an atomic64 counter")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index c0b31b6c3877..45d9eb77b84e 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -168,7 +168,7 @@ void dump_mm(const struct mm_struct *mm)
 		mm_pgtables_bytes(mm),
 		mm->map_count,
 		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
-		atomic64_read(&mm->pinned_vm),
+		(u64)atomic64_read(&mm->pinned_vm),
 		mm->data_vm, mm->exec_vm, mm->stack_vm,
 		mm->start_code, mm->end_code, mm->start_data, mm->end_data,
 		mm->start_brk, mm->brk, mm->start_stack,
-- 
2.17.2 (Apple Git-113)

