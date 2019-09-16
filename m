Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4481CC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 06:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D959F2067B
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 06:06:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D959F2067B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A72D6B0005; Mon, 16 Sep 2019 02:06:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 457036B0006; Mon, 16 Sep 2019 02:06:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31F2A6B0007; Mon, 16 Sep 2019 02:06:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0009.hostedemail.com [216.40.44.9])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7A76B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 02:06:49 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 91960824CA30
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 06:06:48 +0000 (UTC)
X-FDA: 75939750096.18.scene70_130f67d14c01
X-HE-Tag: scene70_130f67d14c01
X-Filterd-Recvd-Size: 4490
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 06:06:48 +0000 (UTC)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8G61r0j069034
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 02:06:46 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2v233s2exn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 02:06:45 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Mon, 16 Sep 2019 07:06:44 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 16 Sep 2019 07:06:39 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8G66c9755574628
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 16 Sep 2019 06:06:38 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A8A4911C050;
	Mon, 16 Sep 2019 06:06:38 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 53A8811C04C;
	Mon, 16 Sep 2019 06:06:38 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 16 Sep 2019 06:06:38 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id CDA59A01B5;
	Mon, 16 Sep 2019 16:06:36 +1000 (AEST)
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
Subject: [PATCH v2 0/2] Add bounds check for Hotplugged memory
Date: Mon, 16 Sep 2019 16:05:38 +1000
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19091606-0012-0000-0000-0000034C692D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091606-0013-0000-0000-00002186DDB4
Message-Id: <20190916060544.21824-1-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-16_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=569 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909160066
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000024, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

This series adds bounds checks for hotplugged memory, ensuring that
it is within the physically addressable range (for platforms that
define MAX_(POSSIBLE_)PHYSMEM_BITS.

This allows for early failure, rather than attempting to access
bogus section numbers.

Changelog:
 V2:
   - Don't use MAX_POSSIBLE_PHYSMEM_BITS as it's wider that what
     may be available

Alastair D'Silva (2):
  memory_hotplug: Add a bounds check to check_hotplug_memory_range()
  mm: Add a bounds check in devm_memremap_pages()

 include/linux/memory_hotplug.h |  1 +
 mm/memory_hotplug.c            | 13 ++++++++++++-
 mm/memremap.c                  |  8 ++++++++
 3 files changed, 21 insertions(+), 1 deletion(-)

--=20
2.21.0


