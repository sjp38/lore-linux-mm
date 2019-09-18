Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FB40C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 07:13:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19C022053B
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 07:13:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19C022053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0FCF6B027F; Wed, 18 Sep 2019 03:13:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BF906B0280; Wed, 18 Sep 2019 03:13:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D5AC6B0281; Wed, 18 Sep 2019 03:13:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0048.hostedemail.com [216.40.44.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1466B027F
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 03:13:05 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0F127180AD80A
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:13:05 +0000 (UTC)
X-FDA: 75947174730.27.cook92_72305a54eca2c
X-HE-Tag: cook92_72305a54eca2c
X-Filterd-Recvd-Size: 6063
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:13:04 +0000 (UTC)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8I7CxGj013303
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 03:13:03 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2v3cj8e01b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 03:13:00 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 18 Sep 2019 08:12:16 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 18 Sep 2019 08:12:12 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8I7BiYT42664258
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 07:11:44 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D5EE94C04A;
	Wed, 18 Sep 2019 07:12:10 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0FFE64C05A;
	Wed, 18 Sep 2019 07:12:09 +0000 (GMT)
Received: from in.ibm.com (unknown [9.199.59.145])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 18 Sep 2019 07:12:08 +0000 (GMT)
Date: Wed, 18 Sep 2019 12:42:06 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, cclaudio@linux.ibm.com,
        hch@lst.de
Subject: Re: [PATCH v8 2/8] kvmppc: Movement of pages between normal and
 secure memory
Reply-To: bharata@linux.ibm.com
References: <20190910082946.7849-1-bharata@linux.ibm.com>
 <20190910082946.7849-3-bharata@linux.ibm.com>
 <20190917233139.GB27932@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190917233139.GB27932@us.ibm.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-TM-AS-GCONF: 00
x-cbid: 19091807-4275-0000-0000-00000367EA5F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091807-4276-0000-0000-0000387A5211
Message-Id: <20190918071206.GA11675@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-18_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=728 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909180076
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 04:31:39PM -0700, Sukadev Bhattiprolu wrote:
> 
> Minor: Can this allocation be outside the lock? I guess it would change
> the order of cleanup at the end of the function.

Cleanup has bitmap_clear which needs be under spinlock, so this order
of setup/alloc and cleanup will keep things simple is what I felt.

> 
> > +	spin_unlock(&kvmppc_uvmem_pfn_lock);
> > +
> > +	*rmap = uvmem_pfn | KVMPPC_RMAP_UVMEM_PFN;
> > +	pvt->rmap = rmap;
> > +	pvt->gpa = gpa;
> > +	pvt->lpid = lpid;
> > +	dpage->zone_device_data = pvt;
> > +
> > +	get_page(dpage);
> > +	return dpage;
> > +
> > +out_unlock:
> > +	unlock_page(dpage);
> > +out_clear:
> > +	bitmap_clear(kvmppc_uvmem_pfn_bitmap, uvmem_pfn - pfn_first, 1);
> 
> Reuse variable 'bit'  here?

Sure.

> 
> > +out:
> > +	spin_unlock(&kvmppc_uvmem_pfn_lock);
> > +	return NULL;
> > +}
> > +
> > +/*
> > + * Alloc a PFN from private device memory pool and copy page from normal
> > + * memory to secure memory using UV_PAGE_IN uvcall.
> > + */
> > +static int
> > +kvmppc_svm_page_in(struct vm_area_struct *vma, unsigned long start,
> > +		   unsigned long end, unsigned long *rmap,
> > +		   unsigned long gpa, unsigned int lpid,
> > +		   unsigned long page_shift)
> > +{
> > +	unsigned long src_pfn, dst_pfn = 0;
> > +	struct migrate_vma mig;
> > +	struct page *spage;
> > +	unsigned long pfn;
> > +	struct page *dpage;
> > +	int ret = 0;
> > +
> > +	memset(&mig, 0, sizeof(mig));
> > +	mig.vma = vma;
> > +	mig.start = start;
> > +	mig.end = end;
> > +	mig.src = &src_pfn;
> > +	mig.dst = &dst_pfn;
> > +
> > +	ret = migrate_vma_setup(&mig);
> > +	if (ret)
> > +		return ret;
> > +
> > +	spage = migrate_pfn_to_page(*mig.src);
> > +	pfn = *mig.src >> MIGRATE_PFN_SHIFT;
> > +	if (!spage || !(*mig.src & MIGRATE_PFN_MIGRATE)) {
> > +		ret = 0;
> 
> Do we want to return success here (and have caller return H_SUCCESS) if
> we can't find the source page?

spage is NULL for zero page. In this case we return success but there is
no UV_PAGE_IN involved.

Absence of MIGRATE_PFN_MIGRATE indicates that the requested page
can't be migrated. I haven't hit this case till now. Similar check
is also present in the nouveau driver. I am not sure if this is strictly
needed here.

Christoph, Jason - do you know if !(*mig.src & MIGRATE_PFN_MIGRATE)
check is required and if so in which cases will it be true?

> > + * Fault handler callback when HV touches any page that has been
> 
>  Nit: s/callback/callback. Called /

Yeah will rephrase.

Regards,
Bharata.


