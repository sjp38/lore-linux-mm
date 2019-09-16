Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A051C4CECC
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:57:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2094206A4
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:57:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2094206A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 422866B0005; Mon, 16 Sep 2019 05:57:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D3996B0006; Mon, 16 Sep 2019 05:57:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E9576B0007; Mon, 16 Sep 2019 05:57:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0091.hostedemail.com [216.40.44.91])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC7F6B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:57:26 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id AC0F0824CA2F
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:57:25 +0000 (UTC)
X-FDA: 75940331250.26.honey23_7af94fe116f55
X-HE-Tag: honey23_7af94fe116f55
X-Filterd-Recvd-Size: 5551
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:57:24 +0000 (UTC)
Received: from pps.filterd (m0187473.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8G9qTcD137685
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:57:23 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2v0uusm5s7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:57:23 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Mon, 16 Sep 2019 10:57:20 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 16 Sep 2019 10:57:18 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8G9vHJW50397298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 16 Sep 2019 09:57:17 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EC8844C046;
	Mon, 16 Sep 2019 09:57:16 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E09854C040;
	Mon, 16 Sep 2019 09:57:14 +0000 (GMT)
Received: from pomme.com (unknown [9.145.76.175])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 16 Sep 2019 09:57:14 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org,
        aneesh.kumar@linux.ibm.com, npiggin@gmail.com,
        linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v2 0/2] powerpc/mm: Conditionally call H_BLOCK_REMOVE
Date: Mon, 16 Sep 2019 11:55:41 +0200
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19091609-0008-0000-0000-00000316E1D3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091609-0009-0000-0000-00004A355A78
Message-Id: <20190916095543.17496-1-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909160105
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since the commit ba2dd8a26baa ("powerpc/pseries/mm: call H_BLOCK_REMOVE")=
,
the call to H_BLOCK_REMOVE is always done if the feature is exhibited.

However, the hypervisor may not support all the block size for the hcall
H_BLOCK_REMOVE depending on the segment base page size and actual page
size.

When unsupported block size is used, the hcall H_BLOCK_REMOVE is returnin=
g
H_PARAM, which is triggering a BUG_ON check leading to a panic like this:

The PAPR document specifies the TLB Block Invalidate Characteristics whic=
h
tells for each couple segment base page size, actual page size, the size =
of
the block the hcall H_BLOCK_REMOVE is supporting.

Supporting various block sizes doesn't seem needed at that time since all
systems I was able to play with was supporting an 8 addresses block size,
which is the maximum through the hcall, or none at all. Supporting variou=
s
size would complexify the algorithm in call_block_remove() so unless this
is required, this is not done.

In the case of block size different from 8, a warning message is displaye=
d
at boot time and that block size will be ignored checking for the
H_BLOCK_REMOVE support.

Due to the minimal amount of hardware showing a limited set of
H_BLOCK_REMOVE supported page size, I don't think there is a need to push
this series to the stable mailing list.

The first patch is reading the characteristic through the hcall
ibm,get-system-parameter and record the supported block size for each pag=
e
size.  The second patch is changing the check used to detect the
H_BLOCK_REMOVE availability to take care of the base page size and page
size couple.

Changes since V1:

 - Remove penc initialisation, this is already done in
   mmu_psize_set_default_penc()
 - Add details on the TLB Block Invalidate Characteristics's buffer forma=
t
 - Introduce #define instead of using direct numerical values
 - Function reading the characteristics is now directly called from
   pSeries_setup_arch()
 - The characteristics are now stored in a dedciated table static to lpar=
.c

Laurent Dufour (2):
  powperc/mm: read TLB Block Invalidate Characteristics
  powerpc/mm: call H_BLOCK_REMOVE when supported

 .../include/asm/book3s/64/tlbflush-hash.h     |   1 +
 arch/powerpc/platforms/pseries/lpar.c         | 173 +++++++++++++++++-
 arch/powerpc/platforms/pseries/setup.c        |   1 +
 3 files changed, 173 insertions(+), 2 deletions(-)

--=20
2.23.0


