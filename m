Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFDE0C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 10:06:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FE8020665
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 10:06:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FE8020665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5AEB6B0005; Tue, 13 Aug 2019 06:06:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0B486B0006; Tue, 13 Aug 2019 06:06:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B20806B0007; Tue, 13 Aug 2019 06:06:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0120.hostedemail.com [216.40.44.120])
	by kanga.kvack.org (Postfix) with ESMTP id 904D66B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 06:06:24 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 32188181AC9B4
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:06:24 +0000 (UTC)
X-FDA: 75816974688.15.stick41_72045570a3962
X-HE-Tag: stick41_72045570a3962
X-Filterd-Recvd-Size: 6753
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:06:23 +0000 (UTC)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7DA28AP013453
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 06:06:22 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ubr3ufavu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 06:06:21 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 13 Aug 2019 11:06:19 +0100
Received: from b06avi18878370.portsmouth.uk.ibm.com (9.149.26.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 13 Aug 2019 11:06:16 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06avi18878370.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7DA6FYi38601132
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 13 Aug 2019 10:06:15 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A9431A405E;
	Tue, 13 Aug 2019 10:06:15 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0FCFBA4053;
	Tue, 13 Aug 2019 10:06:15 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.59])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 13 Aug 2019 10:06:14 +0000 (GMT)
Date: Tue, 13 Aug 2019 13:06:13 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
        Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [rgushchin:fix_vmstats 210/221]
 arch/microblaze/include/asm/pgalloc.h:63:7: error: implicit declaration of
 function 'pgtable_page_ctor'; did you mean 'pgtable_pmd_page_ctor'?
References: <201908131204.B910fkl1%lkp@intel.com>
 <20190813095312.GB866@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813095312.GB866@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19081310-0008-0000-0000-000003087814
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19081310-0009-0000-0000-00004A268A18
Message-Id: <20190813100612.GA19524@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-13_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=738 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908130108
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 10:53:12AM +0100, Mark Rutland wrote:
> On Tue, Aug 13, 2019 at 12:38:50PM +0800, kbuild test robot wrote:
> > tree:   https://github.com/rgushchin/linux.git fix_vmstats
> > head:   4ec858b5201ae067607e82706b36588631c1b990
> > commit: 8abab7c3016f03edee681cd2a8231c0a4f567ec9 [210/221] mm: treewide: clarify pgtable_page_{ctor,dtor}() naming
> > config: microblaze-mmu_defconfig (attached as .config)
> > compiler: microblaze-linux-gcc (GCC) 7.4.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 8abab7c3016f03edee681cd2a8231c0a4f567ec9
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=7.4.0 make.cross ARCH=microblaze 
> > 
> > If you fix the issue, kindly add following tag
> > Reported-by: kbuild test robot <lkp@intel.com>
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    In file included from arch/microblaze/kernel/process.c:21:0:
> >    arch/microblaze/include/asm/pgalloc.h: In function 'pte_alloc_one':
> > >> arch/microblaze/include/asm/pgalloc.h:63:7: error: implicit declaration of function 'pgtable_page_ctor'; did you mean 'pgtable_pmd_page_ctor'? [-Werror=implicit-function-declaration]
> >      if (!pgtable_page_ctor(ptepage)) {
> >           ^~~~~~~~~~~~~~~~~
> >           pgtable_pmd_page_ctor
> >    cc1: some warnings being treated as errors
> 
> This was correctly changed to pgtable_pte_page_ctor()  in patch I posted
> [1], and the version in today's linux-next (next-20190813), so AFAICT a
> hunk went missing when it was applied to this tree.

There is a conflict between your patch and the removal of quicklist for pte
allocations for microblaze. I'm sending a "fix" in a short while.
 
> Dodgy rebase?
> 
> Thanks,
> Mark.
> 
> > 
> > vim +63 arch/microblaze/include/asm/pgalloc.h
> > 
> > 1f84e1ea0e87ad Michal Simek       2009-05-26  59  
> > 1f84e1ea0e87ad Michal Simek       2009-05-26  60  	ptepage = alloc_pages(flags, 0);
> > 8abe73465660f1 Kirill A. Shutemov 2013-11-14  61  	if (!ptepage)
> > 8abe73465660f1 Kirill A. Shutemov 2013-11-14  62  		return NULL;
> > 8abe73465660f1 Kirill A. Shutemov 2013-11-14 @63  	if (!pgtable_page_ctor(ptepage)) {
> > 8abe73465660f1 Kirill A. Shutemov 2013-11-14  64  		__free_page(ptepage);
> > 8abe73465660f1 Kirill A. Shutemov 2013-11-14  65  		return NULL;
> > 8abe73465660f1 Kirill A. Shutemov 2013-11-14  66  	}
> > 1f84e1ea0e87ad Michal Simek       2009-05-26  67  	return ptepage;
> > 1f84e1ea0e87ad Michal Simek       2009-05-26  68  }
> > 1f84e1ea0e87ad Michal Simek       2009-05-26  69  
> > 
> > :::::: The code at line 63 was first introduced by commit
> > :::::: 8abe73465660f12dee03871f681175f4dae62e7f microblaze: add missing pgtable_page_ctor/dtor calls
> > 
> > :::::: TO: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
> > 
> > ---
> > 0-DAY kernel test infrastructure                Open Source Technology Center
> > https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
> 

-- 
Sincerely yours,
Mike.


