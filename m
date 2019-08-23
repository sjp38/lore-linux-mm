Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00F1EC3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 06:58:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A50521726
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 06:58:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A50521726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09CA76B0381; Fri, 23 Aug 2019 02:58:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04D716B0383; Fri, 23 Aug 2019 02:58:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA6176B0384; Fri, 23 Aug 2019 02:58:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0236.hostedemail.com [216.40.44.236])
	by kanga.kvack.org (Postfix) with ESMTP id C7F3A6B0381
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 02:58:14 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4F6C2824CA3E
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 06:58:14 +0000 (UTC)
X-FDA: 75852788508.10.frogs21_47de68419aa59
X-HE-Tag: frogs21_47de68419aa59
X-Filterd-Recvd-Size: 5475
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 06:58:13 +0000 (UTC)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7N6h5hP112915
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 02:58:12 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uj9mauh3r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 02:58:12 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Fri, 23 Aug 2019 07:58:09 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 23 Aug 2019 07:58:07 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7N6w5X837552392
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 23 Aug 2019 06:58:05 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4ABE45205A;
	Fri, 23 Aug 2019 06:58:05 +0000 (GMT)
Received: from in.ibm.com (unknown [9.109.246.128])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id E32195204E;
	Fri, 23 Aug 2019 06:58:01 +0000 (GMT)
Date: Fri, 23 Aug 2019 12:27:58 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de
Subject: Re: [PATCH v7 0/7] KVMPPC driver to manage secure guest pages
Reply-To: bharata@linux.ibm.com
References: <20190822102620.21897-1-bharata@linux.ibm.com>
 <20190823041747.ctquda5uwvy2eiqz@oak.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190823041747.ctquda5uwvy2eiqz@oak.ozlabs.ibm.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19082306-0028-0000-0000-0000039308E9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082306-0029-0000-0000-000024553699
Message-Id: <20190823065758.GA29900@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-23_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908230070
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 02:17:47PM +1000, Paul Mackerras wrote:
> On Thu, Aug 22, 2019 at 03:56:13PM +0530, Bharata B Rao wrote:
> > Hi,
> > 
> > A pseries guest can be run as a secure guest on Ultravisor-enabled
> > POWER platforms. On such platforms, this driver will be used to manage
> > the movement of guest pages between the normal memory managed by
> > hypervisor(HV) and secure memory managed by Ultravisor(UV).
> > 
> > Private ZONE_DEVICE memory equal to the amount of secure memory
> > available in the platform for running secure guests is created.
> > Whenever a page belonging to the guest becomes secure, a page from
> > this private device memory is used to represent and track that secure
> > page on the HV side. The movement of pages between normal and secure
> > memory is done via migrate_vma_pages(). The reverse movement is driven
> > via pagemap_ops.migrate_to_ram().
> > 
> > The page-in or page-out requests from UV will come to HV as hcalls and
> > HV will call back into UV via uvcalls to satisfy these page requests.
> > 
> > These patches are against hmm.git
> > (https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=hmm)
> > 
> > plus
> > 
> > Claudio Carvalho's base ultravisor enablement patchset v6
> > (https://lore.kernel.org/linuxppc-dev/20190822034838.27876-1-cclaudio@linux.ibm.com/T/#t)
> 
> How are you thinking these patches will go upstream?  Are you going to
> send them via the hmm tree?
> 
> I assume you need Claudio's patchset as a prerequisite for your series
> to compile, which means the hmm maintainers would need to pull in a
> topic branch from Michael Ellerman's powerpc tree, or something like
> that.

I was hoping that changes required from hmm.git would hit upstream soon,
will reflect in  mpe's powerpc tree at which time these patches can go
via powerpc tree along with or after Claudio's patchset.

Though this depends on migrate_vma and memremap changes that
happen to be in hmm.git, this is majorly a kvmppc change. Hence I thought
it would be appropriate for this to go via your or mpe's tree together
with required dependencies.

Regards,
Bharata.


