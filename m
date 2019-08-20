Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C45CC3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 03:04:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00EB2206DF
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 03:04:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00EB2206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 962D36B000A; Mon, 19 Aug 2019 23:04:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 913816B000C; Mon, 19 Aug 2019 23:04:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DB946B000D; Mon, 19 Aug 2019 23:04:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0217.hostedemail.com [216.40.44.217])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4E16B000A
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:04:48 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 044A46D76
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:04:48 +0000 (UTC)
X-FDA: 75841313856.28.fold65_29dcd3454b320
X-HE-Tag: fold65_29dcd3454b320
X-Filterd-Recvd-Size: 4448
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:04:47 +0000 (UTC)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7K321L7084400;
	Mon, 19 Aug 2019 23:04:46 -0400
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ug7sh1m4f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 19 Aug 2019 23:04:46 -0400
Received: from m0098419.ppops.net (m0098419.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x7K33UUo088217;
	Mon, 19 Aug 2019 23:04:46 -0400
Received: from ppma02wdc.us.ibm.com (aa.5b.37a9.ip4.static.sl-reverse.com [169.55.91.170])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ug7sh1m41-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 19 Aug 2019 23:04:46 -0400
Received: from pps.filterd (ppma02wdc.us.ibm.com [127.0.0.1])
	by ppma02wdc.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x7K34RL4027432;
	Tue, 20 Aug 2019 03:04:45 GMT
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by ppma02wdc.us.ibm.com with ESMTP id 2ue97644dp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 20 Aug 2019 03:04:45 +0000
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7K34iB142139986
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 20 Aug 2019 03:04:44 GMT
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E4A5878064;
	Tue, 20 Aug 2019 03:04:43 +0000 (GMT)
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E57057805E;
	Tue, 20 Aug 2019 03:04:40 +0000 (GMT)
Received: from morokweng.localdomain (unknown [9.85.220.248])
	by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTPS;
	Tue, 20 Aug 2019 03:04:40 +0000 (GMT)
References: <20190809084108.30343-1-bharata@linux.ibm.com> <20190809084108.30343-2-bharata@linux.ibm.com>
User-agent: mu4e 1.2.0; emacs 26.2
From: Thiago Jung Bauermann <bauerman@linux.ibm.com>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de
Subject: Re: [PATCH v6 1/7] kvmppc: Driver to manage pages of secure guest
In-reply-to: <20190809084108.30343-2-bharata@linux.ibm.com>
Date: Tue, 20 Aug 2019 00:04:33 -0300
Message-ID: <87ftlwwn9a.fsf@morokweng.localdomain>
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-20_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908200028
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hello Bharata,

I have just a couple of small comments.

Bharata B Rao <bharata@linux.ibm.com> writes:

> +/*
> + * Get a free device PFN from the pool
> + *
> + * Called when a normal page is moved to secure memory (UV_PAGE_IN). Device
> + * PFN will be used to keep track of the secure page on HV side.
> + *
> + * @rmap here is the slot in the rmap array that corresponds to @gpa.
> + * Thus a non-zero rmap entry indicates that the corresonding guest

Typo: corresponding

> +static u64 kvmppc_get_secmem_size(void)
> +{
> +	struct device_node *np;
> +	int i, len;
> +	const __be32 *prop;
> +	u64 size = 0;
> +
> +	np = of_find_node_by_path("/ibm,ultravisor/ibm,uv-firmware");
> +	if (!np)
> +		goto out;

I believe that in general we try to avoid hard-coding the path when a
node is accessed and searched instead via its compatible property.

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

