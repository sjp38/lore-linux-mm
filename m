Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B552C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:38:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1B20218AC
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:38:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1B20218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DA958E0004; Fri,  1 Feb 2019 09:38:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6648A8E0001; Fri,  1 Feb 2019 09:38:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A5CA8E0004; Fri,  1 Feb 2019 09:38:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03E918E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 09:38:57 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so2907111edm.20
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 06:38:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MG7d8JlcgdEo/PiWAtqF1GY166mCr2hrF+TpvL/QC/o=;
        b=EamvY4pMwrFp8KmVWx/uCH1jaQ2EoFF/WdT3stfFszFBC9ua0J5i1vVzmz5P5a5Id+
         lxsA3YAOUcn3GvKbqeyhdXbGEUhEfrCapWqG4CIGwKPSXW9vQmi8Q2cKNPaC/nmutB3z
         JJ5J6z6b4f9zNKmpFDWvqa1GO5Chr0Iwhc8pds0oM+AR1a/VkiRsoRbQffYmsZXliEb3
         YF409KGkRaPfXw2c6zUgUEPUC8dB8UKiHb6AbNnseL/tDCPo+kyo7TzhvIpqD/N3nfKn
         dWiVxVHYwdA+VoumB+Pien2hRY/fZgYGAEza+66L1gbtBXAdPpq3mToeRlTQrspP6LCR
         P3QQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AJcUukdtbvDoBxKDedqsqOAXvPFv2wQQMHNsgfcw8nqlZ5vVKG/6VzUS
	mmhazXGpNTofRjrb5yOj19pOLgt7E+8fduISWTUyKinlTXfVDjB8yMtCvzcipY+3qdptsDkAnAn
	bAAkh1plyZlHLKhcjkyo1ZoDcxmPvV88ddbbd/uAEzl0xXd970tuad+f7/OR3NLHt2A==
X-Received: by 2002:a17:906:264a:: with SMTP id i10mr25836841ejc.11.1549031936509;
        Fri, 01 Feb 2019 06:38:56 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6H5NF+M/yNlLmHsVMWzbq6/kDgPzVdnW4g5fWbg613jWVxV9I80+YLeqsRzEh7GAdAgkV6
X-Received: by 2002:a17:906:264a:: with SMTP id i10mr25836784ejc.11.1549031935504;
        Fri, 01 Feb 2019 06:38:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549031935; cv=none;
        d=google.com; s=arc-20160816;
        b=EfBPE6OIfNoepLU7tixvzMZac2ZgZehcl/IX3mibXo94tLdmHt/4Luj3m6j3W15REo
         z5XsxGXJqeVwbFGiGiKuuhB8Va13B+8ttsLCkRemUUkJ2li3oIuDOljYps19fSFishcH
         vaXkCJmMiigrZO9vLvaPag3j0OGdH4bPtCLneOqUUVS6WWtaLmjdy5znTNIENkzkZ919
         OryI3d2J9neQohKaNqeX2Twcs80Xg8MrBQOMEpsQOJvzahuiUUggfWTXV1NoV3WOduYg
         jwY4ObowsIaqtpVocewYd05ZsVmrxvjT8S+Yb3EBH+hOLCOAZ+K+5L0OlfBLN/SVZnaE
         Fk2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MG7d8JlcgdEo/PiWAtqF1GY166mCr2hrF+TpvL/QC/o=;
        b=BRdwV8qubzl9XrGKYZW6AXQ476rG6KHD7One8Yb7ZduHhNQJgT9LSZIrRK55bVbKpf
         yV2S+rsLv3ZIY97AoRX1rhEQoHU43Sn/7Kwe0crgK3av6V96nZ7Q3aM4+Q2n/MKa9qWo
         PNA18MKUYzAq/zIVixqjCN7iul1lyFoRPxw9M2zf9YUfvk5rJLAmn6ZNA8e39seBHZu3
         hTnaxH2f3BfMrBj31vXxpgGKFbEZqV9XxKAqKSP9odxhjm2AqfXzUXnm+yTIrVNTgG6z
         oIeslLJvw4OI7U1NdatNRZcIHo95kbtlQoyeft3f82DR4p+qAyFxcXU8EoKKfJyIkOCy
         /Vgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id 5-v6si183154ejx.137.2019.02.01.06.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 06:38:55 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) client-ip=81.17.249.194;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 18CFEB8731
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 14:38:55 +0000 (GMT)
Received: (qmail 12935 invoked from network); 1 Feb 2019 14:38:55 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 1 Feb 2019 14:38:55 -0000
Date: Fri, 1 Feb 2019 14:38:53 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: [PATCH] mm, compaction: Capture a page under direct compaction -fix
Message-ID: <20190201143853.GH9565@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-23-mgorman@techsingularity.net>
 <2124d934-0678-6a4b-9991-7450b1e4e39a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2124d934-0678-6a4b-9991-7450b1e4e39a@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vlastimil pointed out that a check for isolation is redundant in
__free_one_page as compaction_capture checks for it.

This is a fix for the mmotm patch
mm-compaction-capture-a-page-under-direct-compaction.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d61174bb0333..b2eee9b71986 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -887,8 +887,7 @@ static inline void __free_one_page(struct page *page,
 continue_merging:
 	while (order < max_order - 1) {
 		if (compaction_capture(capc, page, order, migratetype)) {
-			if (likely(!is_migrate_isolate(migratetype)))
-				__mod_zone_freepage_state(zone, -(1 << order),
+			__mod_zone_freepage_state(zone, -(1 << order),
 								migratetype);
 			return;
 		}

