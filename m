Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C14FBC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:09:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D4662070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:09:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D4662070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=de.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4138D6B059C; Mon, 26 Aug 2019 11:09:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EABB6B059D; Mon, 26 Aug 2019 11:09:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3004A6B059E; Mon, 26 Aug 2019 11:09:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED3E6B059C
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:09:50 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A34E31EF1
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:09:49 +0000 (UTC)
X-FDA: 75864913698.03.burn59_1b8536b6e0312
X-HE-Tag: burn59_1b8536b6e0312
X-Filterd-Recvd-Size: 5618
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:09:48 +0000 (UTC)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7QF6uSD026618
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:09:47 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2umgtcju2h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:09:47 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 26 Aug 2019 16:09:41 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 26 Aug 2019 16:09:37 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7QF9abA55836676
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 26 Aug 2019 15:09:36 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 307514C04A;
	Mon, 26 Aug 2019 15:09:36 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B69734C04E;
	Mon, 26 Aug 2019 15:09:35 +0000 (GMT)
Received: from thinkpad (unknown [9.152.98.249])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 26 Aug 2019 15:09:35 +0000 (GMT)
Date: Mon, 26 Aug 2019 17:09:34 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>,
        Ralph Campbell <rcampbell@nvidia.com>,
        =?UTF-8?B?SsOpcsO0bWU=?= Glisse
 <jglisse@redhat.com>,
        Will Deacon <will@kernel.org>, Peter Zijlstra
 <peterz@infradead.org>,
        "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
        Dave Airlie <airlied@redhat.com>,
        Thomas Hellstrom <thellstrom@vmware.com>,
        Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: replace is_zero_pfn with is_huge_zero_pmd for thp
In-Reply-To: <20190826131858.GB15933@bombadil.infradead.org>
References: <20190825200621.211494-1-yuzhao@google.com>
	<20190826131858.GB15933@bombadil.infradead.org>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19082615-0028-0000-0000-0000039426E8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082615-0029-0000-0000-000024565C3E
Message-Id: <20190826170934.7c2f4340@thinkpad>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-26_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=979 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908260158
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Aug 2019 06:18:58 -0700
Matthew Wilcox <willy@infradead.org> wrote:

> Why did you not cc Gerald who wrote the patch?  You can't just
> run get_maintainers.pl and call it good.
> 
> On Sun, Aug 25, 2019 at 02:06:21PM -0600, Yu Zhao wrote:
> > For hugely mapped thp, we use is_huge_zero_pmd() to check if it's
> > zero page or not.
> > 
> > We do fill ptes with my_zero_pfn() when we split zero thp pmd, but
> >  this is not what we have in vm_normal_page_pmd().
> > pmd_trans_huge_lock() makes sure of it.
> > 
> > This is a trivial fix for /proc/pid/numa_maps, and AFAIK nobody
> > complains about it.
> > 
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > ---
> >  mm/memory.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index e2bb51b6242e..ea3c74855b23 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -654,7 +654,7 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
> >  
> >  	if (pmd_devmap(pmd))
> >  		return NULL;
> > -	if (is_zero_pfn(pfn))
> > +	if (is_huge_zero_pmd(pmd))
> >  		return NULL;
> >  	if (unlikely(pfn > highest_memmap_pfn))
> >  		return NULL;
> > -- 
> > 2.23.0.187.g17f5b7556c-goog
> >   

Looks good to me. The "_pmd" versions for can_gather_numa_stats() and
vm_normal_page() were introduced to avoid using pte_present/dirty() on
pmds, which is not affected by this patch.

In fact, for vm_normal_page_pmd() I basically copied most of the code
from vm_normal_page(), including the is_zero_pfn(pfn) check, which does
look wrong to me now. Using is_huge_zero_pmd() should be correct.

Maybe the description could also mention the symptom of this bug?
I would assume that it affects anon/dirty accounting in gather_pte_stats(),
for huge mappings, if zero page mappings are not correctly recognized.

Regards,
Gerald


