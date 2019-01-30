Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEC71C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:22:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 878292184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:22:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 878292184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9C168E0002; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4B338E0001; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939468E0002; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5E38E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so8943885edd.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:22:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=L5h6t+Np/isQKitfbmkgbu8YacllXiQvoo5p0GEfe08=;
        b=VcMABWt0JwPw2yyGUbUIyADgMWfW2TtdKZKrPASUCZx8Gc/tblqR+N/xVuSMMa63Tf
         UdqULvU+O7ViIA+Z/RiFX/RWtRxyIe8ZINXtSR4gsrY+IHJVwU2NWQ9ulTiUlWR7K0jy
         XDpvqHk8OYJm76Y8Z3nq4tZA8zBL0S3SUxIvCJqVSLKK+xFI41uC4TNtI0BVO4w/araO
         F3BzjHNnAb77DXIIHJzWr5jWcutqpG9QffokaEtjs39yFqt4AvJZDMJOpY8/BQDKqhWA
         ePaAp5ZNFQTmSGzqIT6tlBFSIAcK1qiUiQRohmDqrNt+4JjgUdiTrarNOm5MxWI5GkXo
         pMAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: AJcUukfGZO2QaO8J/kCJwB9eKqT+QInTJU2x+LqQMih78rk3Y9w+fJAX
	a/ZVAp/vof4zRtWiE7XuI2oIOndX4+++DFc2hLp+TL6+duK6rrvNh0Ub1I+9P350M8KPoTvI2g7
	bsCCU7fLYdfM6DX+WKKydznSFvZzvXtUDIREt0mfPnBwyVqdNNr3XdJwZowxUYyNs/Q==
X-Received: by 2002:a50:88c1:: with SMTP id d59mr29004628edd.200.1548836559613;
        Wed, 30 Jan 2019 00:22:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4WPcfz3jDYwN3z24sBMkD4zSHG1SyMa9DmB87jXC6wFeRm419InLqBnE0qB8FzPPf8Er07
X-Received: by 2002:a50:88c1:: with SMTP id d59mr29004541edd.200.1548836558003;
        Wed, 30 Jan 2019 00:22:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548836557; cv=none;
        d=google.com; s=arc-20160816;
        b=fhtAr36qvwEE8B4C1+ayeG+Et3hfxpni5zavZe4WoljRbGcYU/jUu1ocWWM8yzr0J1
         dbIiJLHkvqkITEYs7m8VCrxiEbVlPMXV25/3AnONpiUETK8ttiuO8HUBsl1CFxMHlyHX
         /GyeEcEpFhXQVlbiD2IEKe61CzdEGDbKdmSK5CYDvXOcbmtp5XPRVhxD2oySiWqx+503
         ogE0rxgsVeXzFBY7dSX7lAdrkHCNX7oeYIYKDK6OGvJShZmME05CXROGMG9aQoUFSpZu
         /lm6yQtuw0zND3gkg6oGD5j2rFBDdsLVpvR7iqOtbGMpkrt1/V2ATV8ZW4U0vyLar4BA
         Hh1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=L5h6t+Np/isQKitfbmkgbu8YacllXiQvoo5p0GEfe08=;
        b=JT8/hLqAS/EJWdcsCSl8JqUIAokPf3fKCiUG7lmyWREtFLOrJr0E8Bj0H/8MBhomdw
         AGZ3aV8GZislr6gqxPqtB/nNz8ofjV3RKvdujfeYJewDoeSSmwwILr7xiwA2HLlSup4s
         YErBV4qPXpxrSYpNYMjK9jUqPDvJ4lQG9JETM5pkVhsONHL0c+2o9Pq1oiLawJzvnzEX
         oYnBSSlGB/jYJnN5sNN96T48N4A5wA/cRuudmcXyPhc6R6vRXfGl4vH6I/w156MPrcLV
         SMIis+CMq8e0cVXhdIX63iy70rE9XOFt84VuXKJtE+CX55fy8kNA6mlNvZYO6a+OdfQA
         JyKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h35si631535ede.274.2019.01.30.00.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 00:22:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4AD2FB0EF;
	Wed, 30 Jan 2019 08:22:37 +0000 (UTC)
From: Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	x86@kernel.org,
	linux-mm@kvack.org
Cc: boris.ostrovsky@oracle.com,
	sstabellini@kernel.org,
	hpa@zytor.com,
	tglx@linutronix.de,
	mingo@redhat.com,
	bp@alien8.de,
	Juergen Gross <jgross@suse.com>
