Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47EEFC3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:26:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 146AA233FD
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:26:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 146AA233FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E0D26B02F3; Thu, 22 Aug 2019 06:26:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 991D56B02F4; Thu, 22 Aug 2019 06:26:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 881526B02F5; Thu, 22 Aug 2019 06:26:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 661BA6B02F3
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:26:41 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1D91B180AD801
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:26:41 +0000 (UTC)
X-FDA: 75849685002.30.taste88_5769e6044cf50
X-HE-Tag: taste88_5769e6044cf50
X-Filterd-Recvd-Size: 6685
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:26:40 +0000 (UTC)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7MAMgUM099105
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:26:39 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2uhqy1k7k8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:26:39 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Thu, 22 Aug 2019 11:26:37 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 22 Aug 2019 11:26:35 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7MAQCv340894940
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 22 Aug 2019 10:26:12 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 85CDBAE045;
	Thu, 22 Aug 2019 10:26:33 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F07A9AE055;
	Thu, 22 Aug 2019 10:26:30 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.57.57])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 22 Aug 2019 10:26:30 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v7 0/7] KVMPPC driver to manage secure guest pages
Date: Thu, 22 Aug 2019 15:56:13 +0530
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19082210-4275-0000-0000-0000035BD3F9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082210-4276-0000-0000-0000386DF9B4
Message-Id: <20190822102620.21897-1-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-22_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908220112
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

A pseries guest can be run as a secure guest on Ultravisor-enabled
POWER platforms. On such platforms, this driver will be used to manage
the movement of guest pages between the normal memory managed by
hypervisor(HV) and secure memory managed by Ultravisor(UV).

Private ZONE_DEVICE memory equal to the amount of secure memory
available in the platform for running secure guests is created.
Whenever a page belonging to the guest becomes secure, a page from
this private device memory is used to represent and track that secure
page on the HV side. The movement of pages between normal and secure
memory is done via migrate_vma_pages(). The reverse movement is driven
via pagemap_ops.migrate_to_ram().

The page-in or page-out requests from UV will come to HV as hcalls and
HV will call back into UV via uvcalls to satisfy these page requests.

These patches are against hmm.git
(https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=3Dh=
mm)

plus

Claudio Carvalho's base ultravisor enablement patchset v6
(https://lore.kernel.org/linuxppc-dev/20190822034838.27876-1-cclaudio@lin=
ux.ibm.com/T/#t)

These patches along with Claudio's above patches are required to
run a secure pseries guest on KVM. This patchset is based on hmm.git
because hmm.git has migrate_vma cleanup and not-device memremap_pages
patchsets that are required by this patchset.

Changes in v7
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
- The major change in this version is to not create a char device but
  instead use the not device versions of memremap_pages and
  request_free_mem_region (Christoph Hellwig)
- Other changes
  * Addressed all the changes suggested by Christoph Hellwig for v6.
  * Removed MIGRATE_VMA_HELPER dependency
  * Switched to using of_find_compatible_node() and not doing
    find by path (Thiago Jung Bauermann)
  * Moved kvmppc_rmap_is_devm_pfn to kvm_host.h
  * Updated comments
  * use @page_shift argument in H_SVM_PAGE_OUT instead of PAGE_SHIFT
  * Proper handling of return val from kvmppc_devm_fault_migrate_alloc_an=
d_copy

v6: https://lore.kernel.org/linuxppc-dev/20190809084108.30343-1-bharata@l=
inux.ibm.com/T/#t

Anshuman Khandual (1):
  KVM: PPC: Ultravisor: Add PPC_UV config option

Bharata B Rao (6):
  kvmppc: Driver to manage pages of secure guest
  kvmppc: Shared pages support for secure guests
  kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
  kvmppc: Handle memory plug/unplug to secure VM
  kvmppc: Radix changes for secure guest
  kvmppc: Support reset of secure guest

 Documentation/virtual/kvm/api.txt          |  19 +
 arch/powerpc/Kconfig                       |  17 +
 arch/powerpc/include/asm/hvcall.h          |   9 +
 arch/powerpc/include/asm/kvm_book3s_devm.h |  47 ++
 arch/powerpc/include/asm/kvm_host.h        |  39 ++
 arch/powerpc/include/asm/kvm_ppc.h         |   2 +
 arch/powerpc/include/asm/ultravisor-api.h  |   6 +
 arch/powerpc/include/asm/ultravisor.h      |  36 ++
 arch/powerpc/kvm/Makefile                  |   3 +
 arch/powerpc/kvm/book3s_64_mmu_radix.c     |  22 +
 arch/powerpc/kvm/book3s_hv.c               | 113 ++++
 arch/powerpc/kvm/book3s_hv_devm.c          | 614 +++++++++++++++++++++
 arch/powerpc/kvm/powerpc.c                 |  12 +
 include/uapi/linux/kvm.h                   |   1 +
 14 files changed, 940 insertions(+)
 create mode 100644 arch/powerpc/include/asm/kvm_book3s_devm.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_devm.c

--=20
2.21.0


