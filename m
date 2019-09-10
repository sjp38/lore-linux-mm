Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 256F5C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:26:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDBA72089F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:26:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="Lx4tZkss"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDBA72089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C6AC6B0007; Tue, 10 Sep 2019 06:26:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6775F6B0008; Tue, 10 Sep 2019 06:26:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58C896B000A; Tue, 10 Sep 2019 06:26:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0001.hostedemail.com [216.40.44.1])
	by kanga.kvack.org (Postfix) with ESMTP id 368096B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:26:57 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id DBC7D181AC9AE
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:26:56 +0000 (UTC)
X-FDA: 75918632832.30.ice19_1f77536b3fb02
X-HE-Tag: ice19_1f77536b3fb02
X-Filterd-Recvd-Size: 7393
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com [66.55.73.32])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:26:56 +0000 (UTC)
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id D305A2DC1B4F;
	Tue, 10 Sep 2019 06:26:54 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1568111215;
	bh=IggLXpyrgzR37Zims9TMaadnZMay9Mu65KHSmY0138A=;
	h=From:To:Cc:References:In-Reply-To:Subject:Date:From;
	b=Lx4tZkssR8JoEhRj30r5TKdn5tR6+Orw+QImB+QRX+ZsB/iW5acBC9EmUkn+RBf2c
	 FmwI2XwUoyJx0m3PwqY4MzStA89RjKp4D1hS9K34FzWb7y2aIF6fc4dON0Ees4706m
	 yDchhIfLdlgsEo+fSKiJRNGuvr5htSHtiav5O/F48Xw6Vcwk3uSn1yZ6tGe32iBost
	 Nkmud4Hhl165PyF3SHwmPPATv0MKXq4Zu/kdfySMuQRT6z00U+bIyN1aJIMlIHTHeW
	 jZhgRbeDc3FZCx8YtQUAvFP0YvFuMzob5SJumfwA43cM6LuUnowyIs+31URwyJx3Lx
	 iOSEsFTKXDnkZre4t8iVMfL9dY62Wh8xi8XjM8SPLDwZXC/AhyAMkGz6YuReozTdPP
	 FZ591GJDQURbxSWTWuVcIGqK7RB2y2iuW99jjjiiMqMvIlbABV2jl19VTCBC4yp9xI
	 HgoaZU+6koOYIY88uMVq/6cYxr4aKljcDLhs5oH9PvkhGJdypU3z+h9yEq40Wf/l9L
	 VNtKQ71+VAUkm9dhsm4XItZrC76u9C9fdtlKUt5e0BuDFR503WwnFA7spzXct8Ova2
	 UQJlrJziHPn4LK/YIiOcQPZBZUZH4fXvtXRnS7cJqUfAesfyb2g6vqmNbKw+cpPwhl
	 0Mpagc85fz+GdSCf9PjK4ayU=
Received: from Hawking (ntp.lan [10.0.1.1])
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x8AAQoXI022575
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 10 Sep 2019 20:26:50 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
From: "Alastair D'Silva" <alastair@d-silva.org>
To: "'David Hildenbrand'" <david@redhat.com>,
        "'Alastair D'Silva'" <alastair@au1.ibm.com>
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
        "'Oscar Salvador'" <osalvador@suse.com>,
        "'Michal Hocko'" <mhocko@suse.com>,
        "'Pavel Tatashin'" <pasha.tatashin@soleen.com>,
        "'Wei Yang'" <richard.weiyang@gmail.com>,
        "'Dan Williams'" <dan.j.williams@intel.com>, "'Qian Cai'" <cai@lca.pw>,
        "'Jason Gunthorpe'" <jgg@ziepe.ca>,
        "'Logan Gunthorpe'" <logang@deltatee.com>,
        "'Ira Weiny'" <ira.weiny@intel.com>, <linux-mm@kvack.org>,
        <linux-kernel@vger.kernel.org>
References: <20190910025225.25904-1-alastair@au1.ibm.com> <20190910025225.25904-2-alastair@au1.ibm.com> <f2cde731-30a8-04ca-0ec6-f654d48db7bc@redhat.com>
In-Reply-To: <f2cde731-30a8-04ca-0ec6-f654d48db7bc@redhat.com>
Subject: RE: [PATCH 1/2] memory_hotplug: Add a bounds check to check_hotplug_memory_range()
Date: Tue, 10 Sep 2019 20:26:50 +1000
Message-ID: <05b101d567c2$420492d0$c60db870$@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Mailer: Microsoft Outlook 16.0
Thread-Index: AQHvMJj7Zv4jgOWqcZIGTeYry0K56gHo4ebvAaywkWym1HZBYA==
Content-Language: en-au
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Tue, 10 Sep 2019 20:26:51 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -----Original Message-----
> From: David Hildenbrand <david@redhat.com>
> Sent: Tuesday, 10 September 2019 5:46 PM
> To: Alastair D'Silva <alastair@au1.ibm.com>; alastair@d-silva.org
> Cc: Andrew Morton <akpm@linux-foundation.org>; Oscar Salvador
> <osalvador@suse.com>; Michal Hocko <mhocko@suse.com>; Pavel Tatashin
> <pasha.tatashin@soleen.com>; Wei Yang <richard.weiyang@gmail.com>;
> Dan Williams <dan.j.williams@intel.com>; Qian Cai <cai@lca.pw>; Jason
> Gunthorpe <jgg@ziepe.ca>; Logan Gunthorpe <logang@deltatee.com>; Ira
> Weiny <ira.weiny@intel.com>; linux-mm@kvack.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH 1/2] memory_hotplug: Add a bounds check to
> check_hotplug_memory_range()
>=20
> On 10.09.19 04:52, Alastair D'Silva wrote:
> > From: Alastair D'Silva <alastair@d-silva.org>
> >
> > On PowerPC, the address ranges allocated to OpenCAPI LPC memory are
> > allocated from firmware. These address ranges may be higher than =
what
> > older kernels permit, as we increased the maximum permissable =
address
> > in commit 4ffe713b7587
> > ("powerpc/mm: Increase the max addressable memory to 2PB"). It is
> > possible that the addressable range may change again in the future.
> >
> > In this scenario, we end up with a bogus section returned from
> > __section_nr (see the discussion on the thread "mm: Trigger bug on =
if
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
>=20
> I think using MAX_POSSIBLE_PHYSMEM_BITS bits is wrong. You should use
> MAX_PHYSMEM_BITS.
>=20
> E.g. on x86_64, MAX_POSSIBLE_PHYSMEM_BITS is 52, while
> MAX_PHYSMEM_BITS is (pgtable_l5_enabled() ? 52 : 46) - so
> MAX_PHYSMEM_BITS depends on the actual HW.
>=20

Thanks, I was following the pattern from zsmalloc.c, but what you say =
makes sense.

> > +int check_hotplug_memory_addressable(u64 start, u64 size) { #ifdef
> > +MAX_POSSIBLE_PHYSMEM_BITS
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
> >
>=20
>=20
> --
>=20
> Thanks,
>=20
> David / dhildenb
>=20


--=20
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva     msn: alastair@d-silva.org
blog: http://alastair.d-silva.org    Twitter: @EvilDeece


