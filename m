Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08C7FC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 22:47:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E68B2081B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 22:47:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="oOQpDEP9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E68B2081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C59FE8E0003; Fri,  8 Mar 2019 17:47:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C09468E0002; Fri,  8 Mar 2019 17:47:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF8978E0003; Fri,  8 Mar 2019 17:47:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 821448E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 17:47:05 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id g42so4146122qtb.20
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 14:47:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=SLDY+eriUJJSKq4W6Dwhx/si0YT+O7+wGloz1ULmQTU=;
        b=ZcpExKtU7h3OUn003m3ZSWsQEZ+y9xl+iqj5lzq7PwWc5tTCjvebr/kb7bU3yU0Rbj
         BtIMTpdWCNkESdSg0Z+P5/vSOAfcMLcRY+x/GnztpX+j3ochZGFkQc2VkqYB852oNIo+
         8qeZeDDr3+zwHsExEHXDg7XxeAj5oQ3K9qOP1r9qGcqfLUWV7gCysAsu/u5kNc9A8hVA
         KPHTKqq7EXv+hwI3bwlU5jUekd+X5kunmVkQoB3YNeDb6Z7VhIoF5E7OiNdaGp+CTg5s
         dbKs1Aj/UoLNPIxRSxqQa+wekAUowTNmZmMuCKBqZD9kwy+OZT0kJIY2Bw7zljlPMRwf
         zPKw==
X-Gm-Message-State: APjAAAXFHKQKjjJ/pNriZ/EW9Wl/aK3FU5qky6DsdN13RqG+a4OrNRnm
	8nbWu4eJuubbIu1DgO2GBTyAzL0pHOX4BN8XTlVXZdG74QdUWQpn/AoAT98wcdxqD+uQhaFYVyq
	/RsdFlFBIQeXbm1WxD+KJiq+4fX2nwuBH/6Q0M+A5m/FeyQ1A93uDsMWRSDgep3raO1RLjjis/G
	WRIfdWIVdDrc1zZlkozUtEnriIM9d0z53TuaCCDrCabNJqN1ugSkiDfVGFz4JilIz/Bu/wCD3N8
	Di4VJoad9fIeTIQETn9Vw6Htcm6LtV7HerST9hUKCN/iTEcKgrMmKbJQ7xBw45kNJ4Skhzwl7jr
	mcity/P5Xkdxi92xe7n7s6JmEKKA/Nggb90wxKCRjK2VBe2ql055bizgskog1jdzmbUnEKIxJXU
	I
X-Received: by 2002:ac8:228f:: with SMTP id f15mr3917478qta.286.1552085225227;
        Fri, 08 Mar 2019 14:47:05 -0800 (PST)
