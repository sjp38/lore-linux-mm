Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E867C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 08:35:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04A3721872
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 08:35:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04A3721872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axis.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F6AA6B0277; Fri, 15 Mar 2019 04:35:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87B7F6B0278; Fri, 15 Mar 2019 04:35:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F7D56B0279; Fri, 15 Mar 2019 04:35:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0138A6B0277
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 04:35:11 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id v67so132969lje.15
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 01:35:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id;
        bh=4GNfr92Fc0Vm6PPy25WRg54NPSt/514JDTx+iXMkgGM=;
        b=HwmMUhQIgUINscNnS4VZtXnEnmNgB1Q2NpIA1XWKH2jgsmuGeA7bdLNLGiRWOwobYL
         +/3Ljhd6AzgJnjoNbcQj0zv6Lqo7SPXnE+VK+RljVx5/vHytHRrSj/xHUhqQEssrPFWT
         Gj/FN31o8Zhva3L4i8sm8VXp17aNxbHbRAI/FrIGj/T7RatFhbwqzbGBKpEgTtn7Jvqe
         /ITaHgYzAwvMBEc8lmzeB0/+bF0475/LGSCor7+xFX7JdHgZcoajHGgTCJpGNZ4qCWEK
         NwE44hj7A8VZPGL4K3aqY7kkgO3Zag024UB3QaCDF0njh/voGd10LmumGDYmliQyyUXj
         4Afw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
X-Gm-Message-State: APjAAAUFB5zamDKCb6sC9gEzqNee6PhDVDyVeGfGQnRB1iM30e5DQ7Nc
	ivGRw40AIbeXDI1eY4g2Fr5sKP8+a3kz62hBHNHZTRuvLNjepRx8DVNMgBqruTYIiyO6MEC1BHy
	u1Ve6ardpydy0Je/HtLWD3ASC5CBEMk21gDzCFlICqpYbZU7CI7AvPcWa857hZilCvw==
X-Received: by 2002:a2e:801:: with SMTP id 1mr1497000lji.61.1552638911191;
        Fri, 15 Mar 2019 01:35:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2fcXoez00JsBVIP+j9t+K3j3bqXCwk5KEf+u6KI/w9RufeV6Im+tU1GpDAmS/SbYxH9L4
X-Received: by 2002:a2e:801:: with SMTP id 1mr1496947lji.61.1552638910024;
        Fri, 15 Mar 2019 01:35:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552638910; cv=none;
        d=google.com; s=arc-20160816;
        b=g9k8AkEyjNUUJdqGKVr2+75an9EMUXG7GPNYcntIOzSRCaObY0xckizBposDdFExh6
         Wh/8Lua/7KiIas5RS141gDYGkXAk8xvKS5KIqsfRer1Ga21OEIBBBuSLJM4x6CH0VMO6
         9D6SRk0JLibDLEK3rSWePteudAZxBSeI9PBLjg3FZzEJQuPo4NOpnpuxC/TIG87Z8QA5
         Yv0VxCAXM/NJZZ2duGaftlxKuuLpwYya+OBM2RG0GD4mwNayu/PtHXIXLWE4S/VNa4h5
         TcVE+/rHJtphYtyVKCzbe1sOeuguOakfQhiwhJia3plUqacDaPpkJgLCo4/qRftFP3cm
         F6fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:to:from;
        bh=4GNfr92Fc0Vm6PPy25WRg54NPSt/514JDTx+iXMkgGM=;
        b=IbJOTceJGEBA0VMo6jymHNTOwFdJ8daDH8jN7sZMLbJezhQ1usDXFoPBXbYxvt+Axt
         3bGvOCAaaDbeccBq/wBDjujU8I0kLQP6481ceEQvdfFB3vhnk6JPZS9Bazgr8Y4GVPER
         raJVi7JM8qL5fI6rr79fwy8ecMCAGECQNIvCuNDCPXbG4VZr3Wxo4AbQzuOTGFcV3URT
         QpqIrLpgJsXy+3XqE2Q8LSvOekYnrQXHijEdIu06fijQAaWp2iv+66dv5Bv5fsMBNE08
         33BDs0pq0i1rfsTG/N5K0rzwk3DVOnLjJb6FDLb9TCYMHRCPOoAIA0Q3aWXpBGgfgzk9
         PAzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id u21si1077516ljk.136.2019.03.15.01.35.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 01:35:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) client-ip=195.60.68.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from localhost (localhost [127.0.0.1])
	by bastet.se.axis.com (Postfix) with ESMTP id 66062184E1;
	Fri, 15 Mar 2019 09:35:09 +0100 (CET)
