Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92756C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:56:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F32720833
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:56:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F32720833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E22E8E0006; Mon, 17 Jun 2019 20:56:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 092638E0005; Mon, 17 Jun 2019 20:56:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEA558E0006; Mon, 17 Jun 2019 20:56:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6D7A8E0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:56:24 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h27so1556577pfq.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:56:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=Z5y0VzIBQjnxlCy0xjt7NVE/Wj7O10oFQR/sFQh3qNI=;
        b=ihme+/z0DAlenDBzHFAwDxl3jcCE4ycd61V1xSxytT2VOUjUcJRo6uY7ywwFcQF9LK
         IpQuHrDnk7SJeQeSg2hDIPLeD2gcKsDXUbiUqa/WZFHleeAm1WU7HM3tJNd0MssXj28z
         k9UTowbR5aODbPKIobyvMk0JZp4lf0LgDjwxfbE6qKyh8Vqk6dKJBr3y9DtGcl2x7Wq5
         5PsPsEUt6kqGBWZiyuONQw8/0nPmvuuMqcQhtdhJdAWlzyxGPZdL7Z2u1Mesn02uUsZu
         XcRLwY2zYC+RlVAOMgKet1aiwvSsmZC6EN2G0Jf38nKro9dAmnM0k9ejsk9vyuT65Iqc
         jCeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWvsfYcj5dubapz+uHgVkDRHt6aV/RRtBm2Ou7bMnHmjpwBvGnk
	D79LRFljkMaGhx8hpbCmC2bCvX/AcV7SxZbjzXXESd3UUqjduI1645XuMZKlcRDidnarWlgDMOb
	Ha67zgzgiWJOUV7a82IZLinhFs+JQRbNLyX9bg38LB0AQq63BH5kA1OeEEGS77TdHCQ==
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr110033356plb.334.1560819384427;
        Mon, 17 Jun 2019 17:56:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBta01tyOXbym6RPZAzXpK/19OgJsJDoRzG6f4KHJ4Q0LEcSjrl6nypagPMPxq0YH0wtnP
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr110033316plb.334.1560819383788;
        Mon, 17 Jun 2019 17:56:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560819383; cv=none;
        d=google.com; s=arc-20160816;
        b=pIrjsIE4WvCLvDwB2OLSbm1BtWHtAWSVGu9MCD0m2zG4JQE9U16if1CcTiR3oGoGHM
         0NnFNn2+lK7ihmvFholPVRqlVySHRuhPtnqaJ/s0oqIXTurhsn+kQby0YLA1SRmKBpR6
         jl6p9wh85B1536lcrGhaRLNuM9U1mhTjo3+8aD93a4PcQQE6apSwg8WWzJVUXzO6LEwC
         0gIDqIihU2972RR+84Vk7X43qYtv4Unt1eEc7mWZuaXqZqWkSzcBYIXAWcLyLZCv5Mb8
         Vm89neV43waff5FU0eRjq7yA/jIVZLJ6aKv/cgu3IZEv7sFXBLbyPl8L5KW5bPl+S37b
         me9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=Z5y0VzIBQjnxlCy0xjt7NVE/Wj7O10oFQR/sFQh3qNI=;
        b=EhVDgNUkNIlnZNEmZKB7mtsCleCmacLd2EIkzRF559MezoTCqzuabmJ8JvSrexJrKv
         1U5oiFYeKH3R9jkk1FbYfbLrZCORUQzZWIasK/JFEVwiQJHrxnNPekCKuK3gu2r4SdgY
         Xd/8H43jNaIbJKp3Q4gmE9/Gt4b0HOpzXzGujtqjDRtUyhy6XuXY1F6QVSztgCpcHCEM
         gycP6QGpIoGZ4o54RZJXnPq+RWddA3fh2nZy10lI11dbfo7ZoZPIVfi/eue3QfruRbzN
         eCcmVEt5VCCTlwB+4DAbQUrvIS3rQNZdAy6JkGl5yD2vMDoTKhgh1DBv/SnJ7C5w4fW+
         q+LQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id h11si11499660pgq.170.2019.06.17.17.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 17:56:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 17:56:23 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga001.fm.intel.com with ESMTP; 17 Jun 2019 17:56:22 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	osalvador@suse.de,
	david@redhat.com,
	anshuman.khandual@arm.com,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH v2] mm/sparse: set section nid for hot-add memory
Date: Tue, 18 Jun 2019 08:55:37 +0800
Message-Id: <20190618005537.18878-1-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
section_to_node_table[]. While for hot-add memory, this is missed.
Without this information, page_to_nid() may not give the right node id.

BTW, current online_pages works because it leverages nid in memory_block.
But the granularity of node id should be mem_section wide.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

---
v2:
  * specify the case NODE_NOT_IN_PAGE_FLAGS is effected.
  * list one of the victim page_to_nid()

---
 mm/sparse.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index 4012d7f50010..48fa16038cf5 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -733,6 +733,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	 */
 	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
 
+	set_section_nid(section_nr, nid);
 	section_mark_present(ms);
 	sparse_init_one_section(ms, section_nr, memmap, usemap);
 
-- 
2.19.1

