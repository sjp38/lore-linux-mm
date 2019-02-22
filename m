Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28542C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:26:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5AA82070B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 19:26:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="fqlXLAeF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5AA82070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DC018E0134; Fri, 22 Feb 2019 14:26:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 489EB8E0123; Fri, 22 Feb 2019 14:26:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 352DB8E0134; Fri, 22 Feb 2019 14:26:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5AC8E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:26:12 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id h73so2062808ybg.8
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:26:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=moXzvZWQOYM4BGU5mDrtuh+EjDOFrbKUSqkEdU832nI=;
        b=FJ5s92Hb9okzg5m05GVAyXmd5PdwKjDF+mEUvpk4m0PUhRWyB46OvQqohXZpuwDwTW
         PKfWgg3NIfg50RAz3/czNbvnvenA47jXUqaGczxBYkyuQtiUnTLt1Wgj4zIlwI8RCCP2
         1XkX+YfLEJ5ORSDBUTfwPrR3RMkJ3klgiBk/VRPBjtrdFYyR3bhk5f0KjcuBslk2gGIK
         90qqDFJR9HXlaPFEBmMIiCTehoKrTuJa/waFa5/tDgUW/2QCH8VCZ7iyvwTG3IpUTkoT
         xmna64MhWyRZTzzHtXrWzUitWWnBcAYYn9zJUN3aWwU3piWLVv1x6kpknzyI/C9ZTAVS
         lo2g==
X-Gm-Message-State: AHQUAubxnUqV3qf5zOYoRqRrQWfw0TUjJv5bQ+8rPVEU2MH/pvhyAZ/a
	VHft1K02ODoQ0E27xEt/uPm72IWC4RkFeSURxPiYnEbZrZnuoK5iq/g9HDgcn8mLryEBU341lLh
	SJZFWvBrTbai5gHyh7NZjPA44yU8sWReWyKzTNZNwwON4AJEBbG09CKkc4WVLmvHvcQ==
X-Received: by 2002:a0d:c683:: with SMTP id i125mr4659473ywd.471.1550863571718;
        Fri, 22 Feb 2019 11:26:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYaJr4vvK1AlKWdG4S/PS4326XRYEqpWrx8HF/S4VV3G+/AixXNS/08Cx31x5uQmS2WEEru
X-Received: by 2002:a0d:c683:: with SMTP id i125mr4659429ywd.471.1550863570981;
        Fri, 22 Feb 2019 11:26:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550863570; cv=none;
        d=google.com; s=arc-20160816;
        b=zG/BGZ+rDr/viAnOaaYVy4bjfYkUzQBd9loffft+AZpI7WRe49JR/Tvdi3FmTQ+NUY
         /dcXVwTFN6chJhyM7EWs4mtSKItVDixR8j/xUWRsmyVtW3zZEdHyXGnm1UNmHTtK4zD0
         4U3z5OjnORRlTYzaoh7iCzBfQrylgvXIq/0I/X3O0OwolwI17lnPHG1h2hLvm4gyZzsg
         8j+9uijD9hE5jPv8b0cOAahYSa3w+LOytZRMqH75He+Hi89YZsWEAbBaZCen7eAd3Sl0
         /XmsYOIWjmxegFRypbj0AX0p28TU1GKFUyKdp1PKwL1KmKxpRruwI154P8s/4y5yLUk5
         NlLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=moXzvZWQOYM4BGU5mDrtuh+EjDOFrbKUSqkEdU832nI=;
        b=uc1rnmvEcDjfVasWsNJ8ynjErlCcYmypbCgiC1Y9yX0Nad3E0cucIbnd9rjRCGG1M0
         dMvy0qMtg+R+nVt382GH41ZXAyMbZPV2emnMK3IcqMupFvF6ZkNjwldtPLKvL8ZMrdBq
         LAmXoe3nU0Z0gIz0frg8eDT5LKlIZ2SAsxuE5rdc/E5Sgp11S8PH+Nvp6hR/IANnU4K7
         WoJHyQt5Nlo0tp1molpd9T3zJ/LjtkA3qyTMCqisq3IYeYmcYewYY9h0Npr4+9vIr/7m
         IKelBiG9lfxPUs1nnFIIngbgQi5qA43uaXQXIyun/9D+1nWz0ABfBrF5ODeIgwzOAxYJ
         IytQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fqlXLAeF;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id c79si1402691ywa.394.2019.02.22.11.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 11:26:10 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fqlXLAeF;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c704cda0000>; Fri, 22 Feb 2019 11:26:18 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 22 Feb 2019 11:26:10 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 22 Feb 2019 11:26:10 -0800
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 19:26:09 +0000
Subject: Re: [PATCH v5 4/9] mm/mmu_notifier: contextual information for event
 enums
