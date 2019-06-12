Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 409BAC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:16:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6D2520B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:16:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="osWFZDHN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6D2520B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A2196B000C; Wed, 12 Jun 2019 15:16:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8526F6B0266; Wed, 12 Jun 2019 15:16:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 740D56B0269; Wed, 12 Jun 2019 15:16:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5085A6B000C
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:16:14 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n190so14542027qkd.5
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 12:16:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=VM0X6sjIUXYgIgyRfttiOmJ9MQtVYKp30kcz3vOUcd8=;
        b=PGQdtbzn310GQIJUKrvUEFP95glpTBfCUBrG6RzCKNCjsu4x9CZ4MyDFxkaq4//Fl6
         BB3Dkw+G2g5/EnEHqKajRSPmfBUqCPEaSIme6XVIFUeSUmA9YBhiEnAhhk6ZDgJGxQGJ
         s9hIL1FyV864BLmWOPvwvrOQOa5odhwhpInIXn0JOkH6m2oXYFQxl6jeOzLSymt/5/ZZ
         0KGyknb3cb8qOjlza/t4DGL+Ur/zmO/+UvDLP70sRNyNReYBDNpJO0YvJWYXaDigOHYt
         cB1QZ1QMWBg8CgbAXCJ32ml2JE6WhTsCvG+Qq9GU34j7uRmWGQ8CJR9D+xEjvXUFrRd2
         qkCA==
X-Gm-Message-State: APjAAAVmK7wCaK8JzGbip6C9e65clfVXJ++JIB+mNCwvR/VbcRmzpLhG
	kB7q1hJD+yDUrJ4Qy7qA5XLVxvDyb4RK7IrdgRl5VcqKnn1/FmH1Be9BVxsZfH8isINcyQV5hXH
	refYwX74AxmgDJW9uN4O12ZzFiqpMWQEXr7/i9Bk1qHfncowUErcGbSeDTjUpoFtedw==
X-Received: by 2002:ae9:c30e:: with SMTP id n14mr61927722qkg.220.1560366974047;
        Wed, 12 Jun 2019 12:16:14 -0700 (PDT)
X-Received: by 2002:ae9:c30e:: with SMTP id n14mr61927693qkg.220.1560366973369;
        Wed, 12 Jun 2019 12:16:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560366973; cv=none;
        d=google.com; s=arc-20160816;
        b=Ho/kZVQKUTkRcckaaj+Mt8EZKpigge22i4GryvqmO2T2IkCl8Of/O3QmfTVopQok3I
         4CfhaT8YrvmDS18IgBjxeO1Lr0sZyLQn8hJpr/LvPV3cnCtp9Jtrv5jmf98mOvEpOd+v
         G8ONrNrgZMR91z9Szu4fxCq4d1m/WeszORVXXbs4rfjYuo5edInu1E1iFAc3k5KzTxYc
         JHFZXRjXwk8L3zUFRcAGCwzEXgknB5WMY4l1qQHOuXSL/5+eZQkVm4h5hdJSYY1ZVe6L
         Cj8fVIyLy/m6BZPEi97sFOy/ZQPVErr3uAOGWrbp3IHIYO2P7qI26xa0Sg9UtoF4zVaX
         nSfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=VM0X6sjIUXYgIgyRfttiOmJ9MQtVYKp30kcz3vOUcd8=;
        b=TR1z8Pgap78FnlpufN9meer0tFR8FSx9T+4pKREvJ5lxr9PdUW0Ztgvq45BmsORX7v
         1tGi3RcyOg/Yn4rWeXoYRXcaatXKgSqIOm1AlRe6/eRYA/73gzsFseE/DCTIoOR2AOCO
         wCKq1th1/3Ub2FgCSzHSTKJNqiOglHbr+DQu1HvPEoMcKXRHP1ULS9Sfhsh0M6qxdPn7
         C2owJ4DuDq9oLEt8p3MActVR+Op4g9BNewyFU2jbo+/x2ffkpLjfEg4838X1v8SGfnyU
         ocnJfX0lVp52hqr2BE7/2/MadTtm4kp9+lgI1phlu12H7jPXetTLHa5rC57/awL/o0ec
         edUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=osWFZDHN;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7sor982408qtb.37.2019.06.12.12.16.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 12:16:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=osWFZDHN;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=VM0X6sjIUXYgIgyRfttiOmJ9MQtVYKp30kcz3vOUcd8=;
        b=osWFZDHNmnVngzJkRWmhdL6JobmUmTjdYAA3S1jiMrMfY3FmdHH38icHv8dXo1Tohc
         mSXiMZChJeDdK+U8DMvHPW5aeQO8oKWBgQInrgerdzBRWqEAdKbBTTpYbG7l/KvSHJQm
         aWb6+MdEAuYAsGuzGQSX/eZavG1WjeWvJr8Covmg+XJdIsjtgkmJNfJPZcj7K1fiaTNg
         3pC2hp1o/HKnHMZLH8R4IVfHCmY0jMRECcspcwRN2a0I/M1hPWCtmiefmN6o+Ddx4Ahd
         i4vFCh3B8XD2dlYfMRgKSTj2DTy01/twYA7iKw3x3bJyhHahvFsSQMdT23cTRKPmirRq
         PJWA==
X-Google-Smtp-Source: APXvYqwq5OuLqmcTYHYFkbjfzskyM1J/2vUhrTfX19xKEL2RF3CO3MzulELPQ4bfvgWOTUb6ZbUhpg==
X-Received: by 2002:ac8:c0e:: with SMTP id k14mr29436661qti.72.1560366973092;
        Wed, 12 Jun 2019 12:16:13 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id d25sm209437qko.96.2019.06.12.12.16.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 12:16:12 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	osalvador@suse.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
Date: Wed, 12 Jun 2019 15:15:52 -0400
Message-Id: <1560366952-10660-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit "mm/sparsemem: Add helpers track active portions
of a section at boot" [1] causes a crash below when the first kmemleak
scan kthread kicks in. This is because kmemleak_scan() calls
pfn_to_online_page(() which calls pfn_valid_within() instead of
pfn_valid() on x86 due to CONFIG_HOLES_IN_ZONE=n.

The commit [1] did add an additional check of pfn_section_valid() in
pfn_valid(), but forgot to add it in the above code path.

page:ffffea0002748000 is uninitialized and poisoned
raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
------------[ cut here ]------------
kernel BUG at include/linux/mm.h:1084!
invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
CPU: 5 PID: 332 Comm: kmemleak Not tainted 5.2.0-rc4-next-20190612+ #6
Hardware name: Lenovo ThinkSystem SR530 -[7X07RCZ000]-/-[7X07RCZ000]-,
BIOS -[TEE113T-1.00]- 07/07/2017
RIP: 0010:kmemleak_scan+0x6df/0xad0
Call Trace:
 kmemleak_scan_thread+0x9f/0xc7
 kthread+0x1d2/0x1f0
 ret_from_fork+0x35/0x4

[1] https://patchwork.kernel.org/patch/10977957/

Signed-off-by: Qian Cai <cai@lca.pw>
---
 include/linux/memory_hotplug.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 0b8a5e5ef2da..f02be86077e3 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -28,6 +28,7 @@
 	unsigned long ___nr = pfn_to_section_nr(___pfn);	   \
 								   \
 	if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr) && \
+	    pfn_section_valid(__nr_to_section(___nr), pfn) &&	   \
 	    pfn_valid_within(___pfn))				   \
 		___page = pfn_to_page(___pfn);			   \
 	___page;						   \
-- 
1.8.3.1

