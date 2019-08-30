Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B57B9C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:07:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6842521897
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 12:07:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6842521897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8AFC6B0006; Fri, 30 Aug 2019 08:07:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B12B06B0008; Fri, 30 Aug 2019 08:07:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D9D66B000A; Fri, 30 Aug 2019 08:07:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0246.hostedemail.com [216.40.44.246])
	by kanga.kvack.org (Postfix) with ESMTP id 75CC36B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:24 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1C985181AC9B6
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:07:24 +0000 (UTC)
X-FDA: 75878969208.03.day26_7abc01fc8f804
X-HE-Tag: day26_7abc01fc8f804
X-Filterd-Recvd-Size: 5260
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:07:23 +0000 (UTC)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7UC3Fmg061175
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:22 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uq25wk8fr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:07:21 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 30 Aug 2019 13:07:19 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 30 Aug 2019 13:07:16 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7UC7ELY37355652
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 30 Aug 2019 12:07:14 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7E1E04204F;
	Fri, 30 Aug 2019 12:07:14 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B398742047;
	Fri, 30 Aug 2019 12:07:13 +0000 (GMT)
Received: from pomme.com (unknown [9.145.17.35])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 30 Aug 2019 12:07:13 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org,
        aneesh.kumar@linux.ibm.com, npiggin@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 0/3] powerpc/mm: Conditionally call H_BLOCK_REMOVE
Date: Fri, 30 Aug 2019 14:07:09 +0200
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19083012-0016-0000-0000-000002A4A2D8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19083012-0017-0000-0000-00003304FD2D
Message-Id: <20190830120712.22971-1-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-30_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=787 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908300132
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since the commit ba2dd8a26baa ("powerpc/pseries/mm: call H_BLOCK_REMOVE")=
,
the call to H_BLOCK_REMOVE is always done if the feature is exhibited.

On some system, the hypervisor may not support all the combination of
segment base page size and page size. When this happens the hcall is
returning H_PARAM, which is triggering a BUG_ON check leading to a panic.

The PAPR document is specifying a TLB Block Invalidate Characteristics it=
em
detailing which couple base page size, page size the hypervisor is
supporting through H_BLOCK_REMOVE. Furthermore, the characteristics are
also providing the size of the block the hcall could process.

Supporting various block size seems not needed as all systems I was able =
to
play with was support an 8 addresses block size, which is the maximum
through the hcall. Supporting various size may complexify the algorithm i=
n
call_block_remove() so unless this is required, this is not done.

In the case of block size different from 8, a warning message is displaye=
d
at boot time and that block size will be ignored checking for the
H_BLOCK_REMOVE support.

Due to the minimal amount of hardware showing a limited set of
H_BLOCK_REMOVE supported page size, I don't think there is a need to push
this series to the stable mailing list.

The first patch is initializing the penc values for each page size to an
invalid value to be able to detect those which have been initialized as 0
is a valid value.

The second patch is reading the characteristic through the hcall
ibm,get-system-parameter and record the supported block size for each pag=
e
size.

The third patch is changing the check used to detect the H_BLOCK_REMOVE
availability to take care of the base page size and page size couple.

Laurent Dufour (3):
  powerpc/mm: Initialize the HPTE encoding values
  powperc/mm: read TLB Block Invalidate Characteristics
  powerpc/mm: call H_BLOCK_REMOVE when supported

 arch/powerpc/include/asm/book3s/64/mmu.h |   3 +
 arch/powerpc/mm/book3s64/hash_utils.c    |   8 +-
 arch/powerpc/platforms/pseries/lpar.c    | 118 ++++++++++++++++++++++-
 3 files changed, 125 insertions(+), 4 deletions(-)

--=20
2.23.0


