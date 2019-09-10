Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3538FC4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 02:53:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 026C1218DE
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 02:53:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 026C1218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A17056B000A; Mon,  9 Sep 2019 22:53:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A14E6B000C; Mon,  9 Sep 2019 22:53:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B67E6B000D; Mon,  9 Sep 2019 22:53:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0143.hostedemail.com [216.40.44.143])
	by kanga.kvack.org (Postfix) with ESMTP id 6594B6B000A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 22:53:02 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0EE92181AC9AE
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:53:02 +0000 (UTC)
X-FDA: 75917489004.09.bike33_8ed7f2879430e
X-HE-Tag: bike33_8ed7f2879430e
X-Filterd-Recvd-Size: 5151
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:53:01 +0000 (UTC)
Received: from pps.filterd (m0187473.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8A2q79D035544
	for <linux-mm@kvack.org>; Mon, 9 Sep 2019 22:53:00 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uv86vm6t6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Sep 2019 22:53:00 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Tue, 10 Sep 2019 03:52:57 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 10 Sep 2019 03:52:53 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8A2qqo059375790
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 10 Sep 2019 02:52:52 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ABD9AA4057;
	Tue, 10 Sep 2019 02:52:52 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 57E46A4053;
	Tue, 10 Sep 2019 02:52:52 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 10 Sep 2019 02:52:52 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id 0C7EDA01D3;
	Tue, 10 Sep 2019 12:52:51 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
        Jason Gunthorpe <jgg@ziepe.ca>, Logan Gunthorpe <logang@deltatee.com>,
        Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] mm: Add a bounds check in devm_memremap_pages()
Date: Tue, 10 Sep 2019 12:52:21 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190910025225.25904-1-alastair@au1.ibm.com>
References: <20190910025225.25904-1-alastair@au1.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19091002-0012-0000-0000-0000034946A0
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091002-0013-0000-0000-00002183A8A5
Message-Id: <20190910025225.25904-3-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-10_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=965 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909100026
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

The call to check_hotplug_memory_addressable() validates that the memory
is fully addressable.

Without this call, it is possible that we may remap pages that is
not physically addressable, resulting in bogus section numbers
being returned from __section_nr().

Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
---
 mm/memremap.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/memremap.c b/mm/memremap.c
index 86432650f829..fd00993caa3e 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -269,6 +269,13 @@ void *devm_memremap_pages(struct device *dev, struct=
 dev_pagemap *pgmap)
=20
 	mem_hotplug_begin();
=20
+	error =3D check_hotplug_memory_addressable(res->start,
+						 resource_size(res));
+	if (error) {
+		mem_hotplug_done();
+		goto err_checkrange;
+	}
+
 	/*
 	 * For device private memory we call add_pages() as we only need to
 	 * allocate and initialize struct page for the device memory. More-
@@ -324,6 +331,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
=20
  err_add_memory:
 	kasan_remove_zero_shadow(__va(res->start), resource_size(res));
+ err_checkrange:
  err_kasan:
 	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
  err_pfn_remap:
--=20
2.21.0


