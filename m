Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5891DC3A59B
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 05:28:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0216F2087E
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 05:28:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0216F2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C6E36B0008; Mon, 19 Aug 2019 01:28:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6575E6B000A; Mon, 19 Aug 2019 01:28:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53DF76B000C; Mon, 19 Aug 2019 01:28:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0188.hostedemail.com [216.40.44.188])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6826B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:28:07 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D34398248AAA
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 05:28:06 +0000 (UTC)
X-FDA: 75838046172.24.event60_46c68050c8e51
X-HE-Tag: event60_46c68050c8e51
X-Filterd-Recvd-Size: 4015
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 05:28:06 +0000 (UTC)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7J5QwUb042052
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:28:05 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ufmx6sdjd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 01:28:04 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Mon, 19 Aug 2019 06:28:02 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 19 Aug 2019 06:27:58 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7J5RvCN51708038
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 19 Aug 2019 05:27:57 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 32A0411C054;
	Mon, 19 Aug 2019 05:27:57 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4DABE11C04C;
	Mon, 19 Aug 2019 05:27:55 +0000 (GMT)
Received: from in.ibm.com (unknown [9.109.246.128])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 19 Aug 2019 05:27:54 +0000 (GMT)
Date: Mon, 19 Aug 2019 10:57:52 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
        Jason Gunthorpe <jgg@mellanox.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: add a not device managed memremap_pages v3
Reply-To: bharata@linux.ibm.com
References: <20190818090557.17853-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190818090557.17853-1-hch@lst.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19081905-0020-0000-0000-00000361369F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19081905-0021-0000-0000-000021B66031
Message-Id: <20190819052752.GD8784@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-19_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=802 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908190062
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 18, 2019 at 11:05:53AM +0200, Christoph Hellwig wrote:
> Hi Dan and Jason,
> 
> Bharata has been working on secure page management for kvmppc guests,
> and one I thing I noticed is that he had to fake up a struct device
> just so that it could be passed to the devm_memremap_pages
> instrastructure for device private memory.
> 
> This series adds non-device managed versions of the
> devm_request_free_mem_region and devm_memremap_pages functions for
> his use case.

Tested kvmppc ultravisor patchset with migrate_vma changes and this
patchset. (Had to manually patch mm/memremap.c instead of kernel/memremap.c
though)

For the series,

Tested-by: Bharata B Rao <bharata@linux.ibm.com>


