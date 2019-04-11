Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0B17C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 05:41:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2EF8217D4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 05:41:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rh5xwZnp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2EF8217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B9C56B0005; Thu, 11 Apr 2019 01:41:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36B7F6B0006; Thu, 11 Apr 2019 01:41:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 280336B0007; Thu, 11 Apr 2019 01:41:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E56426B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 01:41:34 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n63so3539147pfb.14
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 22:41:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fLMsq6LduXyvQ3MlccSmAAuSnoDwjI6/ufiAHqMmwtk=;
        b=XIQRl0yabkyxOwqIqmOzHqPH/0nkUzEXiXk6q9cdmzHEaxsJeQXljd6scjj1OecgwK
         Z1mmCP3Flq3fXt4T0MJ/sInoNNkPRJrDbUcNavwUtVAAZhAIVLNas+/MmAJVnPBs5a88
         7wS/20OwVgirEbCQtl6h6m/TmaG/iOKV7M9Pcxa3zj13OYQa2r/ZtnLtY8H24+Kay0oq
         ZEKzAo39IddtksFGEqxT6AAV4mWfmnu2khYyuVlaSm4B01MWeYGfXgT15ZLz9FrZ4M+6
         aXbg1xVaS8pw40Uab2sltKqWy7KaW/83+9/DjciRB0z0oyxKjV8PiQipByYLxsKakniX
         MRcA==
X-Gm-Message-State: APjAAAUcp9daK5Srm6EsqKmNGzw3g57bkx3Zee3viasyLUwj783jbZZh
	A6QooieAdPCnX6qN5X4fgP9kOZWnH1jbtEZYgc4jEF52ZwiWAACXoDpddDhsiY6UQVsv7cg3VvW
	8NR7tecP8N9BMZSGX3fNsk4OECWYpDP6GE5vAIvA0uESfR9w2+PDBAQfDjhxt4zBbDQ==
X-Received: by 2002:a62:b40b:: with SMTP id h11mr48204386pfn.133.1554961294531;
        Wed, 10 Apr 2019 22:41:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrQu5xxoHiwEZ8jWYTqVefhqima7Ix0novdqh482nSiWEtR8dsK42383rPboJ7071c7+NW
X-Received: by 2002:a62:b40b:: with SMTP id h11mr48204332pfn.133.1554961293537;
        Wed, 10 Apr 2019 22:41:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554961293; cv=none;
        d=google.com; s=arc-20160816;
        b=Ta8kmRIv5cxRlCHEBw08lMYEOaC4ka+AjjJrZrmdkyH4e2rMQvukh3xYf408w9QOsU
         jIlD3rJhTWLOA1NEnJRf8LxSBD5vo2VZbG20aKHBYsv5LZFwKOi3LUPGSIDyMeiYqzlh
         XvZkJC8lpovpAmM3GAaOBaMTA6FLt5T0gG7p9/RA827+HxXJn2ybAKByM/GISEqBRovG
         T//PRQsVhPjbYNMVzrG4NhyVQyoRsJg8tRJphcSxTb/wiiK8FhNzuRvgpF4J93eCavLQ
         VvYyCkNMKki04qHO+/Tpp0GdQQ6cGrDg7KLjdnOUl6ZhLDT6SBuNnscIzU+uuaJq1Eut
         V/dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fLMsq6LduXyvQ3MlccSmAAuSnoDwjI6/ufiAHqMmwtk=;
        b=CQmIKIJkl7XX7dp6qksfRbW/NQAayWE5qmsmiBlDq2htcdwQNPiyKoIEgRPakp7fRJ
         W1l1xBOMYv1oK2psv288BZDGfDMqP/moDEX2DGPMKjVS4D6tCFB06W5K4rN0MoCE9JNn
         9uDx7OYtdrQcfLo2rl0gDRqo7phmZU0+2qgRjvdegO+0rD/fdjn0zuWyvwmSaEum+EqU
         FgRVuUIz0+Bm268UVhsUXt3KYxl4yDwiJSpHaiTaItHIu7cRmEdSae3LQeKDP6Wm7q1R
         8gaBGnf/3ksUGmchxerrBVZP46Tv678SYlWxeT4PYAn/6hwdl0pIMwumNgyJTHPRZkV4
         tGQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rh5xwZnp;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 34si5986432plf.288.2019.04.10.22.41.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 22:41:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rh5xwZnp;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [193.47.165.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 77CE72133D;
	Thu, 11 Apr 2019 05:41:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554961293;
	bh=AdnMGIM+zhpk/AkMMfHhD20tBsmxleW3asrU9KtW8Gc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=rh5xwZnp5NtzdWY12ZClWowEtz2If+pz5H1YPGtq5iAN4hd9v2j5LBMyN4hDRcC2B
	 KEkPhf+wxZis6qATkiruJu7Kvh+SOqmhTu52iEOjdqAcCYRSUKChGI/RZP2hKAfwx7
	 vTKjBisVFCSA38vNvsD6cN8iNJ25yiU8dgzw4Zdg=
Date: Thu, 11 Apr 2019 08:41:30 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: jglisse@redhat.com, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v6 7/8] mm/mmu_notifier: pass down vma and reasons why
 mmu notifier is happening v2
