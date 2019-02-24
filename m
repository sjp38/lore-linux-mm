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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C2EAC43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:34:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75EC320842
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 12:34:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZgJwtGqu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75EC320842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 171FD8E015F; Sun, 24 Feb 2019 07:34:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F9B38E015B; Sun, 24 Feb 2019 07:34:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F036D8E015F; Sun, 24 Feb 2019 07:34:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACB6F8E015B
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 07:34:36 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f6so326410pgo.15
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 04:34:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=Z3yLpMlCMDsuGaB02cG1XH8xADN3ETXn1vX/kUyoKIQ=;
        b=CsOIH9yVpbBJoHWfoFbBukWglrI6d9Wflw8omg2vS7+hq5qKUPzpXpRitvfl62iENO
         wCN3Ky+DoQQsUl/C4f92mwezgCWFenbogFbgsZTdQ33Id3B3pAJLeO8HvLwXAJE+JKb0
         sYQHb+6iACqrQFCFUcHNa/gp7a/9z1P5jlc6nH1hpcxHCGPsfhVLYikYjAPsNdq5zPty
         uPVskU6+iN6m18SCiewEW2MzSHLKxQo8XYXdrQ+iOzTDy0+KgD8sPR0hYjHrNUc6VOX7
         8PrSozpWg+U7I5EeEbW9A9cHEKNwpNVeLxQUceUf3vLG653cqUoCGIotHCDmEeazMrBL
         3x1A==
X-Gm-Message-State: AHQUAuZ8zqcOmT0C0L+mPPWo8d3ebSYXatmmUgERJ5wqk+FJ573DUl7O
	dy5eYrdqMDB6SjCOyJtR1PB4nQaOhtw/mZGzS+stnumLQEmc9Gz+UayaivjHsH5+RUQMjDTp4sE
	f7Z7vvXGZdrfI/8ZtqIneCmRrTznYrweK1m693EFzagQ14+Ze8MptsXr/mY1AP37dHu3ANnAldO
	riOkN90V/Zg/+sG72etNpz1tYi0PmH7kme5XYqlMro9EOqnRENy0TL1x2NeHCeJpmtqL5d1FNGO
	ayn98TaciVMso7XTMeQfNn3NrllkrAen+ON3Po/8VIHh2L0Mx6QaBN5PXgaS9tDg2WlZqOCedfE
	bbWRj05sq9oIEf3Xz+4tVAI2dLn/qQw2jSdMeWdgFY2zYkVdawkwcHdh8N3lujSl8lQFHVwP0jD
	m
X-Received: by 2002:a63:7c07:: with SMTP id x7mr12998538pgc.284.1551011676376;
        Sun, 24 Feb 2019 04:34:36 -0800 (PST)
X-Received: by 2002:a63:7c07:: with SMTP id x7mr12998420pgc.284.1551011675076;
        Sun, 24 Feb 2019 04:34:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551011675; cv=none;
        d=google.com; s=arc-20160816;
        b=p9MQGfxJpDihkuo0hAuUMmJ76Wm17XcbsFTKUI5qlS4FPnlPK37Kk12vtjKkgisyOl
         vszgEghA1puoQxyCGrF2sjl3QyIpfJSSfxLpErA2IHfE8PZgaWfpll3J8pibVThKRU5F
         LdELnh+oFrC71OeOVkNPfLRQyXns32mymn7tvQGbw7tqtwcKm3zmATl9KjOqODI7SIXg
         krInXzYVGAj+hbadzjz0PmB2btlf7VBS9FNa5KAenSfIdYWxOYb3mpoWkOEK8qHFMuRe
         iSF/vJ5J6fIKDY/3MULpy1zn3j5RCgCcSvl/OW6seixq0ct/DZOQlj5dvrbPfdOQs8CB
         rQgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=Z3yLpMlCMDsuGaB02cG1XH8xADN3ETXn1vX/kUyoKIQ=;
        b=GpamsqmWZcG3npeOX4MibwUjxPbnc9uEgag2oVGRk2wiYIbOIeHv5ihWC6CuoP/7d8
         AERS/De7wk5Dbpu3niPUnYKdCbzBR3PnUF8/W7LSGatNFjbS/fZzkwZjANlGDowGkgHi
         ubkKfXc5vidiEMd9mnT0LhscV6e310cP2l8Ejlzmy5jr25E+BSQD03ZvmZGG2KX2TYP3
         B7opBd2qq0wRQVfbKQjsDbhpKDhmaxsSN7TS+h/RKrmnQJ/rCQ2Hx4aS9Ah20CBwtOwi
         gQeaYaVaFD5t+5EK2Xrbz+pVjIF9H8JvkcPw9XShcY2ih+j4YSxUSMeZFNI5m2s0iWwj
         gVaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZgJwtGqu;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 142sor4590673pfb.41.2019.02.24.04.34.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 04:34:35 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZgJwtGqu;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=Z3yLpMlCMDsuGaB02cG1XH8xADN3ETXn1vX/kUyoKIQ=;
        b=ZgJwtGqu+tpzE0Sxv2rBnzGQOgVnCbdTJWs6MlhjOmVcjzel2NnOzxLme2jKbjJeWe
         xK0/5o0ecLLOWPHsXZKzSd6zgbi7Ayk+jVC1UbUyutgKRnaFKMBtok7NFkgjPNZ/voKE
         6/XH+Rjq9TG++FECnruQColXNmEGsflDw1NKZgJO7HaQsR/mQK++9vNVs4r6xkvqACoE
         oB8bw1zJBJWrwL/fuz09qFJxdRjB7yZPwM4HlkNs2M3SXI+eTm5+mzL7Rp1hEkECGZj5
         ens5fMQO1UEowLbb2bvLHeJoDvWDbG457M+NyhXmt+9+0nZvp6Z7WOOWsKQHrNWtJAWG
         tpaQ==
