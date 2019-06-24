Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E3FEC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:21:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E992208CA
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:21:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BZ00Q4nD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E992208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0E5B6B0003; Mon, 24 Jun 2019 00:21:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBE2D8E0002; Mon, 24 Jun 2019 00:21:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AACCB8E0001; Mon, 24 Jun 2019 00:21:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7064A6B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 00:21:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c17so8733787pfb.21
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 21:21:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=/Vi0SmBJrr/dhcFyf+7ZAHJAQmuruaehm6iOPvzhh0A=;
        b=TXAb4LbqNWBxD1iJ0TgnDu8EJbsrwyCn3aoMytv/2iLxcrIahAeCgsLQh/gO/hoH6F
         byrS7jef1cjFcJJE4LAuv7wFpGMgoyrYTyfW6rrO0el6zDzOGvFKfMxEq8ahqUu+lOss
         rXstao7pG5DAQFnU1f6wf4YQmtWopESbFYm7nAr3lUqAzBoeOBwb8GTiQhrCrN1PQBhJ
         HCmQxJp47YIkfINNO1mXD7R8W1H0VJ6Cgjz22yaBwL4NPZ+4jGWLVhdW2ApY8/Qw8lpb
         RPTDpCjAbmKfuslXwRQjXArnFeaTa0oNYo0ZcRCMglUhkXUBE3navSoxtXNBB8t/Fsuy
         2iCg==
X-Gm-Message-State: APjAAAWULuIX/BHTYgtc4U2oW/f01GUFxU5rLMVJ5CMREBsL56EnOBRg
	s2SIgZNgmCm7JzOzogD1IDHmYC39IGNmTEyDwXpbEE/3+6aJx2u0KU0F4OLXYSmn5bA1T4eMARu
	NWaVIxWL6t1f7FaSlx5TCt4AZZr3NCDGbl04dd3u3AHqUep4tVkpEGVJyZEtwv0VsgA==
X-Received: by 2002:a17:902:b944:: with SMTP id h4mr21042859pls.179.1561350085063;
        Sun, 23 Jun 2019 21:21:25 -0700 (PDT)
X-Received: by 2002:a17:902:b944:: with SMTP id h4mr21042826pls.179.1561350084358;
        Sun, 23 Jun 2019 21:21:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561350084; cv=none;
        d=google.com; s=arc-20160816;
        b=OYwIp1DM33WIjfh0wePzc1n87RehXDqsN8Ml7TiuxGzoGtv9c/U1uQDaCDmLsWmrhk
         DVYHH7AJIkOYk3pr6s/3M/vvD0rHxFAxWOiqOcNO/fpv4zsEQeNB3IIqTiq7Vydy199w
         X8/udCPSJ1jcXXshAr4MqIfdO9X3pD2zER77dHZ5SQUTTw2YKsa6rA6C+1Hn0YvnOLb+
         Cp7PUntHohOy18usoL07vGlIsBy7uie4GgdkvpEbyEbUAkdeI8QdqR8tI/cCHnuVOulP
         9uXnX3ZIt6+q4hr+TNLl5+35FhLzaUG5Lp8x3TVTTKpchgezhP2CzvYtuJnxXnk6QPLC
         jmuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=/Vi0SmBJrr/dhcFyf+7ZAHJAQmuruaehm6iOPvzhh0A=;
        b=jhLW1QvpJFtqju9e8jx//Ex+aQO90uSiuWkP6O1+cbMePi9RnJk+BP5cIXFSOxstcE
         moVulimvH4ffdm3UwfnMxVFTvokFUT1mreYCWBDLQXDsZupnFvpNXSI4NADO9+RwSvoa
         wzENwkC+cPtyuRo4hgjpM/JeTcwyzD2Rt42Re1rtvzlcAncc08mOmeROAGEcMr//nwbt
         0HFhH9dKTJXslq3Wfj6b6DvuBHqJgslnLlv5J1/19Rxyl6mFhtTyHjUYfr3axS0pXJK4
         qoIPNlZcaJo5mqBIb+VmU+aO0IVBz9AhS2PX6I3iM1FXlWGxDN1di6m7J51Fd/RiFLOo
         Eu0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BZ00Q4nD;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 19sor5452256pgo.69.2019.06.23.21.21.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Jun 2019 21:21:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BZ00Q4nD;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=/Vi0SmBJrr/dhcFyf+7ZAHJAQmuruaehm6iOPvzhh0A=;
        b=BZ00Q4nDJWbfG8+WDCxOo9DiaRK/yg6Yn/n2eoMxTA6AukHxBQvZ4+mZP16keQzAgb
         aCsv4jtOVZi0/bgxePIWQmSeq2A2N7zo1ty8lDc6eAOwMd2YYfJY3C/wFotgvEVEmnyB
         8/DgGIGsxZ8kk2ISnWjURBlXhlgWPpfWFRwr5CBk+ma0PfNx6V4v6/c1HQwctUNhXgHF
         YUmoVtW4aH+sw0cJQPaeBP2dq3g1jGkUWlPZRyyZ0z4hMy50mRrR/f/wIEnPmFifV64o
         uq+9VNBHCcsiEIIERe4TC4Kq1oC++FL/XWelwlAX+eliU/V0nipXL02bQBn0VfgV31u3
         5nZw==
X-Google-Smtp-Source: APXvYqzk+mEWys6LQTcZ4E5e9NNeshfHFdIyEnJiuucAc3dGIR7ipjsKgsHr3zoJScBJt8PvZYLzhQ==
X-Received: by 2002:a63:8ac3:: with SMTP id y186mr24564759pgd.198.1561350083906;
        Sun, 23 Jun 2019 21:21:23 -0700 (PDT)
Received: from mylaptop.nay.redhat.com ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id w14sm10047181pfn.47.2019.06.23.21.21.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 21:21:23 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm/hugetlb: allow gigantic page allocation to migrate away smaller huge page
Date: Mon, 24 Jun 2019 12:21:08 +0800
Message-Id: <1561350068-8966-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current pfn_range_valid_gigantic() rejects the pud huge page allocation
if there is a pmd huge page inside the candidate range.

But pud huge resource is more rare, which should align on 1GB on x86. It is
worth to allow migrating away pmd huge page to make room for a pud huge
page.

The same logic is applied to pgd and pud huge pages.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
---
 mm/hugetlb.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ac843d3..02d1978 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1081,7 +1081,11 @@ static bool pfn_range_valid_gigantic(struct zone *z,
 			unsigned long start_pfn, unsigned long nr_pages)
 {
 	unsigned long i, end_pfn = start_pfn + nr_pages;
-	struct page *page;
+	struct page *page = pfn_to_page(start_pfn);
+
+	if (PageHuge(page))
+		if (compound_order(compound_head(page)) >= nr_pages)
+			return false;
 
 	for (i = start_pfn; i < end_pfn; i++) {
 		if (!pfn_valid(i))
@@ -1098,8 +1102,6 @@ static bool pfn_range_valid_gigantic(struct zone *z,
 		if (page_count(page) > 0)
 			return false;
 
-		if (PageHuge(page))
-			return false;
 	}
 
 	return true;
-- 
2.7.5

