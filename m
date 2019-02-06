Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB87FC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 03:47:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30DC4218A1
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 03:47:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="jDCmckdi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30DC4218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86F188E00A8; Tue,  5 Feb 2019 22:47:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81D068E001C; Tue,  5 Feb 2019 22:47:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70C1A8E00A8; Tue,  5 Feb 2019 22:47:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42F038E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 22:47:53 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id y8so1154205qto.19
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 19:47:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=hn7+N9666cc4lS16XW3pckdR4GfHKvecl40QV/S0Gr0=;
        b=f6MQ/D9HI7Qd9V7pCVlTf8uy7WjH6e1u4DiuMgk+TDx/3sDli692nHvyxVf+5ZwfAo
         62I9ZlwLLFt2jmE4OdifTx0Qyw3jcFtp+fYPJT4n7+YwXhvommYA3fz/l9u/r8r2DbqY
         5wWq/DN0URkxru7bHE1Tx1Iqk/6GwgC3fAPEv6l0B/ISbeqQ13Z6E0ReimCUIHdcbpLK
         Ra9s0zGbN16GR3vgQ3V4kLPFGpdOUcowricgFtugWhtgs2MsuVU7wRANxL5eO7IQ96gm
         QX/N3JBmuHJFd+uClTuKrXQEVlh/L7WF9FuIR+gBMQJ7VfPn6ohnDdD84tt672XHjhwg
         DTcQ==
X-Gm-Message-State: AHQUAuZwr3oAop+PZdFxsvrHdT0mLruPdRP3m+gNxo9oEGr6awrBR6Ad
	0gpSIMsfiRYgByYt5aCt/NQ/IQh23axhlWoNg7A/twoGgdvsMa+Za5HYExHi+JGjIuGfQEX9T52
	TKnKcGRLcZcoaCFr8BJ7/beSjfNBduIUKtVTxhPiPVJtXVnSV3oc+bEFz1GPDMWAGxsPs0soeRc
	0fL0UBdt6XPEc8iDcIa1WlHxZYgmbGqT4aPxF7f4Gz1c+H4Jm73l0le7ZScM/IjLX3cKQSTZR5m
	LmpG3mQyWXhAJyMZe9edS9Poawu7L7CfLaleTtQ5G0ySDkVteQiqZEPvrjkMzu0bboQerS6d3Ks
	W7MUYrLivspRLwL5kuB3PTaxsUiqThj+CEGzFBpXy4vq06+h9hjbkQydyWq1vmEb0rPUvVOfSiL
	m
X-Received: by 2002:a37:b842:: with SMTP id i63mr6118865qkf.69.1549424872957;
        Tue, 05 Feb 2019 19:47:52 -0800 (PST)
X-Received: by 2002:a37:b842:: with SMTP id i63mr6118842qkf.69.1549424872190;
        Tue, 05 Feb 2019 19:47:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549424872; cv=none;
        d=google.com; s=arc-20160816;
        b=oYlWXd2OBZlvI7ZJen+l+uIjgdH8nwb1cLYl7ZtIIfdzS2nimKzjqEfMDlwc58j4AO
         ocFDOZXjCS36D7VPO7LnlJYH+TJ7NOkIfImtwxCzdyfWESPwLukxAR3sdaNChhvKjXY6
         dFkuSmw8RybpWWKCn+QfBgyZTEGsK9YRIAbJ1ZhLsybO94eljCOxBrfnX+wFcjo5QxsH
         DnyMtK33stH19TMaJztFWaOL00wSsFSdEA18elPmDex8cF0Sww1Ciq4bIiCOAf/cWktk
         ulWCN2fmJSeiAYBzxrclhI2w7iibxmNBVYT8EV2JBTjIf6TfFeZ8reCQ8MIbXFAgJU3N
         /nfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=hn7+N9666cc4lS16XW3pckdR4GfHKvecl40QV/S0Gr0=;
        b=Yr2QD+P6BmZ8cvH7N8/+qvr1vwwfk2wB6TfreZaF5Kd8QJfbpXd/rzdBvxkAjnolCm
         EiFfMu+tfh4Cd919MP6UIicPPW6/rZvTqcbJqZqxlI79UGmXcfmZepNDGu2uz/fk4nIY
         4avtJm7CdxTy1mSqSN5snWET1rQ83OGYXCuKSkSO4Di+Rlae3PLUjlMDnlKhDMzoGFQx
         4w7SrKn2UqNcD68ydJN+wp7rD2IWK1w7TFtlk5+aUqCD0SS1fPgvBBYnCU8aKABGTjDD
         8nPcDBFO2wbPGwP/SvcxzcKSfs2Ckkpov+77kT/oM07OEJ5wEh7UObGus5Z6tlo0zzJq
         Iu3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=jDCmckdi;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z190sor5451832qkz.19.2019.02.05.19.47.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 19:47:52 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=jDCmckdi;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=hn7+N9666cc4lS16XW3pckdR4GfHKvecl40QV/S0Gr0=;
        b=jDCmckdiuhtXoybFpuM3uFm+lgtvEbsTXUi7VxzhH4gerkvuUkAcEMj20+hcJM0I4L
         +Tm6nJTIF2LnT7Jv0bmR7CGF3BdDPlhMVo91k0OEdihfT75hjweOW8igV0UcvETTe3sM
         xc2qMWcUMhQS1cQDjq1Qx+9M2O5r4iRDTk2EslJwzFxhelOZxJmHijj8d/bZwYy9/fC+
         KGp2quNBAnmr0a8whQPJHIyGFGPEMlbZuagS6UsiFgOMzj8PNl5Pe55e++lvXL9KITz2
         XENp3372I1aNr6brGGEd3nFSz5uE4MZ/HR5C7v1qvqtWo/eRwFWHhWwXqq+6pRR9IG0g
         wXQw==
