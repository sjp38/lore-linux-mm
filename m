Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0F1DC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:03:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C23921B18
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:03:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="W2HUxGmX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C23921B18
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B86E8E011C; Mon, 11 Feb 2019 13:03:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 068D28E0115; Mon, 11 Feb 2019 13:03:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E72AA8E011C; Mon, 11 Feb 2019 13:03:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B2E2E8E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:03:13 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id y133so8332209ywa.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:03:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :dkim-signature;
        bh=d16B9cEowlIrDNqFOjOpmh5xN3wPEAP2do6FDpElAnY=;
        b=tiS+ah8TdMdtWUOxN6NZjE/kp/tqXxl0LV8uDO8w9Tt5+X2krFPxhoycGZt4pSp4Se
         91SCCz+hiAMkI9dOUchjHVTR0mGwkUmrh+htWxTaugoPApwgvkxcmAaIX9jrDwQQ1pfa
         UF5hz6FeocsT6+Ztk67zk0Mqe6x4ddKLrpdbOI3AHlvYde4/d7yVlgXmf0R3VKW57Mas
         IDbMV06csIF3nBZo4+MZPM0LpqQol2rqBlQuydXVMJS2PotBNNQq7+LnhaHcIRxEfvoK
         j54JeiVjdsk8h+Q3MOHASR3mphm6toQtuUpk20r61lsTKrNZ+Bv2lEFDdmqJ48XtMKKu
         uH9g==
X-Gm-Message-State: AHQUAuZ9JbHXaeTxHuqRs2Y1XfJRSV3CS1amxj8MGK7CXr3kofWAqNAp
	XCu/x4cvT3hSyP6y3UKJOJWXFQ6qfyqUZUE6QTPg31BweDvFj+gYCB0vfgegTlyxNDqghrAbD8L
	3sdLWwHZ4iLxZBTNavjtmnTGNqQfcq198fJRTSmqPW9VSss820cZpPDoghValm+3/eA==
X-Received: by 2002:a0d:d144:: with SMTP id t65mr2213820ywd.78.1549908193474;
        Mon, 11 Feb 2019 10:03:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia/jRnhVTCtJt3lzsv4q9Jwrlxo2dWcx0/YYU5TkgucroNb2MlU3QBjqNIXRKzWNxsv62Aa
X-Received: by 2002:a0d:d144:: with SMTP id t65mr2213744ywd.78.1549908192644;
        Mon, 11 Feb 2019 10:03:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549908192; cv=none;
        d=google.com; s=arc-20160816;
        b=ASt2MPIYsupjqkqxPUHimYME7GlLG1XoLGwqXyxpXSF3qff02YGLwzIfsIVII/j2hw
         UmKT5JJwtBo8H7wP84XgX3ZZOpBg++JOre9qri41BPhPB/4Vz1WcTTD9+Rf1k2L0yz3J
         T/MU5WsL+NHsZqSS8OB01Nwd6bSTwedbDtfCllLLfAQFReKA5bZwPCf5NGbUltZjthw5
         IhHdY8nuyTV+6jMk8nZLqk53zETHpVbPQEDGik4nJIJa+ojRpRZ6Vys/deA/tonSxkZZ
         lLPznDetdmH1iRCMiWQra+qkTTNMoq0a8+qiDxtXOV4SPd1gWwhlhqNN2Ysd1g50ZVVU
         5ncg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:message-id:date:subject:cc:to:from;
        bh=d16B9cEowlIrDNqFOjOpmh5xN3wPEAP2do6FDpElAnY=;
        b=rgsumqGggkFBv7hYyMHyhTT54h9omCU3K+OuHcGMgDQN2krlX/8UcK0eTakb7z+Fwd
         +jTVhOMJGTJ2Ou9InF4cfdBa76N81gvNh0xO8EVKXiRf2AO2x/gSBjesNIn7+OpJ+fSA
         E0AxB37U6//hBpZ1iR8sKkHo2mp/CMi1oGyI0T1DyiIK5v+9i9gjD7d7uypf8/rpSqE5
         znjgzHhWshTEW7n+G2LMo3XKx7Z9nHr6UzauxW8Vx7zAC1pMI/JEkM4ecLqlawG0wp+H
         gw+oA7twL0WS9vANgQqVOZPp8vJFlqv+EXIFn+Bste3233IPt2UHgnTvb2IWdX31XQ9u
         d5ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=W2HUxGmX;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j15si5852851ybp.414.2019.02.11.10.03.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:03:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=W2HUxGmX;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c61b8bd0002>; Mon, 11 Feb 2019 10:02:37 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 11 Feb 2019 10:03:11 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 11 Feb 2019 10:03:11 -0800
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 11 Feb
 2019 18:03:11 +0000
