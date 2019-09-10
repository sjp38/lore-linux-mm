Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F37CC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:30:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 153C1206A5
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:30:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 153C1206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAF166B000C; Tue, 10 Sep 2019 04:30:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5F866B000D; Tue, 10 Sep 2019 04:30:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4EDA6B000E; Tue, 10 Sep 2019 04:30:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0138.hostedemail.com [216.40.44.138])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB286B000C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:07 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 3DE51181AC9BF
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:30:07 +0000 (UTC)
X-FDA: 75918338454.19.toes32_1e1373042ef11
X-HE-Tag: toes32_1e1373042ef11
X-Filterd-Recvd-Size: 7211
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:30:06 +0000 (UTC)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8A8RHcw108724
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:05 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ux55bdvkn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:30:05 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 10 Sep 2019 09:30:02 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 10 Sep 2019 09:29:59 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8A8TvLH51249254
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 10 Sep 2019 08:29:57 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A477E52050;
	Tue, 10 Sep 2019 08:29:57 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.35.217])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id A532452052;
	Tue, 10 Sep 2019 08:29:55 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v8 3/8] kvmppc: Shared pages support for secure guests
Date: Tue, 10 Sep 2019 13:59:41 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190910082946.7849-1-bharata@linux.ibm.com>
References: <20190910082946.7849-1-bharata@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19091008-4275-0000-0000-00000363DA67
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091008-4276-0000-0000-000038762D16
Message-Id: <20190910082946.7849-4-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-10_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=806 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909100085
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A secure guest will share some of its pages with hypervisor (Eg. virtio
bounce buffers etc). Support sharing of pages between hypervisor and
ultravisor.

Once a secure page is converted to shared page, the device page is
unmapped from the HV side page tables.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/hvcall.h  |  3 ++
 arch/powerpc/kvm/book3s_hv_uvmem.c | 65 ++++++++++++++++++++++++++++--
 2 files changed, 65 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm=
/hvcall.h
index 2595d0144958..4e98dd992bd1 100644
--- a/arch/powerpc/include/asm/hvcall.h
+++ b/arch/powerpc/include/asm/hvcall.h
@@ -342,6 +342,9 @@
 #define H_TLB_INVALIDATE	0xF808
 #define H_COPY_TOFROM_GUEST	0xF80C
=20
+/* Flags for H_SVM_PAGE_IN */
+#define H_PAGE_IN_SHARED        0x1
+
 /* Platform-specific hcalls used by the Ultravisor */
 #define H_SVM_PAGE_IN		0xEF00
 #define H_SVM_PAGE_OUT		0xEF04
diff --git a/arch/powerpc/kvm/book3s_hv_uvmem.c b/arch/powerpc/kvm/book3s=
_hv_uvmem.c
index a1eccb065ba9..bcecb643a730 100644
--- a/arch/powerpc/kvm/book3s_hv_uvmem.c
+++ b/arch/powerpc/kvm/book3s_hv_uvmem.c
@@ -46,6 +46,7 @@ struct kvmppc_uvmem_page_pvt {
 	unsigned long *rmap;
 	unsigned int lpid;
 	unsigned long gpa;
+	bool skip_page_out;
 };
=20
 /*
@@ -159,6 +160,53 @@ kvmppc_svm_page_in(struct vm_area_struct *vma, unsig=
ned long start,
 	return ret;
 }
=20
+/*
+ * Shares the page with HV, thus making it a normal page.
+ *
+ * - If the page is already secure, then provision a new page and share
+ * - If the page is a normal page, share the existing page
+ *
+ * In the former case, uses the dev_pagemap_ops migrate_to_ram handler
+ * to unmap the device page from QEMU's page tables.
+ */
+static unsigned long
+kvmppc_share_page(struct kvm *kvm, unsigned long gpa, unsigned long page=
_shift)
+{
+
+	int ret =3D H_PARAMETER;
+	struct page *uvmem_page;
+	struct kvmppc_uvmem_page_pvt *pvt;
+	unsigned long pfn;
+	unsigned long *rmap;
+	struct kvm_memory_slot *slot;
+	unsigned long gfn =3D gpa >> page_shift;
+	int srcu_idx;
+
+	srcu_idx =3D srcu_read_lock(&kvm->srcu);
+	slot =3D gfn_to_memslot(kvm, gfn);
+	if (!slot)
+		goto out;
+
+	rmap =3D &slot->arch.rmap[gfn - slot->base_gfn];
+	if (kvmppc_rmap_type(rmap) =3D=3D KVMPPC_RMAP_UVMEM_PFN) {
+		uvmem_page =3D pfn_to_page(*rmap & ~KVMPPC_RMAP_UVMEM_PFN);
+		pvt =3D (struct kvmppc_uvmem_page_pvt *)
+			uvmem_page->zone_device_data;
+		pvt->skip_page_out =3D true;
+	}
+
+	pfn =3D gfn_to_pfn(kvm, gfn);
+	if (is_error_noslot_pfn(pfn))
+		goto out;
+
+	if (!uv_page_in(kvm->arch.lpid, pfn << page_shift, gpa, 0, page_shift))
+		ret =3D H_SUCCESS;
+	kvm_release_pfn_clean(pfn);
+out:
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+	return ret;
+}
+
 /*
  * H_SVM_PAGE_IN: Move page from normal memory to secure memory.
  */
@@ -177,9 +225,12 @@ kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long =
gpa,
 	if (page_shift !=3D PAGE_SHIFT)
 		return H_P3;
=20
-	if (flags)
+	if (flags & ~H_PAGE_IN_SHARED)
 		return H_P2;
=20
+	if (flags & H_PAGE_IN_SHARED)
+		return kvmppc_share_page(kvm, gpa, page_shift);
+
 	ret =3D H_PARAMETER;
 	srcu_idx =3D srcu_read_lock(&kvm->srcu);
 	down_read(&kvm->mm->mmap_sem);
@@ -252,8 +303,16 @@ kvmppc_svm_page_out(struct vm_area_struct *vma, unsi=
gned long start,
 	pvt =3D spage->zone_device_data;
 	pfn =3D page_to_pfn(dpage);
=20
-	ret =3D uv_page_out(pvt->lpid, pfn << page_shift, pvt->gpa, 0,
-			  page_shift);
+	/*
+	 * This function is used in two cases:
+	 * - When HV touches a secure page, for which we do UV_PAGE_OUT
+	 * - When a secure page is converted to shared page, we touch
+	 *   the page to essentially unmap the device page. In this
+	 *   case we skip page-out.
+	 */
+	if (!pvt->skip_page_out)
+		ret =3D uv_page_out(pvt->lpid, pfn << page_shift, pvt->gpa, 0,
+				  page_shift);
=20
 	if (ret =3D=3D U_SUCCESS)
 		*mig.dst =3D migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
--=20
2.21.0


