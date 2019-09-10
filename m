Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3B49C49ED6
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:28:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BCD3207FC
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:28:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="Y9HUa6rU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BCD3207FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27FB26B0006; Tue, 10 Sep 2019 06:28:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 209916B0008; Tue, 10 Sep 2019 06:28:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D1616B000A; Tue, 10 Sep 2019 06:28:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0113.hostedemail.com [216.40.44.113])
	by kanga.kvack.org (Postfix) with ESMTP id D473F6B0006
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:28:26 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 808F7180AD7C3
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:28:26 +0000 (UTC)
X-FDA: 75918636612.12.berry92_2c7befc8ae327
X-HE-Tag: berry92_2c7befc8ae327
X-Filterd-Recvd-Size: 7329
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com [66.55.73.32])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:28:25 +0000 (UTC)
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id 249C42DC1B4F;
	Tue, 10 Sep 2019 06:28:23 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1568111304;
	bh=bZJVg57WDp2Ql9qxXpt8yM2FR4LlDfEfnLgk5E0mBjA=;
	h=From:To:Cc:References:In-Reply-To:Subject:Date:From;
	b=Y9HUa6rUcWPZXDNjUx9UVFKf8wDG0RtUHnj+l9W7NumR7SQJGy1XLM5YK3gertZ92
	 vFGraMB04wjETdXjP94vUyH8EJ7s/lTcxFvmMnsegsm7nSbdfRMIUEOMa3dZNUttZy
	 50L0muONHnEUU0AI9LYIAQw95RimaaguCo+MPVOm4XBPIyGMBBPlUBGshVoWpIAfdg
	 fKj5ciigXPEul+6NQxOWjyHeubmbCjgkyoHIibpmc5bt6fU+TpyeJz9Dgr1vQ/8B+Y
	 DK+mJIP+C0nJfDbvX7/cBHoifpMw2OO6S9LPVH9+zG9FPDnq///gL8B36sGpYSq7Af
	 e2YAc1Gq8tjlanxCEhY3nH1v8UCin/0+LB5cNffu4FsRP6cFnm4nZTLMpeyvF6AUv6
	 wntItlOrrZkxAInF3Lt4xgZJD77QcRjacIdMK04u/bVybMXHdO3TzfPh+m70/uQ1ba
	 07OuYUb66j7d9GT1wBqCq5hXUYGUZtOkM+3MjVWfUK1+wIE6zPitYVAn0/cGNVIND6
	 Em+E2QlS8I9Dj8tDu5CQEu8ExC4HhTL2EdehhwTnNpEBJkPr0X0IdmU421BcCIbvgz
	 8fQ8mjWMfom4MB7nWhSfM/Zlcd2ykHIwU5mjyrvmrIoDE3Ehdmo9hjviorNHoPwCYp
	 er5vqaPzE11ILn3icxx7z/is=
Received: from Hawking (ntp.lan [10.0.1.1])
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x8AASKLp022591
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 10 Sep 2019 20:28:20 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
From: "Alastair D'Silva" <alastair@d-silva.org>
To: "'Kirill A. Shutemov'" <kirill@shutemov.name>,
        "'Alastair D'Silva'" <alastair@au1.ibm.com>
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
        "'David Hildenbrand'" <david@redhat.com>,
        "'Oscar Salvador'" <osalvador@suse.com>,
        "'Michal Hocko'" <mhocko@suse.com>,
        "'Pavel Tatashin'" <pasha.tatashin@soleen.com>,
        "'Wei Yang'" <richard.weiyang@gmail.com>,
        "'Dan Williams'" <dan.j.williams@intel.com>, "'Qian Cai'" <cai@lca.pw>,
        "'Jason Gunthorpe'" <jgg@ziepe.ca>,
        "'Logan Gunthorpe'" <logang@deltatee.com>,
        "'Ira Weiny'" <ira.weiny@intel.com>, <linux-mm@kvack.org>,
        <linux-kernel@vger.kernel.org>
