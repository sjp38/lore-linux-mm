Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4230C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 07:17:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C318214AF
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 07:17:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C318214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 356046B0281; Wed, 18 Sep 2019 03:17:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 306B16B0282; Wed, 18 Sep 2019 03:17:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F63E6B0283; Wed, 18 Sep 2019 03:17:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB76D6B0281
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 03:17:10 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 92B976D6C
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:17:10 +0000 (UTC)
X-FDA: 75947185020.16.crib44_465d2d26c355
X-HE-Tag: crib44_465d2d26c355
X-Filterd-Recvd-Size: 3970
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:17:10 +0000 (UTC)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8I7CwCd013293
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 03:17:09 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2v3cj8e41y-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 03:17:09 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Wed, 18 Sep 2019 08:17:07 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 18 Sep 2019 08:17:05 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8I7H3WV41025598
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 07:17:03 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6DDCA11C05B;
	Wed, 18 Sep 2019 07:17:03 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 88EBA11C054;
	Wed, 18 Sep 2019 07:17:01 +0000 (GMT)
Received: from in.ibm.com (unknown [9.199.59.145])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 18 Sep 2019 07:17:01 +0000 (GMT)
Date: Wed, 18 Sep 2019 12:46:59 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, cclaudio@linux.ibm.com,
        hch@lst.de, Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH v8 4/8] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Reply-To: bharata@linux.ibm.com
References: <20190910082946.7849-1-bharata@linux.ibm.com>
 <20190910082946.7849-5-bharata@linux.ibm.com>
 <20190917233502.GD27932@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190917233502.GD27932@us.ibm.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-TM-AS-GCONF: 00
x-cbid: 19091807-0020-0000-0000-0000036E72ED
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091807-0021-0000-0000-000021C41A51
Message-Id: <20190918071659.GB11675@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-18_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=865 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909180076
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 04:35:02PM -0700, Sukadev Bhattiprolu wrote:
> 
> > +unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
> > +{
> > +	if (!(kvm->arch.secure_guest & KVMPPC_SECURE_INIT_START))
> 
> Minor: Should we also check if KVMPPC_SECURE_INIT_DONE is set here (since
> both can be set)?

You imply that we can check if more H_SVM_INIT_DONE calls are issued
after first such call? Currently we just set the KVMPPC_SECURE_INIT_DONE
bit again.

Regards,
Bharata.