X-Google-Smtp-Source: AHgI3IYYsWafgP2p4U1Cc1O2opO2btKPmB4WsQkz1bQsdyYsJYn8g6ToK1eA9OuugrJ1Yvpy3NyY5w==
X-Received: by 2002:a62:ee03:: with SMTP id e3mr13962942pfi.241.1551011674749;
        Sun, 24 Feb 2019 04:34:34 -0800 (PST)
Received: from mylaptop.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id v6sm9524634pgb.2.2019.02.24.04.34.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 04:34:34 -0800 (PST)
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
Subject: [PATCH 1/6] mm/numa: extract the code of building node fall back list
Date: Sun, 24 Feb 2019 20:34:04 +0800
Message-Id: <1551011649-30103-2-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In coming patch, memblock allocator also utilizes node fall back list info.
Hence extracting the related code for reusing.

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
 mm/page_alloc.c | 48 +++++++++++++++++++++++++++++-------------------
 1 file changed, 29 insertions(+), 19 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde0..a6967a1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5380,6 +5380,32 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
 	zonerefs->zone_idx = 0;
 }
 
+int build_node_order(int *node_oder_array, int sz,
+	int local_node, nodemask_t *used_mask)
+{
+	int node, nr_nodes = 0;
+	int prev_node = local_node;
+	int load = nr_online_nodes;
+
+
+	while ((node = find_next_best_node(local_node, used_mask)) >= 0
+		&& nr_nodes < sz) {
+		/*
+		 * We don't want to pressure a particular node.
+		 * So adding penalty to the first node in same
+		 * distance group to make it round-robin.
+		 */
+		if (node_distance(local_node, node) !=
+		    node_distance(local_node, prev_node))
+			node_load[node] = load;
+
+		node_oder_array[nr_nodes++] = node;
+		prev_node = node;
+		load--;
+	}
+	return nr_nodes;
+}
+
 /*
  * Build zonelists ordered by zone and nodes within zones.
  * This results in conserving DMA zone[s] until all Normal memory is
@@ -5390,32 +5416,16 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
 static void build_zonelists(pg_data_t *pgdat)
 {
 	static int node_order[MAX_NUMNODES];
-	int node, load, nr_nodes = 0;
+	int local_node, nr_nodes = 0;
 	nodemask_t used_mask;
-	int local_node, prev_node;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
-	load = nr_online_nodes;
-	prev_node = local_node;
 	nodes_clear(used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
-	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
-		/*
-		 * We don't want to pressure a particular node.
-		 * So adding penalty to the first node in same
-		 * distance group to make it round-robin.
-		 */
-		if (node_distance(local_node, node) !=
-		    node_distance(local_node, prev_node))
-			node_load[node] = load;
-
-		node_order[nr_nodes++] = node;
-		prev_node = node;
-		load--;
-	}
-
+	nr_nodes = build_node_order(node_order, MAX_NUMNODES,
+		local_node, &used_mask);
 	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
 	build_thisnode_zonelists(pgdat);
 }
-- 
2.7.4