To: <jglisse@redhat.com>, <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <linux-kernel@vger.kernel.org>, =?UTF-8?Q?Christian_K=c3=b6nig?=
	<christian.koenig@amd.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, Andrea
 Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, Felix Kuehling
	<Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler
	<zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini
	<pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, John Hubbard <jhubbard@nvidia.com>,
	<kvm@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-rdma@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>
References: <20190219200430.11130-1-jglisse@redhat.com>
 <20190219200430.11130-5-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <49d6489c-31b4-511b-2504-bc7aa5d44673@nvidia.com>
Date: Fri, 22 Feb 2019 11:26:09 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190219200430.11130-5-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550863578; bh=moXzvZWQOYM4BGU5mDrtuh+EjDOFrbKUSqkEdU832nI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=fqlXLAeFhKwY6TP5GVtaWTaO7QF5ITIk6dsvNamSzXK2iReHcI9lZ48Mb//cmCY+/
	 uE9tA19tSn/+Zff+czY5HVk72LmXFOcALM8hJsBblpMTqXmiFrLaj4OApAI0MzsJm5
	 doxUuI5qDGBijzL0lkZ/Ty/4kBR4a+UnNNjo/VipTYUYpmS5u7ZhEK9XQzG8PfMC1l
	 Z5jjm5ohCfsTVOtJSgQmxG2Z3yV1mY5c/3iK80E71ric2ItAwo/93XNgi8M5cRSCxG
	 vEGxe86P2ADW6EFrJFBNO+PFsNeQup4EKbWkuuBPZIWnfPBnjIQOWF+YKbbl3HT7EL
	 gCgol5oBcGR8Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/19/19 12:04 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> CPU page table update can happens for many reasons, not only as a result

s/update/updates
s/happens/happen

> of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> as a result of kernel activities (memory compression, reclaim, migration,
> ...).
>=20
> This patch introduce a set of enums that can be associated with each of

s/introduce/introduces

> the events triggering a mmu notifier. Latter patches take advantages of
> those enum values.

s/advantages/advantage

>=20
>      - UNMAP: munmap() or mremap()
>      - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
>      - PROTECTION_VMA: change in access protections for the range
>      - PROTECTION_PAGE: change in access protections for page in the rang=
e
>      - SOFT_DIRTY: soft dirtyness tracking
>=20

s/dirtyness/dirtiness

> Being able to identify munmap() and mremap() from other reasons why the
> page table is cleared is important to allow user of mmu notifier to
> update their own internal tracking structure accordingly (on munmap or
> mremap it is not longer needed to track range of virtual address as it
> becomes invalid).
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Peter Xu <peterx@redhat.com>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Christian Koenig <christian.koenig@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>   include/linux/mmu_notifier.h | 30 ++++++++++++++++++++++++++++++
>   1 file changed, 30 insertions(+)
>=20
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index c8672c366f67..2386e71ac1b8 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -10,6 +10,36 @@
>   struct mmu_notifier;
>   struct mmu_notifier_ops;
>  =20
> +/**
> + * enum mmu_notifier_event - reason for the mmu notifier callback
> + * @MMU_NOTIFY_UNMAP: either munmap() that unmap the range or a mremap()=
 that
> + * move the range

I would say something about the VMA for the notifier range
is being deleted.
MMU notifier clients can then use this case to remove any policy or
access counts associated with the range.
Just changing the PTE to "no access" as in the CLEAR case
doesn't mean a policy which prefers device private memory
over system memory should be cleared.

> + *
> + * @MMU_NOTIFY_CLEAR: clear page table entry (many reasons for this like
> + * madvise() or replacing a page by another one, ...).
> + *
> + * @MMU_NOTIFY_PROTECTION_VMA: update is due to protection change for th=
e range
> + * ie using the vma access permission (vm_page_prot) to update the whole=
 range
> + * is enough no need to inspect changes to the CPU page table (mprotect(=
)
> + * syscall)
> + *
> + * @MMU_NOTIFY_PROTECTION_PAGE: update is due to change in read/write fl=
ag for
> + * pages in the range so to mirror those changes the user must inspect t=
he CPU
> + * page table (from the end callback).
> + *
> + * @MMU_NOTIFY_SOFT_DIRTY: soft dirty accounting (still same page and sa=
me
> + * access flags). User should soft dirty the page in the end callback to=
 make
> + * sure that anyone relying on soft dirtyness catch pages that might be =
written
> + * through non CPU mappings.
> + */
> +enum mmu_notifier_event {
> +	MMU_NOTIFY_UNMAP =3D 0,
> +	MMU_NOTIFY_CLEAR,
> +	MMU_NOTIFY_PROTECTION_VMA,
> +	MMU_NOTIFY_PROTECTION_PAGE,
> +	MMU_NOTIFY_SOFT_DIRTY,
> +};
> +
>   #ifdef CONFIG_MMU_NOTIFIER
>  =20
>   /*
>=20

