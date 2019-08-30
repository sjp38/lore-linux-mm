Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8606CC3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 11:13:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E8B521897
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 11:13:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E8B521897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E222D6B0006; Fri, 30 Aug 2019 07:13:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DACEF6B0008; Fri, 30 Aug 2019 07:13:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C730F6B000A; Fri, 30 Aug 2019 07:13:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1606B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 07:13:44 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 51820181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 11:13:44 +0000 (UTC)
X-FDA: 75878833968.28.leaf21_5ac94fa133321
X-HE-Tag: leaf21_5ac94fa133321
X-Filterd-Recvd-Size: 5204
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 11:13:43 +0000 (UTC)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7UBCBGZ105028
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 07:13:42 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2upyvu73ae-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 07:13:42 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 30 Aug 2019 12:13:40 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 30 Aug 2019 12:13:38 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7UBDaHf59965478
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 30 Aug 2019 11:13:36 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9BDB9A405F;
	Fri, 30 Aug 2019 11:13:36 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E47B3A405C;
	Fri, 30 Aug 2019 11:13:34 +0000 (GMT)
Received: from in.ibm.com (unknown [9.85.81.70])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri, 30 Aug 2019 11:13:34 +0000 (GMT)
Date: Fri, 30 Aug 2019 16:43:32 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, cclaudio@linux.ibm.com,
        hch@lst.de
Subject: Re: [PATCH v7 1/7] kvmppc: Driver to manage pages of secure guest
Reply-To: bharata@linux.ibm.com
References: <20190822102620.21897-1-bharata@linux.ibm.com>
 <20190822102620.21897-2-bharata@linux.ibm.com>
 <20190829030219.GA17497@us.ibm.com>
 <20190829065642.GA31913@in.ibm.com>
 <20190829193911.GA26729@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829193911.GA26729@us.ibm.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-TM-AS-GCONF: 00
x-cbid: 19083011-0020-0000-0000-000003659D50
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19083011-0021-0000-0000-000021BAF9A8
Message-Id: <20190830111332.GE31913@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-30_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=956 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908300122
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 29, 2019 at 12:39:11PM -0700, Sukadev Bhattiprolu wrote:
> Bharata B Rao [bharata@linux.ibm.com] wrote:
> > On Wed, Aug 28, 2019 at 08:02:19PM -0700, Sukadev Bhattiprolu wrote:
> Where do we serialize two threads attempting to H_SVM_PAGE_IN the same gfn
> at the same time? Or one thread issuing a H_SVM_PAGE_IN and another a
> H_SVM_PAGE_OUT for the same page?

I am not not serializing page-in/out calls on same gfn, I thought you take
care of that in UV, guess UV doesn't yet.

I can probably use rmap_lock() and serialize such calls in HV if UV can't
prevent such calls easily.

> > > > +
> > > > +	if (!trylock_page(dpage))
> > > > +		goto out_clear;
> > > > +
> > > > +	*rmap = devm_pfn | KVMPPC_RMAP_DEVM_PFN;
> > > > +	pvt = kzalloc(sizeof(*pvt), GFP_ATOMIC);
> > > > +	if (!pvt)
> > > > +		goto out_unlock;
> 
> If we fail to alloc, we don't clear the KVMPPC_RMAP_DEVM_PFN?

Right, I will move the assignment to *rmap to after kzalloc.

> 
> Also, when/where do we clear this flag on an uv-page-out?
> kvmppc_devm_drop_pages() drops the flag on a local variable but not
> in the rmap? If we don't clear the flag on page-out, would the
> subsequent H_SVM_PAGE_IN of this page fail?

It gets cleared in kvmppc_devm_page_free().

> 
> Ok. Nit. thought we can drop the "_fault" in the function name but would
> collide the other "alloc_and_copy" function used during H_SVM_PAGE_IN.
> If the two alloc_and_copy functions are symmetric, maybe they could
> have "page_in" and "page_out" in the (already long) names.

Christoph also suggested to reorganize these two calls. Will take care.

Regards,
Bharata.


