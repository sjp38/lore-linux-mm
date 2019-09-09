Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5934C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:49:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A42C0218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:49:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A42C0218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 484106B0008; Mon,  9 Sep 2019 07:49:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4312B6B000A; Mon,  9 Sep 2019 07:49:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 345A46B000C; Mon,  9 Sep 2019 07:49:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id 1071B6B0008
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:49:01 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B74A352D3
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:49:00 +0000 (UTC)
X-FDA: 75915210840.08.goose56_6bc22444b1d5b
X-HE-Tag: goose56_6bc22444b1d5b
X-Filterd-Recvd-Size: 3589
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:49:00 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5393DC045750;
	Mon,  9 Sep 2019 11:48:59 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-173.ams2.redhat.com [10.36.116.173])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 09F6F100195C;
	Mon,  9 Sep 2019 11:48:56 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	Souptick Joarder <jrdr.linux@gmail.com>,
	linux-hyperv@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.com>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v1 3/3] mm/memory_hotplug: Remove __online_page_free() and __online_page_increment_counters()
Date: Mon,  9 Sep 2019 13:48:30 +0200
Message-Id: <20190909114830.662-4-david@redhat.com>
In-Reply-To: <20190909114830.662-1-david@redhat.com>
References: <20190909114830.662-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 09 Sep 2019 11:48:59 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's drop the now unused functions.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Qian Cai <cai@lca.pw>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h |  3 ---
 mm/memory_hotplug.c            | 12 ------------
 2 files changed, 15 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
index 71a620eabb62..933f2bb3bdbb 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -106,9 +106,6 @@ extern void generic_online_page(struct page *page, un=
signed int order);
 extern int set_online_page_callback(online_page_callback_t callback);
 extern int restore_online_page_callback(online_page_callback_t callback)=
;
=20
-extern void __online_page_increment_counters(struct page *page);
-extern void __online_page_free(struct page *page);
-
 extern int try_online_node(int nid);
=20
 extern int arch_add_memory(int nid, u64 start, u64 size,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f32a5feaf7ff..16dd5b1498e8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -602,18 +602,6 @@ int restore_online_page_callback(online_page_callbac=
k_t callback)
 }
 EXPORT_SYMBOL_GPL(restore_online_page_callback);
=20
-void __online_page_increment_counters(struct page *page)
-{
-	adjust_managed_page_count(page, 1);
-}
-EXPORT_SYMBOL_GPL(__online_page_increment_counters);
-
-void __online_page_free(struct page *page)
-{
-	__free_reserved_page(page);
-}
-EXPORT_SYMBOL_GPL(__online_page_free);
-
 void generic_online_page(struct page *page, unsigned int order)
 {
 	kernel_map_pages(page, 1 << order, 1);
--=20
2.21.0