References: <20190910025225.25904-1-alastair@au1.ibm.com> <20190910025225.25904-2-alastair@au1.ibm.com> <20190910101502.2ioujfvopyr5krpq@box.shutemov.name>
In-Reply-To: <20190910101502.2ioujfvopyr5krpq@box.shutemov.name>
Subject: RE: [PATCH 1/2] memory_hotplug: Add a bounds check to check_hotplug_memory_range()
Date: Tue, 10 Sep 2019 20:28:19 +1000
Message-ID: <05b301d567c2$772be760$6583b620$@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
X-Mailer: Microsoft Outlook 16.0
Thread-Index: AQHvMJj7Zv4jgOWqcZIGTeYry0K56gHo4ebvAnkbkLemzhNyMA==
Content-Language: en-au
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Tue, 10 Sep 2019 20:28:20 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: Kirill A. Shutemov <kirill@shutemov.name>
> Sent: Tuesday, 10 September 2019 8:15 PM
> To: Alastair D'Silva <alastair@au1.ibm.com>
> Cc: alastair@d-silva.org; Andrew Morton <akpm@linux-foundation.org>;
> David Hildenbrand <david@redhat.com>; Oscar Salvador
> <osalvador@suse.com>; Michal Hocko <mhocko@suse.com>; Pavel Tatashin
> <pasha.tatashin@soleen.com>; Wei Yang <richard.weiyang@gmail.com>;
> Dan Williams <dan.j.williams@intel.com>; Qian Cai <cai@lca.pw>; Jason
> Gunthorpe <jgg@ziepe.ca>; Logan Gunthorpe <logang@deltatee.com>; Ira
> Weiny <ira.weiny@intel.com>; linux-mm@kvack.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH 1/2] memory_hotplug: Add a bounds check to
> check_hotplug_memory_range()
> 
> On Tue, Sep 10, 2019 at 12:52:20PM +1000, Alastair D'Silva wrote:
> > From: Alastair D'Silva <alastair@d-silva.org>
> >
> > On PowerPC, the address ranges allocated to OpenCAPI LPC memory are
> > allocated from firmware. These address ranges may be higher than what
> > older kernels permit, as we increased the maximum permissable address
> > in commit 4ffe713b7587
> > ("powerpc/mm: Increase the max addressable memory to 2PB"). It is
> > possible that the addressable range may change again in the future.
> >
> > In this scenario, we end up with a bogus section returned from
> > __section_nr (see the discussion on the thread "mm: Trigger bug on if
> > a section is not found in __section_nr").
> >
> > Adding a check here means that we fail early and have an opportunity
> > to handle the error gracefully, rather than rumbling on and
> > potentially accessing an incorrect section.
> >
> > Further discussion is also on the thread ("powerpc: Perform a bounds
> > check in arch_add_memory").
> >
> > Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> > ---
> >  include/linux/memory_hotplug.h |  1 +
> >  mm/memory_hotplug.c            | 19 ++++++++++++++++++-
> >  2 files changed, 19 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/linux/memory_hotplug.h
> > b/include/linux/memory_hotplug.h index f46ea71b4ffd..bc477e98a310
> > 100644
> > --- a/include/linux/memory_hotplug.h
> > +++ b/include/linux/memory_hotplug.h
> > @@ -110,6 +110,7 @@ extern void
> > __online_page_increment_counters(struct page *page);  extern void
> > __online_page_free(struct page *page);
> >
> >  extern int try_online_node(int nid);
> > +int check_hotplug_memory_addressable(u64 start, u64 size);
> >
> >  extern int arch_add_memory(int nid, u64 start, u64 size,
> >  			struct mhp_restrictions *restrictions); diff --git
> > a/mm/memory_hotplug.c b/mm/memory_hotplug.c index
> > c73f09913165..3c5428b014f9 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1030,6 +1030,23 @@ int try_online_node(int nid)
> >  	return ret;
> >  }
> >
> > +#ifndef MAX_POSSIBLE_PHYSMEM_BITS
> > +#ifdef MAX_PHYSMEM_BITS
> > +#define MAX_POSSIBLE_PHYSMEM_BITS MAX_PHYSMEM_BITS #endif
> #endif
> > +
> > +int check_hotplug_memory_addressable(u64 start, u64 size) { #ifdef
> > +MAX_POSSIBLE_PHYSMEM_BITS
> 
> How can it be not defined? You've defined it 6 lines above.
> 

It's only conditionally defined.

I'll be following David H's advice and just using MAX_PHYSMEM_BITS in the
next spin anyway.

> > +	if ((start + size - 1) >> MAX_POSSIBLE_PHYSMEM_BITS)
> > +		return -E2BIG;
> > +#endif
> > +
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL_GPL(check_hotplug_memory_addressable);
> > +
> >  static int check_hotplug_memory_range(u64 start, u64 size)  {
> >  	/* memory range must be block size aligned */ @@ -1040,7 +1057,7
> @@
> > static int check_hotplug_memory_range(u64 start, u64 size)
> >  		return -EINVAL;
> >  	}
> >
> > -	return 0;
> > +	return check_hotplug_memory_addressable(start, size);
> >  }
> >
> >  static int online_memory_block(struct memory_block *mem, void *arg)
> > --
> > 2.21.0
> >
> 
> --
>  Kirill A. Shutemov
> 


-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva     msn: alastair@d-silva.org
blog: http://alastair.d-silva.org    Twitter: @EvilDeece



