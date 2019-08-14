Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E178C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 17:18:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21694206C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 17:18:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21694206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hpe.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAE336B0003; Wed, 14 Aug 2019 13:18:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5EFA6B0005; Wed, 14 Aug 2019 13:18:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94DF86B0006; Wed, 14 Aug 2019 13:18:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0100.hostedemail.com [216.40.44.100])
	by kanga.kvack.org (Postfix) with ESMTP id 6E29B6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:18:15 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 163E18248AA6
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:18:15 +0000 (UTC)
X-FDA: 75821691750.08.sky44_db2e1a197c2a
X-HE-Tag: sky44_db2e1a197c2a
X-Filterd-Recvd-Size: 3537
Received: from mx0b-002e3701.pphosted.com (mx0b-002e3701.pphosted.com [148.163.143.35])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:18:13 +0000 (UTC)
Received: from pps.filterd (m0150244.ppops.net [127.0.0.1])
	by mx0b-002e3701.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7EGvC4f020879;
	Wed, 14 Aug 2019 17:18:09 GMT
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com [15.241.48.72])
	by mx0b-002e3701.pphosted.com with ESMTP id 2ucm0vh8y6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Wed, 14 Aug 2019 17:18:09 +0000
Received: from g4t3433.houston.hpecorp.net (g4t3433.houston.hpecorp.net [16.208.49.245])
	by g9t5008.houston.hpe.com (Postfix) with ESMTP id 92E2768;
	Wed, 14 Aug 2019 17:18:07 +0000 (UTC)
Received: from hpe.com (teo-eag.americas.hpqcorp.net [10.33.152.10])
	by g4t3433.houston.hpecorp.net (Postfix) with ESMTP id 4CB6F45;
	Wed, 14 Aug 2019 17:18:06 +0000 (UTC)
Date: Wed, 14 Aug 2019 12:18:06 -0500
From: Dimitri Sivanich <sivanich@hpe.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        John Hubbard <jhubbard@nvidia.com>,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Ralph Campbell <rcampbell@nvidia.com>,
        "Kuehling, Felix" <Felix.Kuehling@amd.com>,
        Alex Deucher <alexander.deucher@amd.com>,
        Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
        "David (ChunMing) Zhou" <David1.Zhou@amd.com>,
        Dimitri Sivanich <sivanich@hpe.com>,
        "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
        "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
        "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
        Gavin Shan <shangw@linux.vnet.ibm.com>,
        Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v3 hmm 04/11] misc/sgi-gru: use mmu_notifier_get/put for
 struct gru_mm_struct
Message-ID: <20190814171806.GA14680@hpe.com>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-5-jgg@ziepe.ca>
 <20190808102556.GB648@lst.de>
 <20190814155830.GO13756@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814155830.GO13756@mellanox.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-HPE-SCL: -1
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-14_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=636 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908140158
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 03:58:34PM +0000, Jason Gunthorpe wrote:
> On Thu, Aug 08, 2019 at 12:25:56PM +0200, Christoph Hellwig wrote:
> > Looks good,
> > 
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> Dimitri, are you OK with this patch?
>

I think this looks OK.

Reviewed-by: Dimitri Sivanich <sivanich@hpe.com>