From: <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: Ralph Campbell <rcampbell@nvidia.com>, Andrew Morton
	<akpm@linux-foundation.org>
Subject: [PATCH] numa: Change get_mempolicy() to use nr_node_ids instead of MAX_NUMNODES
Date: Mon, 11 Feb 2019 10:02:45 -0800
Message-ID: <20190211180245.22295-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.17.2
X-NVConfidentiality: public
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549908157; bh=d16B9cEowlIrDNqFOjOpmh5xN3wPEAP2do6FDpElAnY=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 X-NVConfidentiality:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=W2HUxGmXeqLCrBaa4ZfDaV4GdSHUchRdHbrhVMlOGfv1/k5dC3+7taiOACt6oMs5f
	 wX/EtKObQXv6ZHEWb0Gg9vTXZTjzuPpAiEsbY1q4dCY3sEUziEZAsmE9dtbLBcBFMl
	 LFwBp4cQAsM771PDUPvLqtkmR/xSvQpo587Bv6a5TIVbyMErCH10czh7a8nk8XWSkp
	 X5+/yuTc1zXo/1wag0iKY1vm7LqYO4bRrOYmKqN84gZN24f435SQnzld5Yc4DGK5ED
	 7j99Jj8YehVRPjrv8H4PqxnP/IsHqEXmNIH4+VZXuf6MChdV+JuuFqnPMNpBYCroRo
	 08gn3siCY603w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

The system call, get_mempolicy() [1], passes an unsigned long *nodemask
pointer and an unsigned long maxnode argument which specifies the
length of the user's nodemask array in bits (which is rounded up).
The manual page says that if the maxnode value is too small,
get_mempolicy will return EINVAL but there is no system call to return
this minimum value. To determine this value, some programs search
/proc/<pid>/status for a line starting with "Mems_allowed:" and use
the number of digits in the mask to determine the minimum value.
A recent change to the way this line is formatted [2] causes these
programs to compute a value less than MAX_NUMNODES so get_mempolicy()
returns EINVAL.

Change get_mempolicy(), the older compat version of get_mempolicy(), and
the copy_nodes_to_user() function to use nr_node_ids instead of
MAX_NUMNODES, thus preserving the defacto method of computing the
minimum size for the nodemask array and the maxnode argument.

[1] http://man7.org/linux/man-pages/man2/get_mempolicy.2.html
[2] https://lore.kernel.org/lkml/1545405631-6808-1-git-send-email-longman@redhat.com

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Suggested-by: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/mempolicy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1da2f1f09675..af171ccb56a2 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1314,7 +1314,7 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 			      nodemask_t *nodes)
 {
 	unsigned long copy = ALIGN(maxnode-1, 64) / 8;
-	const int nbytes = BITS_TO_LONGS(MAX_NUMNODES) * sizeof(long);
+	unsigned int nbytes = BITS_TO_LONGS(nr_node_ids) * sizeof(long);
 
 	if (copy > nbytes) {
 		if (copy > PAGE_SIZE)
@@ -1491,7 +1491,7 @@ static int kernel_get_mempolicy(int __user *policy,
 	int uninitialized_var(pval);
 	nodemask_t nodes;
 
-	if (nmask != NULL && maxnode < MAX_NUMNODES)
+	if (nmask != NULL && maxnode < nr_node_ids)
 		return -EINVAL;
 
 	err = do_get_mempolicy(&pval, &nodes, addr, flags);
@@ -1527,7 +1527,7 @@ COMPAT_SYSCALL_DEFINE5(get_mempolicy, int __user *, policy,
 	unsigned long nr_bits, alloc_size;
 	DECLARE_BITMAP(bm, MAX_NUMNODES);
 
-	nr_bits = min_t(unsigned long, maxnode-1, MAX_NUMNODES);
+	nr_bits = min_t(unsigned long, maxnode-1, nr_node_ids);
 	alloc_size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
 
 	if (nmask)
-- 
2.17.2

