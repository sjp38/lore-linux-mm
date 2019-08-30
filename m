Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A987C3A5A7
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 184B02341B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:07:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 184B02341B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 109D26B000D; Fri, 30 Aug 2019 08:07:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03D316B000E; Fri, 30 Aug 2019 08:07:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E216F6B0010; Fri, 30 Aug 2019 08:07:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0129.hostedemail.com [216.40.44.129])
	by kanga.kvack.org (Postfix) with ESMTP id AA4646B000E
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:26 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 510ED82437C9
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:07:26 +0000 (UTC)
X-FDA: 75878969292.19.laugh28_7b1557382f516
X-HE-Tag: laugh28_7b1557382f516
X-Filterd-Recvd-Size: 4937
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:07:25 +0000 (UTC)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7UC3ZmT043082
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:24 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uq364gymn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:24 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 30 Aug 2019 13:07:22 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 30 Aug 2019 13:07:18 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7UC7HdQ40763796
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 30 Aug 2019 12:07:17 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2547A42047;
	Fri, 30 Aug 2019 12:07:17 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 63DF442042;
	Fri, 30 Aug 2019 12:07:16 +0000 (GMT)
Received: from pomme.com (unknown [9.145.17.35])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 30 Aug 2019 12:07:16 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org,
        aneesh.kumar@linux.ibm.com, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 3/3] powerpc/mm: call H_BLOCK_REMOVE when supported
Date: Fri, 30 Aug 2019 14:07:12 +0200
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190830120712.22971-1-ldufour@linux.ibm.com>
References: <20190830120712.22971-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19083012-0028-0000-0000-00000395A0EE
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19083012-0029-0000-0000-00002457E4A7
Message-Id: <20190830120712.22971-4-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-30_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=989 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908300132
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of calling H_BLOCK_REMOVE all the time when the feature is
exhibited, call this hcall only when the couple base page size, page size
is supported as reported by the TLB Invalidate Characteristics.

For regular pages and hugetlb, the assumption is made that the page size =
is
equal to the base page size. For THP the page size is assumed to be 16M.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 arch/powerpc/platforms/pseries/lpar.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platfor=
ms/pseries/lpar.c
index 375e19b3cf53..ef3dbf108a65 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -1143,7 +1143,11 @@ static inline void __pSeries_lpar_hugepage_invalid=
ate(unsigned long *slot,
 	if (lock_tlbie)
 		spin_lock_irqsave(&pSeries_lpar_tlbie_lock, flags);
=20
-	if (firmware_has_feature(FW_FEATURE_BLOCK_REMOVE))
+	/*
+	 * Assuming THP size is 16M, and we only support 8 bytes size buffer
+	 * for the momment.
+	 */
+	if (mmu_psize_defs[psize].hblk[MMU_PAGE_16M] =3D=3D 8)
 		hugepage_block_invalidate(slot, vpn, count, psize, ssize);
 	else
 		hugepage_bulk_invalidate(slot, vpn, count, psize, ssize);
@@ -1437,7 +1441,10 @@ static void pSeries_lpar_flush_hash_range(unsigned=
 long number, int local)
 	if (lock_tlbie)
 		spin_lock_irqsave(&pSeries_lpar_tlbie_lock, flags);
=20
-	if (firmware_has_feature(FW_FEATURE_BLOCK_REMOVE)) {
+	/*
+	 * Currently, we only support 8 bytes size buffer in do_block_remove().
+	 */
+	if (mmu_psize_defs[batch->psize].hblk[batch->psize] =3D=3D 8) {
 		do_block_remove(number, batch, param);
 		goto out;
 	}
--=20
2.23.0


