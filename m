Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4014C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:27:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2E4D20863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:27:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2E4D20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C81F6B0008; Mon,  9 Sep 2019 11:27:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4780F6B000C; Mon,  9 Sep 2019 11:27:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B3CA6B000D; Mon,  9 Sep 2019 11:27:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0216.hostedemail.com [216.40.44.216])
	by kanga.kvack.org (Postfix) with ESMTP id 15C476B0008
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:27:04 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id BF9C1180AD7C3
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:27:03 +0000 (UTC)
X-FDA: 75915760326.02.shape32_77c85ca80131e
X-HE-Tag: shape32_77c85ca80131e
X-Filterd-Recvd-Size: 4126
Received: from mga18.intel.com (mga18.intel.com [134.134.136.126])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:27:02 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 08:27:01 -0700
X-IronPort-AV: E=Sophos;i="5.64,486,1559545200"; 
   d="scan'208";a="175011691"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga007-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 08:27:01 -0700
Message-ID: <5cfa877d02b1a6dadbb28f40111726245cf7856f.camel@linux.intel.com>
Subject: Re: [PATCH v9 5/8] arm64: Move hugetlb related definitions out of
 pgtable.h to page-defs.h
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: David Hildenbrand <david@redhat.com>, Alexander Duyck
 <alexander.duyck@gmail.com>, virtio-dev@lists.oasis-open.org, 
 kvm@vger.kernel.org, mst@redhat.com, catalin.marinas@arm.com, 
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, 
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 will@kernel.org,  linux-arm-kernel@lists.infradead.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com, 
 nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com,  aarcange@redhat.com, ying.huang@intel.com,
 pbonzini@redhat.com,  dan.j.williams@intel.com, fengguang.wu@intel.com, 
 kirill.shutemov@linux.intel.com
Date: Mon, 09 Sep 2019 08:27:01 -0700
In-Reply-To: <90785d30-cde9-f380-5f4a-8af989b11729@redhat.com>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
	 <20190907172545.10910.88045.stgit@localhost.localdomain>
	 <90785d30-cde9-f380-5f4a-8af989b11729@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-09 at 10:52 +0200, David Hildenbrand wrote:
> On 07.09.19 19:25, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Move the static definition for things such as HUGETLB_PAGE_ORDER out of
> > asm/pgtable.h and place it in page-defs.h. By doing this the includes
> > become much easier to deal with as currently arm64 is the only architecture
> > that didn't include this definition in the asm/page.h file or a file
> > included by it.
> > 
> > It also makes logical sense as PAGE_SHIFT was already defined in
> > page-defs.h so now we also have HPAGE_SHIFT defined there as well.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  arch/arm64/include/asm/page-def.h |    9 +++++++++
> >  arch/arm64/include/asm/pgtable.h  |    9 ---------
> >  2 files changed, 9 insertions(+), 9 deletions(-)
> > 
> > diff --git a/arch/arm64/include/asm/page-def.h b/arch/arm64/include/asm/page-def.h
> > index f99d48ecbeef..1c5b079e2482 100644
> > --- a/arch/arm64/include/asm/page-def.h
> > +++ b/arch/arm64/include/asm/page-def.h
> > @@ -20,4 +20,13 @@
> >  #define CONT_SIZE		(_AC(1, UL) << (CONT_SHIFT + PAGE_SHIFT))
> >  #define CONT_MASK		(~(CONT_SIZE-1))
> >  
> > +/*
> > + * Hugetlb definitions.
> > + */
> > +#define HUGE_MAX_HSTATE		4
> > +#define HPAGE_SHIFT		PMD_SHIFT
> > +#define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
> > +#define HPAGE_MASK		(~(HPAGE_SIZE - 1))
> > +#define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
> > +
> 
> I wonder if you should initially limit "config PAGE_REPORTING" to x86
> only and unlock it for the other targets once we actually test it there.
> Or did you test PAGE_REPORTING on other architectures as well?
> 

I haven't, but essentially the effects should be the same regardless of
architecture. In addition since this is a feature that can be
enabled/disabled via QEMU I am not sure there is much harm other than
getting additional testing by enabling for all of the architectures at
once.