X-Google-Smtp-Source: AHgI3IY5rnr5djl+RIVWHTf46zBv2SkMoEUn9XCb9tFsbn6dnXUyHHUJdKQTmk02zutMbpDTLc1DKw==
X-Received: by 2002:a37:2d02:: with SMTP id t2mr5897714qkh.82.1549424871806;
        Tue, 05 Feb 2019 19:47:51 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id u27sm7392987qte.48.2019.02.05.19.47.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 19:47:51 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/compaction: no stuck in __reset_isolation_pfn()
Date: Tue,  5 Feb 2019 22:47:32 -0500
Message-Id: <20190206034732.75687-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit c68d77911c23 ("mm, compaction: be selective about what
pageblocks to clear skip hints") introduced an infinite loop if a pfn is
invalid, it will loop again without increasing page counters. It can be
reproduced by running LTP tests on an arm64 server.

 # oom01 (swapping)
 # hugemmap01
tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
mem.c:814: INFO: set nr_hugepages to 128
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Test timeouted, sending SIGKILL!
Cannot kill test processes!
Congratulation, likely test hit a kernel bug.

Also, triggers soft lockups.

[  456.232228] watchdog: BUG: soft lockup - CPU#122 stuck for 22s! [kswapd0:1375]
[  456.273354] pstate: 80400009 (Nzcv daif +PAN -UAO)
[  456.278143] pc : pfn_valid+0x54/0xdc
[  456.281713] lr : __reset_isolation_pfn+0x3a8/0x584
[  456.369358] Call trace:
[  456.371798]  pfn_valid+0x54/0xdc
[  456.375019]  __reset_isolation_pfn+0x3a8/0x584
[  456.379455]  __reset_isolation_suitable+0x1bc/0x280
[  456.384325]  reset_isolation_suitable+0xb8/0xe0
[  456.388847]  kswapd+0xd08/0x1048
[  456.392067]  kthread+0x2f4/0x30c
[  456.395289]  ret_from_fork+0x10/0x18

Fixes: c68d77911c23 ("mm, compaction: be selective about what pageblocks to clear skip hints")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/compaction.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 03804ab412f3..1cc871da3fda 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -282,17 +282,16 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 	end_page = pfn_to_page(pfn);
 
 	do {
-		if (!pfn_valid_within(pfn))
-			continue;
-
-		if (check_source && PageLRU(page)) {
-			clear_pageblock_skip(page);
-			return true;
-		}
+		if (pfn_valid_within(pfn)) {
+			if (check_source && PageLRU(page)) {
+				clear_pageblock_skip(page);
+				return true;
+			}
 
-		if (check_target && PageBuddy(page)) {
-			clear_pageblock_skip(page);
-			return true;
+			if (check_target && PageBuddy(page)) {
+				clear_pageblock_skip(page);
+				return true;
+			}
 		}
 
 		page += (1 << PAGE_ALLOC_COSTLY_ORDER);
-- 
2.17.2 (Apple Git-113)