X-Received: by 2002:ac8:228f:: with SMTP id f15mr3917438qta.286.1552085224472;
        Fri, 08 Mar 2019 14:47:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552085224; cv=none;
        d=google.com; s=arc-20160816;
        b=pFiWLbuCm/Dx/+nFC0nfPtjz9Ffx2D3VleQs1rEsjjXDLRBSLhyym3evU9urTfe8to
         m7Vhoben6eETVlBvSENbeXkqEpMOh7lW73no3Lu5Ejedla7d8kj/S2NpSrIlgBPjiHg/
         WIIhE1kVwSH3hilUFMY5SXhJp0J5MwEEjFOdRPTwGSZsDK1aMI+vjEaAbPv9Ds306cmR
         KF0lslPN08mHW6yC3w9Uq2g7JKF1qNt7l2d1igduQb42ZmUCUzjIwaa4S4TPsAmr+N3T
         ema60aN0Astx4A9JVzmgw2Kr9DKrInCQPP29Z1LzlLnrwb38CThGBKaBSt10o33RVGAt
         pKdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=SLDY+eriUJJSKq4W6Dwhx/si0YT+O7+wGloz1ULmQTU=;
        b=LNDjUlqTQc5ytitOYQnG1mcnREQqxA9y4YIOtPXfG8zyTxWFOL1R7MQ9af96dmTDX+
         tT2dNC08OXxcVjgSNAkn1HBQujgVni213gTZUbs1OlSFuSCO03RB7pLsg5aTbR5mYvXE
         vJ6kpzIGqWOOOhEC2rRZOJ4PsuxtTl603zCpCZf++BVY3GY6e8jmI4r+kB6Jb1x72w2e
         DWoo1zafKoqBD2dV6BKp1oxX/L51o9nbzN8rBMTzUVlOrBPMPRrt6Cr4d1+xVgqJeMOZ
         2rXsbLNK7PYpWmgxvXyzLs/CTZnygIfC6WGn4KfEiy7iAewD2/EvlODBMZKs7eDe9xaQ
         UyMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=oOQpDEP9;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p45sor11247071qtp.35.2019.03.08.14.47.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 14:47:04 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=oOQpDEP9;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=SLDY+eriUJJSKq4W6Dwhx/si0YT+O7+wGloz1ULmQTU=;
        b=oOQpDEP9evP6fSuVmOI0LzQexDVdxNzccGiHwo5R+FegnFSCVdAbeWGK2AOfbA3K//
         3aR6qgBlzozzeOWgaZCmI55wtaCoQF1Ql6z//pVfi9ub5N4RISvwd7EkRMXbEvNvwB7D
         45YercVK3kb7X5QEjl62rOAAeI3AbzhZOwhyEXGYzibyCvQoRcQt8oXpfI3baAIdS2n6
         XYpZ+xeAhC6Q55eyOlV79WYktAn/TdvmENl2sW07UzZqsphqmqMZ+Gm0CQ6TGJipCV0P
         0mX6zfbjLwzGIzBL+gT+y0yYRil9wlU3LjyZM+hwlY4sIV64K+Jl+RrqkQezUSt92mJc
         DsXw==
X-Google-Smtp-Source: APXvYqzCPtblkSBKWUEyR9rRRlxzrEv6PwwKFyPnyYkxKn57Os1ZcK9NiV4YklZkkhAOwJVb3Kmykw==
X-Received: by 2002:ac8:2fda:: with SMTP id m26mr16733925qta.312.1552085224207;
        Fri, 08 Mar 2019 14:47:04 -0800 (PST)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s49sm5429876qtk.7.2019.03.08.14.47.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 14:47:03 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/compaction: fix an undefined behaviour
Date: Fri,  8 Mar 2019 17:46:50 -0500
Message-Id: <20190308224650.68955-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In a low-memory situation, cc->fast_search_fail can keep increasing as
it is unable to find an available page to isolate in
fast_isolate_freepages(). As the result, it could trigger an error
below, so just compare with the maximum bits can be shifted first.

UBSAN: Undefined behaviour in mm/compaction.c:1160:30
shift exponent 64 is too large for 64-bit type 'unsigned long'
CPU: 131 PID: 1308 Comm: kcompactd1 Kdump: loaded Tainted: G
W    L    5.0.0+ #17
Call trace:
 dump_backtrace+0x0/0x450
 show_stack+0x20/0x2c
 dump_stack+0xc8/0x14c
 __ubsan_handle_shift_out_of_bounds+0x7e8/0x8c4
 compaction_alloc+0x2344/0x2484
 unmap_and_move+0xdc/0x1dbc
 migrate_pages+0x274/0x1310
 compact_zone+0x26ec/0x43bc
 kcompactd+0x15b8/0x1a24
 kthread+0x374/0x390
 ret_from_fork+0x10/0x18

Fixes: 70b44595eafe ("mm, compaction: use free lists to quickly locate a migration source")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/compaction.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index f171a83707ce..6aebf1eb8d98 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1157,7 +1157,9 @@ static bool suitable_migration_target(struct compact_control *cc,
 static inline unsigned int
 freelist_scan_limit(struct compact_control *cc)
 {
-	return (COMPACT_CLUSTER_MAX >> cc->fast_search_fail) + 1;
+	return (COMPACT_CLUSTER_MAX >>
+		min((unsigned short)(BITS_PER_LONG - 1), cc->fast_search_fail))
+		+ 1;
 }
 
 /*
-- 
2.17.2 (Apple Git-113)

