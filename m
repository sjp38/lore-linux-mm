Return-Path: <SRS0=ZOUz=TM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32A5BC04AB4
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 04:35:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBBEE2089E
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 04:35:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="gtj/vqFS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBBEE2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45C6C6B0003; Sun, 12 May 2019 00:35:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40C9E6B0005; Sun, 12 May 2019 00:35:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D4306B0006; Sun, 12 May 2019 00:35:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 11A7D6B0003
	for <linux-mm@kvack.org>; Sun, 12 May 2019 00:35:24 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l20so10834010qtq.21
        for <linux-mm@kvack.org>; Sat, 11 May 2019 21:35:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=dPdaQ04OQMGwU42dwLeynqlwiEFIdM5ipI+2HR6a1s4=;
        b=odyheaVLBp7TMXSwOF7uqxMyuv/e0axWgSKU2dUwKtTBVmP7FCigXIRAni2C0ZqMo/
         PcMzxelMnGny7bpPmrjN+NgNzjNRsDCFnTcB40cpqPq27huGRnheXOGpn4Vru5l7Fstq
         udK7vWPqNAW3p46pNpyu9UZSL2QlyK41StQsgy/eqSM7eWcoGYjDi9qrO/EXZJivmfkj
         w5NviD+DPlBs3xcPhXV6uQfS3vqJJ/BQFbasUwu+6+zn6lVdvgSeCnYWDGvsduWP1h1K
         0+OXFea5pYRLMQJGSOrT4HalaEF+MjB2wPWFX+EKnF9Y9vvprM1/NLUYuSo9W1PpHbMw
         EKYA==
X-Gm-Message-State: APjAAAXoH5UFeWFOc1YaGOUvnzqeX4EtaxCGr52cJEnZ0LABlMOEeYN/
	kKQO4xQrTtfuwaTVOflzlKIiIBKdUwBdOALeNZxlhpU43FPjwuNp7xxHfMWdzuB8ZRYMntF6Y+1
	Of8w/IJcRybQZ8Hzhuk79udcbokgach2X1NWaNZ4MJ8LUjptY0npXcOSL3uwd7ypLxQ==
X-Received: by 2002:a37:7986:: with SMTP id u128mr17051297qkc.45.1557635723719;
        Sat, 11 May 2019 21:35:23 -0700 (PDT)
X-Received: by 2002:a37:7986:: with SMTP id u128mr17051240qkc.45.1557635722776;
        Sat, 11 May 2019 21:35:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557635722; cv=none;
        d=google.com; s=arc-20160816;
        b=0aWTyf0Qh2a6mDkGlnBiHK1ovfAoZxX52JA2ra29kEpBpRObMwhulhHxJMv/kmf1iM
         uLs2rqoZ9lgT+2dcnZG+4i403KaFMtSlrpzmUycnkvLBWAGGGxlEzYjfp4UL1NJBUZbx
         lg4eyi6D3FsjyvmmZ/esgor6zE7NbfoAsaS/dK2LW08jhPfBdiE90ZTDl7IrNlMh6OWu
         Hd9fd8b1Hkk0osPemob+GFUz5gikFeFYv1vk7GGCJyhEncYeqzKd/k7x90bDZnhyrox3
         aRhwewkWPwrPvk0DdxaKVNMm/F3/wspT2bBlCiBo1XMd68x1OR8eNKAOaLgh4Vdcq4UQ
         DR8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=dPdaQ04OQMGwU42dwLeynqlwiEFIdM5ipI+2HR6a1s4=;
        b=k+D7Do79ESPZSR8jAAnIax+n4yxM+uzWD8pZi/hTm0O/ncmIe7xhWtMRtnS2vjlKr/
         SfU40A4wsZkrFSV/PzrcyXNflHLl4kMepPotImpzEGO71WHR5w2YFykFfzmo7TvlLb+r
         4GuMKTIbMBAdMQqPFkbP1kwi+bMpbpj5DAb/QEQt1h0NFc8aynJCRXvfZpngpqEOQGF9
         nZ6fUMPvRvrguNT53VL/KaQ6jsdpc0c0k16qHx5gfS1tNsTpIhdIpe7HCATNhUiDd7/F
         h+S0qnviEWZC9+PDK4PBR9Z8o++jwFZUc/TGBvzfjdm2ubPJqRxFqpcFRQNDuCvW86Qv
         MhYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="gtj/vqFS";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y20sor12655969qtk.52.2019.05.11.21.35.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 11 May 2019 21:35:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="gtj/vqFS";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=dPdaQ04OQMGwU42dwLeynqlwiEFIdM5ipI+2HR6a1s4=;
        b=gtj/vqFS/ws9nX0lxJcywKgYAZdqHJJb4vL/tZ+2R7I6Exl8SCCT7HaTwvmrB2Yj2H
         SUzH4VhZPlI/HROyYk4qt6HtZSax9kDys+YNj6qhlXo4jBaMZaYiCbjf/5uDONIEBTy7
         Tp9d0mTyCX5Gvb5vM7my+jvPZWPq9O5PD4D1kQmMhPS+CHgfrcJIZnzFZRiN5T0mtKUR
         HnQ3U7MuG0YjkJFU/0tPcfOlZ6kShz+RVP1IB9GRzHKbwDIttPMGGRdwKjcDHKLPwyX7
         aZO0Qw7FW/GyAjk5DLGfxwdJhinfsGKM+GpQyYc1PsRSn1XbOpRc6T1MJG7x0eA5GbfB
         GpUw==
