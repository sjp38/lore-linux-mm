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
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7189C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:35:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64195206B6
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:35:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iY5qksCI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64195206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 149B08E0163; Sun, 24 Feb 2019 07:35:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D2868E015B; Sun, 24 Feb 2019 07:35:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDDD78E0163; Sun, 24 Feb 2019 07:35:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA6788E015B
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 07:35:08 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y8so5038545pgk.2
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 04:35:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=0NMCKN566TqKrSROT1OL4y1pVAJFuioGBAgJ45OiBK4=;
        b=XarrJZHyy/y1+dSYeddp7SoSf/D/Wc6lRqYL234m9qr3isR+ri7qx7Bn9H7Tz5X2dU
         Xplps9YlGWPS+Q8CeWqMThwSOju/Yki83bNbDJhw+D2NnbCi4ZUePCH5vtwdORienaN7
         FPP64aigF7bNgCEDqfqdwyNZlbgZRw8fY32Bk/TnujarhBTsn6EJn2EFWKcT/zYsldKv
         1cgULRQb3Fy9HGzrOGQDeDi31S8IOLlXjMlQ+wtilX0oXs4u6WXWVDPiA3eoPdBMeYt9
         dhHWHjw8vSaU+5B/5SyqivmQtJ7Ow5RTW5WB6Hlp5Rcd9XtLh0u3ilRq1M3X8qfDgQSX
         L1vA==
X-Gm-Message-State: AHQUAuZWJh+UjbauvVTg7xS1NEF70tupCUgXzBsy3rEJTkK71Q3t7bbj
	B1ioyyMadrA2iY9tmP6QU4v3ZzvKKnOF0+LIKxGMBw5+6x1goSIYXOREFy99rXO7bA/3DXh1zI3
	cwbRlH5/RF/JEjbYA9xJtgP+jisVu59gUka1TEFM9B9luuc+drxiwaegWBPcvQ5od6UfnxRyNhv
	AcT9PHX5khre23f7bYTITpMFrRkrZ03HwICRpUUDiIqQ4fgMWxxK6H3IM8sdO6Qp7q/smJ1f/yl
	5IERjwXFVX1x9u9qimhKgl3uWxKmrG0jvwKX7dq0RedR/2zifNS7gzs+ScuzOCz0A93lp+FwKRW
	9Q7m7BvMqbrymk9AdQPP6vsn0NtC/zZPUO2iitkQLUlZsrGGjvjT9Y1NxxiMuOHFOmS8pncWRC7
	n
X-Received: by 2002:a63:dc54:: with SMTP id f20mr12941757pgj.410.1551011708362;
        Sun, 24 Feb 2019 04:35:08 -0800 (PST)
X-Received: by 2002:a63:dc54:: with SMTP id f20mr12941628pgj.410.1551011707060;
        Sun, 24 Feb 2019 04:35:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551011707; cv=none;
        d=google.com; s=arc-20160816;
        b=cO3erMlHc3MXkKAA7HuA4sVF05Z6B3iRPx6X6R0EGilFYon1PDaO7zojq5w6UIV+V0
         v8FmyZjprq5ffaMFTH9VJ8qOJwy5kNQZbLwvoKzBqzyCjTNlPzRe5NwmgS8rM7Cyczw9
         ZDMwhqrpSmCsjqYZyicW7HzqH2PANWzY6b+LNAK5++3Y+moMhZtmTbGwYdRpguFgq108
         fTe2gBAgUmGwd0zPGb3VJMECXsrIIJGABfMFjWxSj+ZbuJbodWJ5kgDhOlLTmQg9nyW4
         A9+IXoNLOatgDPXD/+DS5UGEm9SfWsPEcfoqLBSLrZ+AWpAdgTUcG1E/xK7WB70xaWdf
         lF3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=0NMCKN566TqKrSROT1OL4y1pVAJFuioGBAgJ45OiBK4=;
        b=Sil0US3Z6J8WndL/F7m+wsJy35Eqdq+Vgc5JEFOOtps2ULZLstYyFP27LHHQAIPYdR
         hHF5Bq36Zv82ld2xpefWFJyiqk5hhDfFZoJm8eXYIQbqRbFwTlsHS5QMSlMmEb7s1vjo
         BtRG1EWV5ozIuE4tXozz2uaMx/8AFK5UsEsRXFEUMyrYNthMq3o4LAOJdSeuiVrYhtVe
         cPWdHohf4JbXIkWxrkF7Bh6z4F3kMHrRwvcs/nL1On5gnfkzwjfrfKI8tmm/+2Y82cE/
         o3+vnWfHdstvOL6fuW6K+6wIo6tDHxRXwk5NQVAWPFBa0q0d3OC7QzAH4syyP3MwvJ9c
         ZLVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iY5qksCI;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r14sor9815696pgf.79.2019.02.24.04.35.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 04:35:07 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iY5qksCI;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=0NMCKN566TqKrSROT1OL4y1pVAJFuioGBAgJ45OiBK4=;
        b=iY5qksCIMpNU389QUSs7IU3yhYB8G0qeGuofPuj7VOiuoUKF3lEIfU0EIj4vIyZGxy
         lfGuvV+dKLpk9vmJOA8iGOZeVGx1R5OoJTYMgUmJp3746nRHEl0S2MLvX5k033Nv//84
         mDo14vacdwcpGP4nPjXiBuFbH4AHdrcqN6IsJBRmpNv+fK1FORzwuFvX/wZKblimKkQP
         H9XH3K4Eom4q4IXXZbXjw3E4kEAZerpxutrYN0lNUcpo3BsJCUHJTK9TcTLXrimeAne8
         2Oy7y5IfhCi+Y+NMgXPpNQ304JNgsNYrJ6xo/gzm0wA6P/YV5Mayp/k+DBLWEA96+TmJ
         7LjQ==
