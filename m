Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE3E7C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:35:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92F6C206B6
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:35:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lsZNpX90"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92F6C206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 454838E0162; Sun, 24 Feb 2019 07:35:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 404A88E015B; Sun, 24 Feb 2019 07:35:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A72A8E0162; Sun, 24 Feb 2019 07:35:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D53688E015B
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 07:35:00 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f10so5021237pgp.13
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 04:35:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=VUSACWx8owSCA/d69ivl0fhPuKN1EhNSteFOcIuEGZ0=;
        b=huF1uVMaH/FHH4MNc56nPvS/Vjk6iiVW170tZZpFzHO+J9z/ebIVMsx+FHY7A6uC31
         UTP3c/jBcM9n5016P1GK7RXswmZsxx431oB5BmmM3vX3Q6dwbFiTc4VA8NGcMqkryMQS
         NM+Nk13dv5eShXUCUq8QpG7jnyf7cR0Rmnaz3YT+vGzqiXtVPMRbaCRrsKxxGsquc+7l
         7Ld+lwhoqlmxHTB4516SXlA09ehCedQWkOzWRDKaXmJ1lzCYktBnQ8lcteQTkZO2y1Z9
         uLFZLmfEPmC5B4Wu67LnFURQvCQUCnQ9fuEd1NdmYE20Utq5h6OT5IWOWGksdvR7eyt0
         3bqw==
X-Gm-Message-State: AHQUAuZkmeJUFevqswA2i9AMkoAG5eyXRjGRxPK/SQcyNHWmKTp29JFy
	/qn10XlC8aGP8mTWEKEt701RbNV0zWtMniMkWCGjz//YpxolosDH4e2KTY0GTJ75JsoYQnh7+WW
	qm33Dq79py0dNCbgT7sMoQkurTKQxI31OcngEhrWZIERHhWE7gDOCO0+cdVf9l4Cfx//xsnDYkw
	846oVFfLJ9tzBO5gQ69qogMUq4JdsG+Ja0VEjSo0woBcJuTflpuO5cKJDzx37glZe9Ukx6TTOZh
	hW/GkzsS/+CuI8A9cCltzF6hwznQuREIvM4vc+aUJLp+zCW7is6dwI6vT8Kw+ECOpn0RSFmGxLY
	aZPwmtEKLzxLBVIaLsau4Sg7gFjGCNmi0F9isNQS5U9jmepP3MUBQs0vURpQr8Xr3fPZsPDnV+m
	D
X-Received: by 2002:a62:e204:: with SMTP id a4mr12697307pfi.225.1551011700467;
        Sun, 24 Feb 2019 04:35:00 -0800 (PST)
X-Received: by 2002:a62:e204:: with SMTP id a4mr12697186pfi.225.1551011699258;
        Sun, 24 Feb 2019 04:34:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551011699; cv=none;
        d=google.com; s=arc-20160816;
        b=G8wuJFLzZjiBusv75ZsMU2T/G18KjNLEjQQmdvjJsPwR2gANiJCO2UWVYf54gyXJ0S
         nkKSfc4D/Ux0EWAM5H2tX0ryFFk0vBPrUxX/0BxsKAwrdANdHNaMylAISQlhxPWKezKe
         tk/rpCkKDF9ow8iJ0XcqRMDJuS+t6nFm+tDzHRpkhm+hb5T7+INFbKtKevt2/wCZDQaK
         CMqvp/Bx2yEqe227A8DE5eYbici5Pux4N0F7+uir57gjVnMv1yArlO4G18gjJqzoAKex
         eyKGtcvORBUOFlW5oAf0w1X94DsE7QP94+B27+72H8HQ7H9AJmZzAwtyq3JNRN/D1L2A
         N8Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=VUSACWx8owSCA/d69ivl0fhPuKN1EhNSteFOcIuEGZ0=;
        b=PKveg7zSZ2mn3zFK0qz7iMQ+qs2qrKYrokyu6ZFFUPABCQdfJgqDDFCIqCcgG1nY8W
         NV3Ofk1zriVqULU+ogrzP+YgGPD7GXkFlXTdQM2JnGuvRhQJvYEWI/akWtN+BeK7o2+m
         PVQxsA1IvZV34dc1mEH9IEHuRgJyEtye5BwrQlHLCIpp5nJN+uzvvIiKhZ0m8dvOaX9F
         o9bXxEpaJGlZpfXeaGjHl9NSwsyGmuuOYPRSAZR5DuduDsFPLGFsG1+CDppvbUB6WW/5
         k23KI+8VZ2ZWZjcYz40GlqWDin+Fe3AR2jWx8Gg1PwI3Sqp0scuJ2vCRPs8n4pPakb4J
         7GnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lsZNpX90;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s76sor10687754pfa.68.2019.02.24.04.34.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 04:34:59 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lsZNpX90;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=VUSACWx8owSCA/d69ivl0fhPuKN1EhNSteFOcIuEGZ0=;
        b=lsZNpX90ShPlWQ2zhfCCGLs4i3irzO/qGpdGtyiAVLlwhyAM9bJBwH1VpoF5hjkhUd
         8EUw47B2VpHPlhkSiDW/2Aqy47CseX4XJEnfPB8suhAPn4E9PESpAclo8hmmoUf1/T1g
         PrwAKcR6kJXWz4z7/qi+m31N9ImyTGhf5MdYqOZGPpeRwD/M0cvl+lZm7cLWMOZUwhdw
         5miumxFV+4Y0Zwjui1NQfNcIczbjE0QoMSvg8smGI+VZ6rCei0hywyQi4dC+iLKOn7da
         vVtpQ1jmIK8mo6jkDkO0Gf9ToiAbrWv9SUSRbzXqbxZuWck6rc+HUwYfsGRG2RnYWdQe
         +rYQ==