X-Axis-User: NO
X-Axis-NonUser: YES
X-Virus-Scanned: Debian amavisd-new at bastet.se.axis.com
Received: from bastet.se.axis.com ([IPv6:::ffff:127.0.0.1])
	by localhost (bastet.se.axis.com [::ffff:127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id wPRZ9UvIVLX0; Fri, 15 Mar 2019 09:35:02 +0100 (CET)
Received: from boulder03.se.axis.com (boulder03.se.axis.com [10.0.8.17])
	by bastet.se.axis.com (Postfix) with ESMTPS id 82E47184E2;
	Fri, 15 Mar 2019 09:35:02 +0100 (CET)
Received: from boulder03.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4EA9A1E0BA;
	Fri, 15 Mar 2019 09:35:02 +0100 (CET)
Received: from boulder03.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 41AA81E0B7;
	Fri, 15 Mar 2019 09:35:02 +0100 (CET)
Received: from thoth.se.axis.com (unknown [10.0.2.173])
	by boulder03.se.axis.com (Postfix) with ESMTP;
	Fri, 15 Mar 2019 09:35:02 +0100 (CET)
Received: from pc32929-1845.se.axis.com (pc32929-1845.se.axis.com [10.88.129.17])
	by thoth.se.axis.com (Postfix) with ESMTP id 32DCB311F;
	Fri, 15 Mar 2019 09:35:02 +0100 (CET)
Received: by pc32929-1845.se.axis.com (Postfix, from userid 20456)
	id 2C359409C8; Fri, 15 Mar 2019 09:35:02 +0100 (CET)
From: Lars Persson <lars.persson@axis.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2] mm: migrate: add missing flush_dcache_page for non-mapped page migrate
Date: Fri, 15 Mar 2019 09:35:02 +0100
Message-Id: <20190315083502.11849-1-larper@axis.com>
X-Mailer: git-send-email 2.11.0
X-TM-AS-GCONF: 00
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Our MIPS 1004Kc SoCs were seeing random userspace crashes with SIGILL
and SIGSEGV that could not be traced back to a userspace code
bug. They had all the magic signs of an I/D cache coherency issue.

Now recently we noticed that the /proc/sys/vm/compact_memory interface
was quite efficient at provoking this class of userspace crashes.

Studying the code in mm/migrate.c there is a distinction made between
migrating a page that is mapped at the instant of migration and one
that is not mapped. Our problem turned out to be the non-mapped pages.

For the non-mapped page the code performs a copy of the page content
and all relevant meta-data of the page without doing the required
D-cache maintenance. This leaves dirty data in the D-cache of the CPU
and on the 1004K cores this data is not visible to the I-cache. A
subsequent page-fault that triggers a mapping of the page will happily
serve the process with potentially stale code.

What about ARM then, this bug should have seen greater exposure? Well
ARM became immune to this flaw back in 2010, see commit c01778001a4f
("ARM: 6379/1: Assume new page cache pages have dirty D-cache").

My proposed fix moves the D-cache maintenance inside move_to_new_page
to make it common for both cases.

Cc: stable@vger.kernel.org
Fixes: 97ee0524614 ("flush cache before installing new page at migraton")
Reviewed-by: Paul Burton <paul.burton@mips.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Lars Persson <larper@axis.com>
---
v2: Added a Fixes footer and CC for stable. No functional change.
---
 mm/migrate.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index ac6f4939bb59..663a5449367a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -248,10 +248,8 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 				pte = swp_entry_to_pte(entry);
 			} else if (is_device_public_page(new)) {
 				pte = pte_mkdevmap(pte);
-				flush_dcache_page(new);
 			}
-		} else
-			flush_dcache_page(new);
+		}
 
 #ifdef CONFIG_HUGETLB_PAGE
 		if (PageHuge(new)) {
@@ -995,6 +993,13 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		 */
 		if (!PageMappingFlags(page))
 			page->mapping = NULL;
+
+		if (unlikely(is_zone_device_page(newpage))) {
+			if (is_device_public_page(newpage))
+				flush_dcache_page(newpage);
+		} else
+			flush_dcache_page(newpage);
+
 	}
 out:
 	return rc;
-- 
2.11.0