X-Google-Smtp-Source: APXvYqzwDUmg+Md2mff4foee6rHIFv6KDP9kS5NCEcqkWVWSn/2AZSbj0Pa5JyccSK9BiECN+H5XrA==
X-Received: by 2002:ac8:3785:: with SMTP id d5mr18133800qtc.166.1557635722507;
        Sat, 11 May 2019 21:35:22 -0700 (PDT)
Received: from ovpn-121-162.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id t63sm4887472qka.33.2019.05.11.21.35.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 May 2019 21:35:21 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	brho@google.com,
	kernelfans@gmail.com,
	dave.hansen@intel.com,
	rppt@linux.ibm.com,
	peterz@infradead.org,
	mpe@ellerman.id.au,
	mingo@elte.hu,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/hotplug: fix a null-ptr-deref during NUMA boot
Date: Sun, 12 May 2019 00:34:42 -0400
Message-Id: <20190512043442.11212-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit ("x86, numa: always initialize all possible
nodes") introduced a crash below during boot for systems with a
memory-less node. This is due to CPUs that get onlined during SMP boot,
but that onlining triggers a page fault in bus_add_device() during
device registration:

	error = sysfs_create_link(&bus->p->devices_kset->kobj,

bus->p is NULL. That "p" is the subsys_private struct, and it should
have been set in,

	postcore_initcall(register_node_type);

but that happens in do_basic_setup() after smp_init().

The old code had set this node online via alloc_node_data(), so when it
came time to do_cpu_up() -> try_online_node(), the node was already up
and nothing happened.

Now, it attempts to online the node, which registers the node with
sysfs, but that can't happen before the 'node' subsystem is registered.

Since kernel_init() is running by a kernel thread that is in
SYSTEM_SCHEDULINGi state, fixed this skipping registering with sysfs
during the early boot in __try_online_node().

Call Trace:
 device_add+0x43e/0x690
 device_register+0x107/0x110
 __register_one_node+0x72/0x150
 __try_online_node+0x8f/0xd0
 try_online_node+0x2b/0x50
 do_cpu_up+0x46/0xf0
 cpu_up+0x13/0x20
 smp_init+0x6e/0xd0
 kernel_init_freeable+0xe5/0x21f
 kernel_init+0xf/0x180
 ret_from_fork+0x1f/0x30

Reported-by: Barret Rhoden <brho@google.com>
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b236069ff0d8..5970dd65d698 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1034,7 +1034,7 @@ static int __try_online_node(int nid, u64 start, bool set_node_online)
 	pg_data_t *pgdat;
 	int ret = 1;
 
-	if (node_online(nid))
+	if (node_online(nid) || system_state == SYSTEM_SCHEDULING)
 		return 0;
 
 	pgdat = hotadd_new_pgdat(nid, start);
-- 
2.20.1 (Apple Git-117)

