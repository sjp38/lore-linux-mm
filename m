Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 330F8C282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:22:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE9EA2184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:22:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE9EA2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 718638E0004; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A3578E0002; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58FEF8E0004; Wed, 30 Jan 2019 03:22:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F24198E0002
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:22:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e12so9037590edd.16
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:22:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=TJO0Zx3zgr6bZWGM/Nb2zUxhbxoNhDHQOJxHEZaXWl4=;
        b=qOTcX9Qm5BOtQdQbddfeWjrCDy9MVBaanvs35KnioY7HDYi9jxuDUENtlMbVU2owjb
         /cgraA26YkPz9vmfmpD1aYRTYcFoJHsskEeom/EJFCZRu273jkR6PaSV0I2SWbM2OS4j
         +g3MaSpuaqzxxV/13/CcFnWLlo3SxjzMQi30FcUQzVtQZnKRK/DUU0V1dKeu6KZ2rd2L
         krgHvnP0blGeabJ9++w7UywXx25sEALdRrRf42wrREpaIogmOAkTObIwlUCbmRmwv6MK
         sFtDged+MMlSu9uZhM1I0T/55kbJomCAq81eeAX6+uy7l2+IKAbzUnYqmlN6b1sflHl5
         lRwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: AJcUukcByPS5JfV2cKRl6K9jdZIj/Y31O8tU3uyPtCiQAd/7RXsoXcK6
	6Fms5+uKezUWfuz5gt08SLhDlIfrA6zWLdnc1BSiOtohEg2unXOeLwqqFG9usyapQUlIVLVjWfc
	Xxyq8tZ2CS+QjL5iB+6k/nbX2Wdx7aO+ChGX2cb9/mgkLM0R/6alVJnCZYsyVdQJKyQ==
X-Received: by 2002:a50:c2d9:: with SMTP id u25mr29255816edf.280.1548836559440;
        Wed, 30 Jan 2019 00:22:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5OQhZsdTuC/cYVIiA1Ikq6HrIxlHC51z6wC8vmX1FX6JgOmAdjs5oTBpf5rEaZ0gX2Q0kB
X-Received: by 2002:a50:c2d9:: with SMTP id u25mr29255735edf.280.1548836557979;
        Wed, 30 Jan 2019 00:22:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548836557; cv=none;
        d=google.com; s=arc-20160816;
        b=1Dwla5ZynrJ15z7kFLRkLd0h+DDHp45nHusSINEU3M7elpUm1+OxegAJCvECYaqof2
         efjQsRIWJwb05TJSqXgN8tA1wXKUhII6IxPokz10zEnZ4R0DmLJb8HkKbyBy9LNPPHvU
         AvHZhLRwldRl/heRb/73RM2bTOILL9t/4V+2maX358H5id+ANRT6ppcboHoP8oErcaOS
         sxhGOwFARA2lUSTjt0nfEr0JWqXINwWvvTyWhGT0TvvxC3Ak8aAB5T/JunBCT25XY93C
         HIsw7Rtdzs7mLnMKgsLMkgXiFdT/k0sKrKTk5lLBuxaAMNnTcsdcZfXGLo6XnJ6/YJti
         3ToQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=TJO0Zx3zgr6bZWGM/Nb2zUxhbxoNhDHQOJxHEZaXWl4=;
        b=a2wxAhyJE4moV0sV1FHfDGRTtuOGIWQaU+MWFRAz7La3VzOVpNnDok5oL9Rccx3rV0
         OlvM2j5q6Z1J0xg1UlGdJxdsqJNRowCjy3lI5edCt8ouact23ZbAf0GvQ74IaSvtR9US
         NHeP4UQWM/R8hqZD/UCjXZys8ovpof57/sQz0BtcUJBfSnuOwxUPJBwpCg+sl+Xcc2Bu
         VwoVWjcXQAg8ZvKbJtubWrpgs008h6PSMg/hlYo3CccaG4yVewf9VefQrigKOoaa9SYB
         n1TEtrhVo01c24sVbJUIZMyCnr+xv7cw8SIPT8XPinPmiIro9CZYN/rMbmAMQ250oVCo
         Ps2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k23si591420ejx.298.2019.01.30.00.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 00:22:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ED07CB0DC;
	Wed, 30 Jan 2019 08:22:36 +0000 (UTC)
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
Subject: [PATCH v2 1/2] x86: respect memory size limiting via mem= parameter
Date: Wed, 30 Jan 2019 09:22:32 +0100
Message-Id: <20190130082233.23840-2-jgross@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190130082233.23840-1-jgross@suse.com>
References: <20190130082233.23840-1-jgross@suse.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When limiting memory size via kernel parameter "mem=" this should be
respected even in case of memory made accessible via a PCI card.

Today this kind of memory won't be made usable in initial memory
setup as the memory won't be visible in E820 map, but it might be
added when adding PCI devices due to corresponding ACPI table entries.

Not respecting "mem=" can be corrected by adding a global max_mem_size
variable set by parse_memopt() which will result in rejecting adding
memory areas resulting in a memory size above the allowed limit.

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/kernel/e820.c         | 5 +++++
 include/linux/memory_hotplug.h | 2 ++
 mm/memory_hotplug.c            | 6 ++++++
 3 files changed, 13 insertions(+)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 50895c2f937d..e67513e2cbbb 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -14,6 +14,7 @@
 #include <linux/acpi.h>
 #include <linux/firmware-map.h>
 #include <linux/sort.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/e820/api.h>
 #include <asm/setup.h>
@@ -881,6 +882,10 @@ static int __init parse_memopt(char *p)
 
 	e820__range_remove(mem_size, ULLONG_MAX - mem_size, E820_TYPE_RAM, 1);
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+	max_mem_size = mem_size;
+#endif
+
 	return 0;
 }
 early_param("mem", parse_memopt);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 07da5c6c5ba0..fb6bd0022d41 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -98,6 +98,8 @@ extern void __online_page_free(struct page *page);
 
 extern int try_online_node(int nid);
 
+extern u64 max_mem_size;
+
 extern bool memhp_auto_online;
 /* If movable_node boot option specified */
 extern bool movable_node_enabled;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9a667d36c55..94f81c596151 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -96,10 +96,16 @@ void mem_hotplug_done(void)
 	cpus_read_unlock();
 }
 
+u64 max_mem_size = U64_MAX;
+
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
 	struct resource *res, *conflict;
+
+	if (start + size > max_mem_size)
+		return ERR_PTR(-E2BIG);
+
 	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
 	if (!res)
 		return ERR_PTR(-ENOMEM);
-- 
2.16.4

