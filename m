Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D186C3A59E
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 03:29:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B63E322CF7
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 03:29:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B63E322CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2662F6B02C9; Wed, 21 Aug 2019 23:29:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 216FD6B02CA; Wed, 21 Aug 2019 23:29:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DF6B6B02CB; Wed, 21 Aug 2019 23:29:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0125.hostedemail.com [216.40.44.125])
	by kanga.kvack.org (Postfix) with ESMTP id E0DC96B02C9
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:29:28 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 729E6181AC9B4
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:29:28 +0000 (UTC)
X-FDA: 75848633616.08.care68_52a6a4e69565c
X-HE-Tag: care68_52a6a4e69565c
X-Filterd-Recvd-Size: 4538
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:29:27 +0000 (UTC)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7M3RFP9111258
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:29:27 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2uhj6qhpw3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 23:29:26 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Thu, 22 Aug 2019 04:29:25 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 22 Aug 2019 04:29:22 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7M3TLOD57082002
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 22 Aug 2019 03:29:21 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 13F9D42042;
	Thu, 22 Aug 2019 03:29:21 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 971C542047;
	Thu, 22 Aug 2019 03:29:18 +0000 (GMT)
Received: from in.ibm.com (unknown [9.199.42.175])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 22 Aug 2019 03:29:18 +0000 (GMT)
Date: Thu, 22 Aug 2019 08:59:15 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Thiago Jung Bauermann <bauerman@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de
Subject: Re: [PATCH v6 1/7] kvmppc: Driver to manage pages of secure guest
Reply-To: bharata@linux.ibm.com
References: <20190809084108.30343-1-bharata@linux.ibm.com>
 <20190809084108.30343-2-bharata@linux.ibm.com>
 <87ftlwwn9a.fsf@morokweng.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ftlwwn9a.fsf@morokweng.localdomain>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19082203-4275-0000-0000-0000035BB836
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082203-4276-0000-0000-0000386DDCE1
Message-Id: <20190822032915.GA13625@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-22_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908220033
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000035, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 12:04:33AM -0300, Thiago Jung Bauermann wrote:
> 
> Hello Bharata,
> 
> I have just a couple of small comments.
> 
> Bharata B Rao <bharata@linux.ibm.com> writes:
> 
> > +/*
> > + * Get a free device PFN from the pool
> > + *
> > + * Called when a normal page is moved to secure memory (UV_PAGE_IN). Device
> > + * PFN will be used to keep track of the secure page on HV side.
> > + *
> > + * @rmap here is the slot in the rmap array that corresponds to @gpa.
> > + * Thus a non-zero rmap entry indicates that the corresonding guest
> 
> Typo: corresponding
> 
> > +static u64 kvmppc_get_secmem_size(void)
> > +{
> > +	struct device_node *np;
> > +	int i, len;
> > +	const __be32 *prop;
> > +	u64 size = 0;
> > +
> > +	np = of_find_node_by_path("/ibm,ultravisor/ibm,uv-firmware");
> > +	if (!np)
> > +		goto out;
> 
> I believe that in general we try to avoid hard-coding the path when a
> node is accessed and searched instead via its compatible property.

Thanks, will switch to of_find_compatible_node().

Regards,
Bharata.