X-Google-Smtp-Source: AHgI3IZ+KhDfYa4kZE1/ENHjM5rMoFfQUz/8SRp5zyphLnw8+HWtaHY6Dz/ZQLwOtrZah70pozY1yQ==
X-Received: by 2002:a62:b508:: with SMTP id y8mr13857223pfe.140.1551011699044;
        Sun, 24 Feb 2019 04:34:59 -0800 (PST)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id v6sm9524634pgb.2.2019.02.24.04.34.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 04:34:58 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
To: x86@kernel.org,
	linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andy Lutomirski <luto@kernel.org>,
	Andi Kleen <ak@linux.intel.com>,
	Petr Tesarik <ptesarik@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Jonathan Corbet <corbet@lwn.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Daniel Vacek <neelx@redhat.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/6] x86/numa: concentrate the code of setting cpu to node map
Date: Sun, 24 Feb 2019 20:34:07 +0800
Message-Id: <1551011649-30103-5-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Both numa_init_array() and init_cpu_to_node() aim at setting up the cpu to
node map, so combining them. And the coming patch will set up node to
cpumask map in the combined function.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Ingo Molnar <mingo@redhat.com>
CC: Borislav Petkov <bp@alien8.de>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Vlastimil Babka <vbabka@suse.cz>
CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Joonsoo Kim <iamjoonsoo.kim@lge.com>
CC: Andy Lutomirski <luto@kernel.org>
CC: Andi Kleen <ak@linux.intel.com>
CC: Petr Tesarik <ptesarik@suse.cz>
CC: Michal Hocko <mhocko@suse.com>
CC: Stephen Rothwell <sfr@canb.auug.org.au>
CC: Jonathan Corbet <corbet@lwn.net>
CC: Nicholas Piggin <npiggin@gmail.com>
CC: Daniel Vacek <neelx@redhat.com>
CC: linux-kernel@vger.kernel.org
---
 arch/x86/mm/numa.c | 39 +++++++++++++--------------------------
 1 file changed, 13 insertions(+), 26 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index bfe6732..c8dd7af 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -599,30 +599,6 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 	return 0;
 }
 
-#ifdef CONFIG_NUMA
-/*
- * There are unfortunately some poorly designed mainboards around that
- * only connect memory to a single CPU. This breaks the 1:1 cpu->node
- * mapping. To avoid this fill in the mapping for all possible CPUs,
- * as the number of CPUs is not known yet. We round robin the existing
- * nodes.
- */
-static void __init numa_init_array(void)
-{
-	int rr, i;
-
-	rr = first_node(node_online_map);
-	for (i = 0; i < nr_cpu_ids; i++) {
-		if (early_cpu_to_node(i) != NUMA_NO_NODE)
-			continue;
-		numa_set_node(i, rr);
-		rr = next_node_in(rr, node_online_map);
-	}
-}
-#else
-static void __init numa_init_array(void) {}
-#endif
-
 static int __init numa_init(int (*init_func)(void))
 {
 	int i;
@@ -675,7 +651,6 @@ static int __init numa_init(int (*init_func)(void))
 		if (!node_online(nid))
 			numa_clear_node(i);
 	}
-	numa_init_array();
 
 	return 0;
 }
@@ -758,14 +733,26 @@ void __init init_cpu_to_node(void)
 {
 	int cpu;
 	u16 *cpu_to_apicid = early_per_cpu_ptr(x86_cpu_to_apicid);
+	int rr;
 
 	BUG_ON(cpu_to_apicid == NULL);
+	rr = first_node(node_online_map);
 
 	for_each_possible_cpu(cpu) {
 		int node = numa_cpu_node(cpu);
 
-		if (node == NUMA_NO_NODE)
+		/*
+		 * There are unfortunately some poorly designed mainboards
+		 * around that only connect memory to a single CPU. This
+		 * breaks the 1:1 cpu->node mapping. To avoid this fill in
+		 * the mapping for all possible CPUs, as the number of CPUs
+		 * is not known yet. We round robin the existing nodes.
+		 */
+		if (node == NUMA_NO_NODE) {
+			numa_set_node(cpu, rr);
+			rr = next_node_in(rr, node_online_map);
 			continue;
+		}
 
 		if (!node_online(node))
 			init_memory_less_node(node);
-- 
2.7.4

