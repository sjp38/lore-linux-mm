Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A729C49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:48:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE0DF218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:48:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE0DF218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C5736B0006; Mon,  9 Sep 2019 07:48:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 875586B0007; Mon,  9 Sep 2019 07:48:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78BC66B0008; Mon,  9 Sep 2019 07:48:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0238.hostedemail.com [216.40.44.238])
	by kanga.kvack.org (Postfix) with ESMTP id 56CE76B0006
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:48:52 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 131F32C94
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:48:52 +0000 (UTC)
X-FDA: 75915210504.30.tax91_6a7944fe7c413
X-HE-Tag: tax91_6a7944fe7c413
X-Filterd-Recvd-Size: 3988
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:48:51 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B011D3060815;
	Mon,  9 Sep 2019 11:48:50 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-173.ams2.redhat.com [10.36.116.173])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AF815100197A;
	Mon,  9 Sep 2019 11:48:39 +0000 (UTC)
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
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v1 1/3] mm/memory_hotplug: Export generic_online_page()
Date: Mon,  9 Sep 2019 13:48:28 +0200
Message-Id: <20190909114830.662-2-david@redhat.com>
In-Reply-To: <20190909114830.662-1-david@redhat.com>
References: <20190909114830.662-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 09 Sep 2019 11:48:50 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Let's expose generic_online_page() so online_page_callback users can
simply fallback to the generic implementation when actually deciding to
online the pages.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h | 1 +
 mm/memory_hotplug.c            | 5 ++---
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
index 8ee3a2ae5131..71a620eabb62 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -102,6 +102,7 @@ extern unsigned long __offline_isolated_pages(unsigne=
d long start_pfn,
=20
 typedef void (*online_page_callback_t)(struct page *page, unsigned int o=
rder);
=20
+extern void generic_online_page(struct page *page, unsigned int order);
 extern int set_online_page_callback(online_page_callback_t callback);
 extern int restore_online_page_callback(online_page_callback_t callback)=
;
=20
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2f0d2908e235..f32a5feaf7ff 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -49,8 +49,6 @@
  * and restore_online_page_callback() for generic callback restore.
  */
=20
-static void generic_online_page(struct page *page, unsigned int order);
-
 static online_page_callback_t online_page_callback =3D generic_online_pa=
ge;
 static DEFINE_MUTEX(online_page_callback_lock);
=20
@@ -616,7 +614,7 @@ void __online_page_free(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__online_page_free);
=20
-static void generic_online_page(struct page *page, unsigned int order)
+void generic_online_page(struct page *page, unsigned int order)
 {
 	kernel_map_pages(page, 1 << order, 1);
 	__free_pages_core(page, order);
@@ -626,6 +624,7 @@ static void generic_online_page(struct page *page, un=
signed int order)
 		totalhigh_pages_add(1UL << order);
 #endif
 }
+EXPORT_SYMBOL_GPL(generic_online_page);
=20
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_=
pages,
 			void *arg)
--=20
2.21.0


