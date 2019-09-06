Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 029E7C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 11:36:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C27892070C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 11:36:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C27892070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39BE06B0003; Fri,  6 Sep 2019 07:36:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34DA06B0006; Fri,  6 Sep 2019 07:36:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23C696B0007; Fri,  6 Sep 2019 07:36:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0028.hostedemail.com [216.40.44.28])
	by kanga.kvack.org (Postfix) with ESMTP id 02BAF6B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 07:36:50 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 95985180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:36:50 +0000 (UTC)
X-FDA: 75904293780.23.test78_75dd643ce563d
X-HE-Tag: test78_75dd643ce563d
X-Filterd-Recvd-Size: 5298
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:36:49 +0000 (UTC)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x86Bai6u128015
	for <linux-mm@kvack.org>; Fri, 6 Sep 2019 07:36:49 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uun8e3fdy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 06 Sep 2019 07:36:48 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 6 Sep 2019 12:36:46 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 6 Sep 2019 12:36:45 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x86Bahag46399692
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 6 Sep 2019 11:36:43 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7AA2652054;
	Fri,  6 Sep 2019 11:36:43 +0000 (GMT)
Received: from in.ibm.com (unknown [9.199.53.172])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id B556A5204E;
	Fri,  6 Sep 2019 11:36:41 +0000 (GMT)
Date: Fri, 6 Sep 2019 17:06:39 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com
Subject: Re: [PATCH v7 1/7] kvmppc: Driver to manage pages of secure guest
Reply-To: bharata@linux.ibm.com
References: <20190822102620.21897-1-bharata@linux.ibm.com>
 <20190822102620.21897-2-bharata@linux.ibm.com>
 <20190829083810.GA13039@lst.de>
 <20190830034259.GD31913@in.ibm.com>
 <20190902075356.GA28967@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190902075356.GA28967@lst.de>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-TM-AS-GCONF: 00
x-cbid: 19090611-0008-0000-0000-00000311D8FF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19090611-0009-0000-0000-00004A303630
Message-Id: <20190906113639.GA8748@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-06_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=988 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909060123
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 09:53:56AM +0200, Christoph Hellwig wrote:
> On Fri, Aug 30, 2019 at 09:12:59AM +0530, Bharata B Rao wrote:
> > On Thu, Aug 29, 2019 at 10:38:10AM +0200, Christoph Hellwig wrote:
> > > On Thu, Aug 22, 2019 at 03:56:14PM +0530, Bharata B Rao wrote:
> > > > +/*
> > > > + * Bits 60:56 in the rmap entry will be used to identify the
> > > > + * different uses/functions of rmap.
> > > > + */
> > > > +#define KVMPPC_RMAP_DEVM_PFN	(0x2ULL << 56)
> > > 
> > > How did you come up with this specific value?
> > 
> > Different usage types of RMAP array are being defined.
> > https://patchwork.ozlabs.org/patch/1149791/
> > 
> > The above value is reserved for device pfn usage.
> 
> Shouldn't all these defintions go in together in a patch?

Ideally yes, but the above patch is already in Paul's tree, I will sync
up with him about this.

> Also is bit 56+ a set of values, so is there 1 << 56 and 3 << 56 as well?  Seems
> like even that other patch doesn't fully define these "pfn" values.

I realized that the bit numbers have changed, it is no longer bits 60:56,
but instead top 8bits. 

#define KVMPPC_RMAP_UVMEM_PFN   0x0200000000000000
static inline bool kvmppc_rmap_is_uvmem_pfn(unsigned long *rmap)
{
        return ((*rmap & 0xff00000000000000) == KVMPPC_RMAP_UVMEM_PFN);
}

> 
> > > No need for !! when returning a bool.  Also the helper seems a little
> > > pointless, just opencoding it would make the code more readable in my
> > > opinion.
> > 
> > I expect similar routines for other usages of RMAP to come up.
> 
> Please drop them all.  Having to wade through a header to check for
> a specific bit that also is set manually elsewhere in related code
> just obsfucates it for the reader.

I am currently using the routine kvmppc_rmap_is_uvmem_pfn() (shown
above) instead open coding it at multiple places, but I can drop it if
you prefer.

Regards,
Bharata.