Message-ID: <20190411054130.GY3201@mtr-leonro.mtl.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
 <20190326164747.24405-8-jglisse@redhat.com>
 <20190410234124.GE22989@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DoqoDKVG8/W9HA34"
Content-Disposition: inline
In-Reply-To: <20190410234124.GE22989@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--DoqoDKVG8/W9HA34
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 10, 2019 at 04:41:57PM -0700, Ira Weiny wrote:
> On Tue, Mar 26, 2019 at 12:47:46PM -0400, Jerome Glisse wrote:
> > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> >
> > CPU page table update can happens for many reasons, not only as a result
> > of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> > as a result of kernel activities (memory compression, reclaim, migratio=
n,
> > ...).
> >
> > Users of mmu notifier API track changes to the CPU page table and take
> > specific action for them. While current API only provide range of virtu=
al
> > address affected by the change, not why the changes is happening
> >
> > This patch is just passing down the new informations by adding it to the
> > mmu_notifier_range structure.
> >
> > Changes since v1:
> >     - Initialize flags field from mmu_notifier_range_init() arguments
> >
> > Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: linux-mm@kvack.org
> > Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> > Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> > Cc: Jani Nikula <jani.nikula@linux.intel.com>
> > Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Peter Xu <peterx@redhat.com>
> > Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > Cc: Ross Zwisler <zwisler@kernel.org>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Paolo Bonzini <pbonzini@redhat.com>
> > Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Christian Koenig <christian.koenig@amd.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: kvm@vger.kernel.org
> > Cc: dri-devel@lists.freedesktop.org
> > Cc: linux-rdma@vger.kernel.org
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  include/linux/mmu_notifier.h | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> > index 62f94cd85455..0379956fff23 100644
> > --- a/include/linux/mmu_notifier.h
> > +++ b/include/linux/mmu_notifier.h
> > @@ -58,10 +58,12 @@ struct mmu_notifier_mm {
> >  #define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
> >
> >  struct mmu_notifier_range {
> > +	struct vm_area_struct *vma;
> >  	struct mm_struct *mm;
> >  	unsigned long start;
> >  	unsigned long end;
> >  	unsigned flags;
> > +	enum mmu_notifier_event event;
> >  };
> >
> >  struct mmu_notifier_ops {
> > @@ -363,10 +365,12 @@ static inline void mmu_notifier_range_init(struct=
 mmu_notifier_range *range,
> >  					   unsigned long start,
> >  					   unsigned long end)
> >  {
> > +	range->vma =3D vma;
> > +	range->event =3D event;
> >  	range->mm =3D mm;
> >  	range->start =3D start;
> >  	range->end =3D end;
> > -	range->flags =3D 0;
> > +	range->flags =3D flags;
>
> Which of the "user patch sets" uses the new flags?
>
> I'm not seeing that user yet.  In general I don't see anything wrong with=
 the
> series and I like the idea of telling drivers why the invalidate has fire=
d.
>
> But is the flags a future feature?

It seems that it is used in HMM ODP patch.
https://patchwork.kernel.org/patch/10894281/

Thanks

>
> For the series:
>
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
>
> Ira
>
> >  }
> >
> >  #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
> > --
> > 2.20.1
> >

--DoqoDKVG8/W9HA34
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJcrtOKAAoJEORje4g2clin4zsP/AmYfZt5oiQTeSP4Xjgwykq0
CzkUmZpJm/vc8F5iiy8PVa00rdya2SH+kRF4wx01H0qC4YfOwxuQTDAekUbrMeHM
huKKVZbzds16MerDumdudWGmW+u2m9Qmt1MoDp7zcZ6kLHCtnQ3y905427D/M4yu
MdQd0LVxa05sk2Tb1D8krE9NkrHMR6nEGfHXE9AE3eSQf9WfqFjFHXGfvxDRylDR
XW/sjkdogpVrONpQ/ZbCPFroOoZS98CLfU894RO9DB/d7kTtWFiSsj3Uh+QR1p64
JWsVhxIERsBYE5PeJ6Y3amF0IXJi8SqiKxIAgi9Qs2xmBIbZBIUP0Snk982qLKzg
Arr7ShCqlg3Zuecwho9onbe3epsZkH9gdLqUqEOe8LXXlRGZ7GVmI6tkNg09SXNY
g7EsDhTMZ8qKGmpzel1qIK/o63ushKp+gtIrBxDLWBF6x61BIni1BkeJdxeKuB/3
OIoN1uETEA10OBIuCT4nH4t5S43CnaGx7B4gN8AY501XXjdeTMUmweO1bRhlwfaX
Ty/xN767bs3Jm9rFjBtAFpx9KYcUc+dOLQESqHvXDk8dL1A2ptljOBLqExzxdSqT
euS5qt4NsdH1vnhJRBFdhGKaIW9DG/t3s0mNKeP1nC62BGbdCfN7hZrKjetGhNxI
JppWRIdYbztvSoppOAp/
=pROR
-----END PGP SIGNATURE-----

--DoqoDKVG8/W9HA34--

