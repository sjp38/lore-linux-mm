Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24681C10F0D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:50:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDCC7218D4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:50:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="jo1am6NX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDCC7218D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A96A36B0003; Wed, 20 Mar 2019 16:50:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1EA96B0006; Wed, 20 Mar 2019 16:50:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E5736B0007; Wed, 20 Mar 2019 16:50:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 61F016B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 16:50:02 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n64so22231649qkb.0
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:50:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=vKMs+vGKtn6uWWX3EIKMHp5IS2yH54+J/gVXjWcLaZM=;
        b=QAmeMd7eaDPHulgdbSAr1WWKK37/rnudSht//DOt4UVZsK89f+mOFCq3dZfwz/abn6
         Pp4/IhZd+JK6QFlfdgbGwZp2ZqTsfUG/QHYnujmQvG0MCMWn0s1hEuKfMQMnEAD6XJVx
         tTlBCPL2Ba+mjqJj23GzwnuOGMt6F5pc4gYY9KN7B8mpOfEe/i7ADW54ukTIVsiI55TW
         7uYS3oiO+COchXgqLZ2q3t2Z0R4ICydCzJVufHnPtEUXdW406efTnXAtBvmzZ9vF+d82
         wdCP2BYfMcTELjeIDDUOj+dOg1tmugfEX9oRZNvocMN7kF4u7j3Xjskhevs9I2Bk4oak
         bSBg==
X-Gm-Message-State: APjAAAXAKwpwwdcQ9N5OwmtRtmd5xa0xKthFQBw/u6EDUTre8ih4Rwdk
	c1IonIBz2VSlua55eAwwOJfpKfRRMeoFyEG13tt2ucOVG6hVUv9Dg1CTo1vf7riuWIIkeu3XfDf
	Cp3S0I1wRJoNpJiEQjRxI/CRJT3C15MtJgsG+TxqLSYuacHo9YmTcTm+uTaquhJLHBg==
X-Received: by 2002:ad4:430c:: with SMTP id c12mr27845qvs.109.1553115002183;
        Wed, 20 Mar 2019 13:50:02 -0700 (PDT)
X-Received: by 2002:ad4:430c:: with SMTP id c12mr27786qvs.109.1553115001136;
        Wed, 20 Mar 2019 13:50:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553115001; cv=none;
        d=google.com; s=arc-20160816;
        b=WiLOUE/OsLIeOd3xSHRVBzaEueMmGyCEIVqiczyiEvJhOEtAjLY8kxVKqzv5O4IiD7
         blldndgHeBiRDqmhNRSrWARyQXgV0GdYLIz8vceiIUBuiGoh6KZh0ezUk33gEmKl5jDE
         b5/VeQvrTscG43tD3a/SVgaACpshMO7U0XaY88JnBdgcONkYPe54oLGWjRHQhYvdCQJZ
         BJ4AzSUPP4soAsivHiF5a+bSP+YLmouRjNXJPXEqHo0tCp4cTETY9xUz8/Q+cNq9Uu2r
         jXELbdsHBt1PEMUEYIqFgrw6drxxsC0rWUdHkavw7rY9DL8K4RrAEwIXFDdQMDRlnfdj
         XokA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=vKMs+vGKtn6uWWX3EIKMHp5IS2yH54+J/gVXjWcLaZM=;
        b=K3l51a57wqXaBGM4NhgT3MXB/SCE7r1lGZmSEYLD9N5AqoRE4FKEqWxhBtwWwS24Us
         Ee2q6S43o7SuX7pUm2ORd9urs+CeeqjvwD+sEcIJTNB0N0i7q3CHD5aHpgXOtLlj6/q8
         jx4YUFPofNzJwxtNo+3GsfTdZ+AdNr/RPaIDU+IudLq8VclyoYSfRHbILrNsAkTA75r/
         /IVxH6iB9UeaIQLBfIBJn1zNSHfXe/uF0uKIvGZ6fczGmLuZEmdq7O8bNPPk5PDtBWgd
         uzlhpKlL3dcr+36lzmQnSR1Gry8pEE291rEcLyHhsG2dY4UNiBXeydZuk13uzV8ApjUk
         lQBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=jo1am6NX;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x16sor2319367qkh.57.2019.03.20.13.50.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 13:50:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=jo1am6NX;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=vKMs+vGKtn6uWWX3EIKMHp5IS2yH54+J/gVXjWcLaZM=;
        b=jo1am6NXmh62DCNOoIRIZQFeCEpQzG9AM3T2gRtKC3HxT/sWZoL3LQhuR6Zxsf2NGW
         f8NfSPfp/AEDG8Mpv8MqvZC/wU6zQgOEXOFKOfzKNQHnTj1BPYfOZC4xiYti+1uKt9Ut
         9O7/4rDm7enXSCwk5a9zr4/2Z4/xgIoQeXOMML6YOZbGqKpnu/sKkjA9KaFoKRQrXNnk
         fEGM5uiB7kxiUla3AEJDSWTOCJT0a8T9hsu1W2+y8V/qigpZucLtNm+3Dhz0nzdJcesk
         Kpouss9sb/XjFOANjQe4G7OWug96I4zPu5Ut4NaNw0XGHlKxPluK4fDr57GbgNXRCtCS
         NOFg==
X-Google-Smtp-Source: APXvYqyK8pMu34MHAiJ9lTIZlVL32AxB4ryVVjnGoBBMBKpGFq/oUuvraCi8U9UCRJOcsrOFw80xaA==
X-Received: by 2002:ae9:ec19:: with SMTP id h25mr8585387qkg.122.1553115000939;
        Wed, 20 Mar 2019 13:50:00 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id g65sm1709700qkf.52.2019.03.20.13.50.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 13:50:00 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	osalvador@suse.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>,
	stable@vger.kernel.org
Subject: [RESEND PATCH] mm: fix a wrong flag in set_migratetype_isolate()
Date: Wed, 20 Mar 2019 16:49:41 -0400
Message-Id: <20190320204941.53731-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Due to has_unmovable_pages() takes an incorrect irqsave flag instead of
the isolation flag in set_migratetype_isolate(), it causes issues with
HWPOSION and error reporting where dump_page() is not called when there
is an unmoveable page.

Fixes: d381c54760dc ("mm: only report isolation failures when offlining memory")
Cc: stable@vger.kernel.org # 5.0.x
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/page_isolation.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index bf4159d771c7..019280712e1b 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -59,7 +59,8 @@ static int set_migratetype_isolate(struct page *page, int migratetype, int isol_
 	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
 	 * We just check MOVABLE pages.
 	 */
-	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype, flags))
+	if (!has_unmovable_pages(zone, page, arg.pages_found, migratetype,
+				 isol_flags))
 		ret = 0;
 
 	/*
-- 
2.17.2 (Apple Git-113)