X-Google-Smtp-Source: AHgI3IYKZHrDENP+56CRPPar4fsatj4I/ajY/II4jFQQaKk4J3r7faH8maH7gEv4Z3POa7YL/eMOUg==
X-Received: by 2002:a63:d814:: with SMTP id b20mr13029128pgh.312.1551011706824;
        Sun, 24 Feb 2019 04:35:06 -0800 (PST)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id v6sm9524634pgb.2.2019.02.24.04.34.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 04:35:06 -0800 (PST)
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
Subject: [PATCH 5/6] x86/numa: push forward the setup of node to cpumask map
Date: Sun, 24 Feb 2019 20:34:08 +0800
Message-Id: <1551011649-30103-6-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

At present the node to cpumask map is set up until the secondary
cpu boot up. But it is too late for the purpose of building node fall back
list at early boot stage. Considering that init_cpu_to_node() already owns
cpu to node map, it is a good place to set up node to cpumask map too. So
do it by calling numa_add_cpu(cpu) in init_cpu_to_node().

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
 arch/x86/include/asm/topology.h | 4 ----
 arch/x86/kernel/setup_percpu.c  | 3 ---
 arch/x86/mm/numa.c              | 5 ++++-
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/topology.h b/arch/x86/include/asm/topology.h
index 453cf38..fad77c7 100644
--- a/arch/x86/include/asm/topology.h
+++ b/arch/x86/include/asm/topology.h
@@ -73,8 +73,6 @@ static inline const struct cpumask *cpumask_of_node(int node)
 }
 #endif
 
-extern void setup_node_to_cpumask_map(void);
-
 #define pcibus_to_node(bus) __pcibus_to_node(bus)
 
 extern int __node_distance(int, int);
@@ -96,8 +94,6 @@ static inline int early_cpu_to_node(int cpu)
 	return 0;
 }
 
-static inline void setup_node_to_cpumask_map(void) { }
-
 #endif
 
 #include <asm-generic/topology.h>
diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
index e8796fc..206fa43 100644
--- a/arch/x86/kernel/setup_percpu.c
+++ b/arch/x86/kernel/setup_percpu.c
@@ -283,9 +283,6 @@ void __init setup_per_cpu_areas(void)
 	early_per_cpu_ptr(x86_cpu_to_node_map) = NULL;
 #endif
 
-	/* Setup node to cpumask map */
-	setup_node_to_cpumask_map();
-
 	/* Setup cpu initialized, callin, callout masks */
 	setup_cpu_local_masks();
 
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index c8dd7af..8d73e2273 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -110,7 +110,7 @@ void numa_clear_node(int cpu)
  * Note: cpumask_of_node() is not valid until after this is done.
  * (Use CONFIG_DEBUG_PER_CPU_MAPS to check this.)
  */
-void __init setup_node_to_cpumask_map(void)
+static void __init setup_node_to_cpumask_map(void)
 {
 	unsigned int node;
 
@@ -738,6 +738,7 @@ void __init init_cpu_to_node(void)
 	BUG_ON(cpu_to_apicid == NULL);
 	rr = first_node(node_online_map);
 
+	setup_node_to_cpumask_map();
 	for_each_possible_cpu(cpu) {
 		int node = numa_cpu_node(cpu);
 
@@ -750,6 +751,7 @@ void __init init_cpu_to_node(void)
 		 */
 		if (node == NUMA_NO_NODE) {
 			numa_set_node(cpu, rr);
+			numa_add_cpu(cpu);
 			rr = next_node_in(rr, node_online_map);
 			continue;
 		}
@@ -758,6 +760,7 @@ void __init init_cpu_to_node(void)
 			init_memory_less_node(node);
 
 		numa_set_node(cpu, node);
+		numa_add_cpu(cpu);
 	}
 }
 
-- 
2.7.4

