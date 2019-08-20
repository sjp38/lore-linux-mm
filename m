Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3FA2C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 06:44:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86A972082F
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 06:44:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86A972082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33F9D6B0007; Tue, 20 Aug 2019 02:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EFF06B0008; Tue, 20 Aug 2019 02:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22D356B000A; Tue, 20 Aug 2019 02:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0186.hostedemail.com [216.40.44.186])
	by kanga.kvack.org (Postfix) with ESMTP id 032D16B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:44:51 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 76D23181AC9AE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:44:51 +0000 (UTC)
X-FDA: 75841868382.19.sleep17_476d89befad58
X-HE-Tag: sleep17_476d89befad58
X-Filterd-Recvd-Size: 6355
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:44:50 +0000 (UTC)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7K6gSWQ023524
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:44:49 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ug9xb44m0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:44:49 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 20 Aug 2019 07:44:45 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 20 Aug 2019 07:44:41 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7K6iJ0B24052144
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 20 Aug 2019 06:44:20 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 43A364C046;
	Tue, 20 Aug 2019 06:44:40 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 687304C040;
	Tue, 20 Aug 2019 06:44:38 +0000 (GMT)
Received: from in.ibm.com (unknown [9.124.35.129])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 20 Aug 2019 06:44:38 +0000 (GMT)
Date: Tue, 20 Aug 2019 12:14:36 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Suraj Jitindar Singh <sjitindarsingh@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de
Subject: Re: [PATCH v6 1/7] kvmppc: Driver to manage pages of secure guest
Reply-To: bharata@linux.ibm.com
References: <20190809084108.30343-1-bharata@linux.ibm.com>
 <20190809084108.30343-2-bharata@linux.ibm.com>
 <1566282135.2166.6.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566282135.2166.6.camel@gmail.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19082006-4275-0000-0000-0000035AFA9A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082006-4276-0000-0000-0000386D1951
Message-Id: <20190820064436.GE8784@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-20_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=963 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908200070
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 04:22:15PM +1000, Suraj Jitindar Singh wrote:
> On Fri, 2019-08-09 at 14:11 +0530, Bharata B Rao wrote:
> > KVMPPC driver to manage page transitions of secure guest
> > via H_SVM_PAGE_IN and H_SVM_PAGE_OUT hcalls.
> > 
> > H_SVM_PAGE_IN: Move the content of a normal page to secure page
> > H_SVM_PAGE_OUT: Move the content of a secure page to normal page
> > 
> > Private ZONE_DEVICE memory equal to the amount of secure memory
> > available in the platform for running secure guests is created
> > via a char device. Whenever a page belonging to the guest becomes
> > secure, a page from this private device memory is used to
> > represent and track that secure page on the HV side. The movement
> > of pages between normal and secure memory is done via
> > migrate_vma_pages() using UV_PAGE_IN and UV_PAGE_OUT ucalls.
> 
> Hi Bharata,
> 
> please see my patch where I define the bits which define the type of
> the rmap entry:
> https://patchwork.ozlabs.org/patch/1149791/
> 
> Please add an entry for the devm pfn type like:
> #define KVMPPC_RMAP_PFN_DEVM 0x0200000000000000 /* secure guest devm
> pfn */
> 
> And the following in the appropriate header file
> 
> static inline bool kvmppc_rmap_is_pfn_demv(unsigned long *rmapp)
> {
> 	return !!((*rmapp & KVMPPC_RMAP_TYPE_MASK) ==
> KVMPPC_RMAP_PFN_DEVM));
> }
> 

Sure, I have the equivalents defined locally, will move to appropriate
headers.

> Also see comment below.
> 
> > +static struct page *kvmppc_devm_get_page(unsigned long *rmap,
> > +					unsigned long gpa, unsigned
> > int lpid)
> > +{
> > +	struct page *dpage = NULL;
> > +	unsigned long bit, devm_pfn;
> > +	unsigned long nr_pfns = kvmppc_devm.pfn_last -
> > +				kvmppc_devm.pfn_first;
> > +	unsigned long flags;
> > +	struct kvmppc_devm_page_pvt *pvt;
> > +
> > +	if (kvmppc_is_devm_pfn(*rmap))
> > +		return NULL;
> > +
> > +	spin_lock_irqsave(&kvmppc_devm_lock, flags);
> > +	bit = find_first_zero_bit(kvmppc_devm.pfn_bitmap, nr_pfns);
> > +	if (bit >= nr_pfns)
> > +		goto out;
> > +
> > +	bitmap_set(kvmppc_devm.pfn_bitmap, bit, 1);
> > +	devm_pfn = bit + kvmppc_devm.pfn_first;
> > +	dpage = pfn_to_page(devm_pfn);
> > +
> > +	if (!trylock_page(dpage))
> > +		goto out_clear;
> > +
> > +	*rmap = devm_pfn | KVMPPC_PFN_DEVM;
> > +	pvt = kzalloc(sizeof(*pvt), GFP_ATOMIC);
> > +	if (!pvt)
> > +		goto out_unlock;
> > +	pvt->rmap = rmap;
> 
> Am I missing something, why does the rmap need to be stored in pvt?
> Given the gpa is already stored and this is enough to get back to the
> rmap entry, right?

I use rmap entry to note that this guest page is secure and is being
represented by device memory page on the HV side. When the page becomes
normal again, I need to undo that from dev_pagemap_ops.page_free()
where I don't have gpa.

Regards,
Bharata.


