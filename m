Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16CA1C4360F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 18:43:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD7862086C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 18:43:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="J7CZLbqC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD7862086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F756B0005; Mon,  1 Apr 2019 14:43:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43E5C6B0008; Mon,  1 Apr 2019 14:43:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BA356B000A; Mon,  1 Apr 2019 14:43:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD2CD6B0005
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 14:43:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n23so8031604plp.23
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 11:43:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=iRhBAjZz3mos7qscT7fOqIQ3MmerevvmfVCbbH+MZvA=;
        b=sMxubJVmjgfMc0zq1u10Gqjmbsp43qiey+2iZ+MgbsoV5qaJm7lEJHV7Df0v7Guo5v
         +aQCATv3r9COhQzQWHvffw9bXmwnjRBVwO1Dm8ypn7RUhN/yORvj1d3wPao49TI+xKxn
         Fm0BCD+a/49cnuwrXcS/l+U7kgr4hpXZJ/dACxrbAHy4IxyDxPQ022/uDoNd9B7ghpFL
         mmHlGG/XwsiBHqxgeQJG2xibk34j+2+4e+bl9ZejBm/bxp/xdmSlxEH+WeXTUur+X+Nw
         oCO40zXo30o5UAyN0pZc86A7IQ3VZ+Y7DNH9oCjAzU6BzE6odfJpadAXcth36h910zQ8
         apJA==
X-Gm-Message-State: APjAAAVDabUSXYsKV4zg3UljkMARZH8LNeI9UcXPHTGPE5FPEodtkktS
	X1ykkM2OSu0vI9yPF0ehqtCyTLiQEbaEJ2uwJW7usDpHC+SoHwBywnGw4pHhJ8t1hfnxQWQJGlK
	cntb0EGGEfsIPHZy4lmkH90HsT69XLkycirPm5TH71aV/rOWjod+L6HngW+bS7CmLDg==
X-Received: by 2002:a65:625a:: with SMTP id q26mr6654433pgv.68.1554144213400;
        Mon, 01 Apr 2019 11:43:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1W5cvXA9Z+5LT1XyjIpl9Sw4UOWiw0tNf8sDx1DNwxlxeWRjiWlnLoDYICNm5zqbBw4MM
