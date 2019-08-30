Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2B4DC3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:15:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F5D723429
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 09:15:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F5D723429
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 246736B0266; Fri, 30 Aug 2019 05:15:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F6F06B0269; Fri, 30 Aug 2019 05:15:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 132D06B026A; Fri, 30 Aug 2019 05:15:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id E2F0A6B0266
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 05:15:21 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8F002181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:15:21 +0000 (UTC)
X-FDA: 75878535642.07.rake71_4bdd4f581962c
X-HE-Tag: rake71_4bdd4f581962c
X-Filterd-Recvd-Size: 4036
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:15:21 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4E6437BDA0;
	Fri, 30 Aug 2019 09:15:20 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 667E7600F8;
	Fri, 30 Aug 2019 09:15:16 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH v4 7/8] mm/memory_hotplug: Drop local variables in shrink_zone_span()
Date: Fri, 30 Aug 2019 11:14:27 +0200
Message-Id: <20190830091428.18399-8-david@redhat.com>
In-Reply-To: <20190830091428.18399-1-david@redhat.com>
References: <20190830091428.18399-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 30 Aug 2019 09:15:20 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Get rid of the unnecessary local variables.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 82f5012cea3c..80cb32cd105e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -374,14 +374,11 @@ static unsigned long find_biggest_section_pfn(int n=
id, struct zone *zone,
 static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 			     unsigned long end_pfn)
 {
-	unsigned long zone_start_pfn =3D zone->zone_start_pfn;
-	unsigned long z =3D zone_end_pfn(zone); /* zone_end_pfn namespace clash=
 */
-	unsigned long zone_end_pfn =3D z;
 	unsigned long pfn;
 	int nid =3D zone_to_nid(zone);
=20
 	zone_span_writelock(zone);
-	if (zone_start_pfn =3D=3D start_pfn) {
+	if (zone->zone_start_pfn =3D=3D start_pfn) {
 		/*
 		 * If the section is smallest section in the zone, it need
 		 * shrink zone->zone_start_pfn and zone->zone_spanned_pages.
@@ -389,25 +386,25 @@ static void shrink_zone_span(struct zone *zone, uns=
igned long start_pfn,
 		 * for shrinking zone.
 		 */
 		pfn =3D find_smallest_section_pfn(nid, zone, end_pfn,
-						zone_end_pfn);
+						zone_end_pfn(zone));
 		if (pfn) {
+			zone->spanned_pages =3D zone_end_pfn(zone) - pfn;
 			zone->zone_start_pfn =3D pfn;
-			zone->spanned_pages =3D zone_end_pfn - pfn;
 		} else {
 			zone->zone_start_pfn =3D 0;
 			zone->spanned_pages =3D 0;
 		}
-	} else if (zone_end_pfn =3D=3D end_pfn) {
+	} else if (zone_end_pfn(zone) =3D=3D end_pfn) {
 		/*
 		 * If the section is biggest section in the zone, it need
 		 * shrink zone->spanned_pages.
 		 * In this case, we find second biggest valid mem_section for
 		 * shrinking zone.
 		 */
-		pfn =3D find_biggest_section_pfn(nid, zone, zone_start_pfn,
+		pfn =3D find_biggest_section_pfn(nid, zone, zone->zone_start_pfn,
 					       start_pfn);
 		if (pfn)
-			zone->spanned_pages =3D pfn - zone_start_pfn + 1;
+			zone->spanned_pages =3D pfn - zone->zone_start_pfn + 1;
 		else {
 			zone->zone_start_pfn =3D 0;
 			zone->spanned_pages =3D 0;
--=20
2.21.0