Subject: [PATCH v2 2/2] x86/xen: dont add memory above max allowed allocation
Date: Wed, 30 Jan 2019 09:22:33 +0100
Message-Id: <20190130082233.23840-3-jgross@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190130082233.23840-1-jgross@suse.com>
References: <20190130082233.23840-1-jgross@suse.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Don't allow memory to be added above the allowed maximum allocation
limit set by Xen.

Trying to do so would result in cases like the following:

[  584.559652] ------------[ cut here ]------------
[  584.564897] WARNING: CPU: 2 PID: 1 at ../arch/x86/xen/multicalls.c:129 xen_alloc_pte+0x1c7/0x390()
[  584.575151] Modules linked in:
[  584.578643] Supported: Yes
[  584.581750] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.4.120-92.70-default #1
[  584.590000] Hardware name: Cisco Systems Inc UCSC-C460-M4/UCSC-C460-M4, BIOS C460M4.4.0.1b.0.0629181419 06/29/2018
[  584.601862]  0000000000000000 ffffffff813175a0 0000000000000000 ffffffff8184777c
[  584.610200]  ffffffff8107f4e1 ffff880487eb7000 ffff8801862b79c0 ffff88048608d290
[  584.618537]  0000000000487eb7 ffffea0000000201 ffffffff81009de7 ffffffff81068561
[  584.626876] Call Trace:
[  584.629699]  [<ffffffff81019ad9>] dump_trace+0x59/0x340
[  584.635645]  [<ffffffff81019eaa>] show_stack_log_lvl+0xea/0x170
[  584.642391]  [<ffffffff8101ac51>] show_stack+0x21/0x40
[  584.648238]  [<ffffffff813175a0>] dump_stack+0x5c/0x7c
[  584.654085]  [<ffffffff8107f4e1>] warn_slowpath_common+0x81/0xb0
[  584.660932]  [<ffffffff81009de7>] xen_alloc_pte+0x1c7/0x390
[  584.667289]  [<ffffffff810647f0>] pmd_populate_kernel.constprop.6+0x40/0x80
[  584.675241]  [<ffffffff815ecfe8>] phys_pmd_init+0x210/0x255
[  584.681587]  [<ffffffff815ed207>] phys_pud_init+0x1da/0x247
[  584.687931]  [<ffffffff815edb3b>] kernel_physical_mapping_init+0xf5/0x1d4
[  584.695682]  [<ffffffff815e9bdd>] init_memory_mapping+0x18d/0x380
[  584.702631]  [<ffffffff81064699>] arch_add_memory+0x59/0xf0

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/xen/setup.c      | 10 ++++++++++
 drivers/xen/xen-balloon.c |  6 ++++++
 2 files changed, 16 insertions(+)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index d5f303c0e656..fdb184cadaf5 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -12,6 +12,7 @@
 #include <linux/memblock.h>
 #include <linux/cpuidle.h>
 #include <linux/cpufreq.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/elf.h>
 #include <asm/vdso.h>
@@ -825,6 +826,15 @@ char * __init xen_memory_setup(void)
 				xen_max_p2m_pfn = pfn_s + n_pfns;
 			} else
 				discard = true;
+#ifdef CONFIG_MEMORY_HOTPLUG
+			/*
+			 * Don't allow adding memory not in E820 map while
+			 * booting the system. Once the balloon driver is up
+			 * it will remove that restriction again.
+			 */
+			max_mem_size = xen_e820_table.entries[i].addr +
+				       xen_e820_table.entries[i].size;
+#endif
 		}
 
 		if (!discard)
diff --git a/drivers/xen/xen-balloon.c b/drivers/xen/xen-balloon.c
index 2acbfe104e46..2a960fcc812e 100644
--- a/drivers/xen/xen-balloon.c
+++ b/drivers/xen/xen-balloon.c
@@ -37,6 +37,7 @@
 #include <linux/mm_types.h>
 #include <linux/init.h>
 #include <linux/capability.h>
+#include <linux/memory_hotplug.h>
 
 #include <xen/xen.h>
 #include <xen/interface/xen.h>
@@ -63,6 +64,11 @@ static void watch_target(struct xenbus_watch *watch,
 	static bool watch_fired;
 	static long target_diff;
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+	/* The balloon driver will take care of adding memory now. */
+	max_mem_size = U64_MAX;
+#endif
+
 	err = xenbus_scanf(XBT_NIL, "memory", "target", "%llu", &new_target);
 	if (err != 1) {
 		/* This is ok (for domain0 at least) - so just return */
-- 
2.16.4