X-Received: by 2002:a65:625a:: with SMTP id q26mr6654352pgv.68.1554144212255;
        Mon, 01 Apr 2019 11:43:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554144212; cv=none;
        d=google.com; s=arc-20160816;
        b=GrgjC1tHm8OaZs548pzvZNfNJN/jZEGh37rrNKm7Wzy6vtVHrvdQV/9UTciCFLBqUb
         7Cot/T9+XlyqgGUwe09E71Xti8SLxHtzSYmmPL2Z7Y44YCCuV9YRAAcMoRVJIYxm4Ip1
         sSJJGFvD9x/JodQXCTtPQzQnzDbqxspfWgD8pDnfG1Cohb0S/O3g4mgEazrM/GSeaVya
         p8p4d6ICIWGEE8fgoJpUNZsu6ozBn7a0yizCAkfKqdnqyeWfHNajByopmTatDCfOQ5aQ
         SJXXzAPs0hFHowJOvTQA/K0Q4eUhyq6QWI4KuaALm5Auxz2DqAMXLlcvnTrS06bgbFXW
         d/Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=iRhBAjZz3mos7qscT7fOqIQ3MmerevvmfVCbbH+MZvA=;
        b=FdXfxEl2EgOlV5oMnM6IIIZICbJJFJ0/ciP6I33ZFTEYPMTh63U/HlqrFyNZNisyiK
         pRBQ01rq5GQwTfonoihrlz7ZR+N7D0cOvpyhM1JdDBHLUSx/jL53Kbd3eL9lGyvjT88x
         Vyrbq6/72XPU9wXjtJ+8xHwutxmjpyngVyQMbkBwoTkN3wlvP1R9+h28+xcT9v0h2+V9
         /UxsaNOHAV9fxiMx60tl2G3SDmAWO6G4GjvZRnkQo6ZvUBfZFZKMbjw/6kWIqJvgPGkS
         T+ZFUCvr59SLEH2pgHgwgNJQtzu9/Rzgi4dmYQz+GBrVH+dRjXXUm8YDnarh6x03kC0n
         PNbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=J7CZLbqC;
       spf=pass (google.com: domain of eugeniy.paltsev@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=eugeniy.paltsev@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id c7si9219155plo.274.2019.04.01.11.43.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 11:43:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of eugeniy.paltsev@synopsys.com designates 198.182.47.9 as permitted sender) client-ip=198.182.47.9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=J7CZLbqC;
       spf=pass (google.com: domain of eugeniy.paltsev@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=eugeniy.paltsev@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (dc8-mailhost2.synopsys.com [10.13.135.210])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay.synopsys.com (Postfix) with ESMTPS id C09B424E28DF;
	Mon,  1 Apr 2019 11:43:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1554144211; bh=/Sb7ii47xyMFrm/jOGOPlK+eRZjqEj1UcszpvGYSL8I=;
	h=From:To:Cc:Subject:Date:From;
	b=J7CZLbqCx4x40b0IM111kgO1xvCa3+eNV0vw9VEw4Mm4R+gH9uOj9ZyDyY8r297Si
	 ZETjNFWMPNAvY89KyNw2HgiyxZe5wOUxqGE5WPnQMoF/AlmPKdIRMp6LVt7HNJqen8
	 WqTsrKDOGZNLEiIvwJxQ0ZUrYnFCdRYIdlk4NPUgZJQ576UUeGaUpUPOSG+2Q7CR7Q
	 +zPcx3ksdIieGe1Buv6zy7ReGn8pcAtQe/N0qbE/c/hou4YVTz1tbyqoEd36nwGeoE
	 AVGOGd1KIefSdMD+mY+g5/zCgynBfA0EE/1ZEjUvd/4M1tT4l5oQmNrCalqE/et1yy
	 NVRV4jJP/uKXA==
Received: from paltsev-e7480.internal.synopsys.com (paltsev-e7480.internal.synopsys.com [10.121.8.106])
	by mailhost.synopsys.com (Postfix) with ESMTP id C4D20A005A;
	Mon,  1 Apr 2019 18:43:29 +0000 (UTC)
From: Eugeniy Paltsev <eugeniy.paltsev@synopsys.com>
To: linux-snps-arc@lists.infradead.org,
	Vineet Gupta <vineet.gupta1@synopsys.com>
Cc: linux-kernel@vger.kernel.org,
	Alexey Brodkin <alexey.brodkin@synopsys.com>,
	linux-arch@vger.kernel.org, linux-mm@kvack.org,
	Eugeniy Paltsev <eugeniy.paltsev@synopsys.com>
Subject: [PATCH] ARC: fix memory nodes topology in case of highmem enabled
Date: Mon,  1 Apr 2019 21:42:42 +0300
Message-Id: <20190401184242.7636-1-Eugeniy.Paltsev@synopsys.com>
X-Mailer: git-send-email 2.14.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Tweak generic node topology in case of CONFIG_HIGHMEM enabled to
prioritize allocations from ZONE_HIGHMEM to avoid ZONE_NORMAL
pressure.

Signed-off-by: Eugeniy Paltsev <Eugeniy.Paltsev@synopsys.com>
---
Tested on both NSIM and HSDK (require memory apertures remmaping and
device tree patching)

 arch/arc/include/asm/Kbuild     |  1 -
 arch/arc/include/asm/topology.h | 30 ++++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+), 1 deletion(-)
 create mode 100644 arch/arc/include/asm/topology.h

diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index caa270261521..e64e0439baff 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -18,7 +18,6 @@ generic-y += msi.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += preempt.h
-generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += user.h
 generic-y += vga.h
diff --git a/arch/arc/include/asm/topology.h b/arch/arc/include/asm/topology.h
new file mode 100644
index 000000000000..c273506931c9
--- /dev/null
+++ b/arch/arc/include/asm/topology.h
@@ -0,0 +1,30 @@
+#ifndef _ASM_ARC_TOPOLOGY_H
+#define _ASM_ARC_TOPOLOGY_H
+
+/*
+ * On ARC (w/o PAE) HIGHMEM addresses are smaller (0x0 based) than addresses in
+ * NORMAL aka low memory (0x8000_0000 based).
+ * Thus HIGHMEM on ARC is imlemented with DISCONTIGMEM which requires multiple
+ * nodes. So here is memory node map depending on the CONFIG_HIGHMEM
+ * enabled/disabled:
+ *
+ * CONFIG_HIGHMEM disabled:
+ *  - node 0: ZONE_NORMAL memory only.
+ *
+ * CONFIG_HIGHMEM enabled:
+ *  - node 0: ZONE_NORMAL memory only.
+ *  - node 1: ZONE_HIGHMEM memory only.
+ *
+ * In case of CONFIG_HIGHMEM enabled we tweak generic node topology and mark
+ * node 1 as the closest to all CPUs to prioritize allocations from ZONE_HIGHMEM
+ * where it is possible to avoid ZONE_NORMAL pressure.
+ */
+#ifdef CONFIG_HIGHMEM
+#define cpu_to_node(cpu)	((void)(cpu), 1)
+#define cpu_to_mem(cpu)		((void)(cpu), 1)
+#define cpumask_of_node(node)	((node) == 1 ? cpu_online_mask : cpu_none_mask)
+#endif /* CONFIG_HIGHMEM */
+
+#include <asm-generic/topology.h>
+
+#endif /* _ASM_ARC_TOPOLOGY_H */
-- 
2.14.5

