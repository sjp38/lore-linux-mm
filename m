Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACF68C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:25:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30AC520872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:25:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="bLdhODUh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30AC520872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A99636B0003; Tue, 10 Sep 2019 06:25:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4A4E6B0006; Tue, 10 Sep 2019 06:25:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93AF46B0007; Tue, 10 Sep 2019 06:25:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id 71B416B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:25:04 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 19739181AC9AE
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:25:04 +0000 (UTC)
X-FDA: 75918628128.07.cook97_eedbee401927
X-HE-Tag: cook97_eedbee401927
X-Filterd-Recvd-Size: 5594
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com [66.55.73.32])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:25:02 +0000 (UTC)
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id C3FF82DC1B4F;
	Tue, 10 Sep 2019 06:25:00 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1568111101;
	bh=HDAltXrE8fa0s1cXwhaPiIFePgfp29KfB1TH4WQiFKM=;
	h=From:To:Cc:References:In-Reply-To:Subject:Date:From;
	b=bLdhODUhBW4Fo/x94Nj+R+V91mwnbDdWHLNOGLCq0biZGZH3Jh+idjt+I4APSOr8C
	 Rbc8OmvyYWwlcbdY4DffVqXm1RUEEn3bfRKdaZ1uoMBCsX+spov/LrzTCPI8p/m6yG
	 eorPdXIjF7Xp4/1L2OakqTNsZo7lNf7vyW9f4wCMpok5yTmvZEsL0GMXwFEsrDvVqV
	 u2BgYZUPjehGpv0d4ae7pNuevsXh0ymINJnKAs/jiu7A8fXASd+pYF2Z09eDbzZJTh
	 rpu+wYaQiZaqh9o5kRpPypjiPm7X6UFOTf8brRROPvWQI0tSg3gcbZbnpN8doK/0IN
	 To853JLOgdR9DOz+Rofmdkpor1j24qEnCwrL59ebH7AMvY/hgaDftc8bL+w6G3fDiu
	 /DdLZUth6SFIpG/syJjKU3YM7QaK33iOJMTO6896o/9bTT2Wyrd0PQItUV+aDxtWFh
	 5uh5FAYEVcPNCe4PJ7st0HYpohFsbuKa9xyf360C6loFML0oFu6jUNQYj0uur0Skg0
	 1fg545R3fYt0a+/SbIObDbvt9lhOh7fMJeqCxkIaudOiWBuTxoYKmBCzDF+5yKubCL
	 f82z0VccKg8yE5D2YaC57RDufBuKihrXFF2SH0JqSFbPOehLLX0RZH1maGEvkJ7hTj
	 ZOP4NSLQU6ekz1+NkJkLdFdQ=
Received: from Hawking (ntp.lan [10.0.1.1])
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x8AAOsMd022564
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 10 Sep 2019 20:24:54 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
From: "Alastair D'Silva" <alastair@d-silva.org>
To: "'David Hildenbrand'" <david@redhat.com>,
        "'Alastair D'Silva'" <alastair@au1.ibm.com>
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
        "'Oscar Salvador'" <osalvador@suse.com>,
        "'Michal Hocko'" <mhocko@suse.com>,
        "'Pavel Tatashin'" <pasha.tatashin@soleen.com>,
        "'Dan Williams'" <dan.j.williams@intel.com>,
        "'Wei Yang'" <richard.weiyang@gmail.com>, "'Qian Cai'" <cai@lca.pw>,
        "'Jason Gunthorpe'" <jgg@ziepe.ca>,
        "'Logan Gunthorpe'" <logang@deltatee.com>,
        "'Ira Weiny'" <ira.weiny@intel.com>, <linux-mm@kvack.org>,
        <linux-kernel@vger.kernel.org>
References: <20190910025225.25904-1-alastair@au1.ibm.com> <20190910025225.25904-3-alastair@au1.ibm.com> <6ca671a0-8b00-e974-7de9-a574ad9b77ec@redhat.com>
In-Reply-To: <6ca671a0-8b00-e974-7de9-a574ad9b77ec@redhat.com>
Subject: RE: [PATCH 2/2] mm: Add a bounds check in devm_memremap_pages()
Date: Tue, 10 Sep 2019 20:24:54 +1000
Message-ID: <05af01d567c1$fdb256d0$f9170470$@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Mailer: Microsoft Outlook 16.0
Thread-Index: AQHvMJj7Zv4jgOWqcZIGTeYry0K56gJQpAzUAu4+QZimxyuUcA==
Content-Language: en-au
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Tue, 10 Sep 2019 20:24:56 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: David Hildenbrand <david@redhat.com>
> Sent: Tuesday, 10 September 2019 5:39 PM
> To: Alastair D'Silva <alastair@au1.ibm.com>; alastair@d-silva.org
> Cc: Andrew Morton <akpm@linux-foundation.org>; Oscar Salvador
> <osalvador@suse.com>; Michal Hocko <mhocko@suse.com>; Pavel Tatashin
> <pasha.tatashin@soleen.com>; Dan Williams <dan.j.williams@intel.com>;
> Wei Yang <richard.weiyang@gmail.com>; Qian Cai <cai@lca.pw>; Jason
> Gunthorpe <jgg@ziepe.ca>; Logan Gunthorpe <logang@deltatee.com>; Ira
> Weiny <ira.weiny@intel.com>; linux-mm@kvack.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH 2/2] mm: Add a bounds check in
> devm_memremap_pages()
> 
> On 10.09.19 04:52, Alastair D'Silva wrote:
> > From: Alastair D'Silva <alastair@d-silva.org>
> >
> > The call to check_hotplug_memory_addressable() validates that the
> > memory is fully addressable.
> >
> > Without this call, it is possible that we may remap pages that is not
> > physically addressable, resulting in bogus section numbers being
> > returned from __section_nr().
> >
> > Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> > ---
> >  mm/memremap.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> >
> > diff --git a/mm/memremap.c b/mm/memremap.c index
> > 86432650f829..fd00993caa3e 100644
> > --- a/mm/memremap.c
> > +++ b/mm/memremap.c
> > @@ -269,6 +269,13 @@ void *devm_memremap_pages(struct device
> *dev,
> > struct dev_pagemap *pgmap)
> >
> >  	mem_hotplug_begin();
> >
> > +	error = check_hotplug_memory_addressable(res->start,
> > +						 resource_size(res));
> > +	if (error) {
> > +		mem_hotplug_done();
> > +		goto err_checkrange;
> > +	}
> > +
> 
> No need to check under the memory hotplug lock.
> 

Thanks, I'll adjust it.

> >  	/*
> >  	 * For device private memory we call add_pages() as we only need to
> >  	 * allocate and initialize struct page for the device memory. More-
> > @@ -324,6 +331,7 @@ void *devm_memremap_pages(struct device *dev,
> > struct dev_pagemap *pgmap)
> >
> >   err_add_memory:
> >  	kasan_remove_zero_shadow(__va(res->start), resource_size(res));
> > + err_checkrange:
> >   err_kasan:
> >  	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
> >   err_pfn_remap:
> >
> 
> 
> --
> 
> Thanks,
> 
> David / dhildenb
> 

-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva     msn: alastair@d-silva.org
blog: http://alastair.d-silva.org    Twitter: @EvilDeece


