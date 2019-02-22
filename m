Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49017C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:25:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF8D1206BA
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:25:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="NHGD06wb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF8D1206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B5BF8E0138; Fri, 22 Feb 2019 16:25:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 764E08E0137; Fri, 22 Feb 2019 16:25:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 653EF8E0138; Fri, 22 Feb 2019 16:25:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35D698E0137
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 16:25:07 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id k69so2162873ywa.12
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:25:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=9karIuIHg1vtBYYf1M4HNuL4qkqDIYWqZ2VdtX6a7DQ=;
        b=tBwpvzWEsCjqVmnhzpPjhx+CoH4o06Y/eiHSwlYK2fhqM7tdyVBopDWQGyQtkiQJF7
         WStXIUuumDo0l26QOYbWfmMMRspqpJsMep8XuUixvVieC9F5903qA/aJDH/IvwbAxG71
         b+lC2QIWCOnJ04CrFZfRSsK2CUYgwE4YMTfYx4RtEsHyqmhBeo/RE5lcqotwAmouUEv7
         M7ruF1+UrVJ27SDVjRPzOIgqmsB+yYi4jKoLQZHOp8Ygl7opw7bA11ADBaPhdUFxcKc5
         sl+8mIcDWudHtopia50944fvkfRcwvIUXRnNZytYUvxvIKYWmogZS+6bK9DLUfLSNOIG
         djgA==
X-Gm-Message-State: AHQUAuYtmyVVwL9yQq2zQmgsTIM4hpxs5T6OCABBEcLpaxC1ATMXMF9F
	cT6b3BFvUjprpK/mQzqdKBh/EXHuSDWt7J6kyT4U5Q0pV1V5iHXr2mvNLEb8aMnTT3E1pjaixOS
	v9pe2hh4fYvoCaVvam90MTI4z7K/Q3qi/csTC/jtoLRE+T0LMC8C+rZo9X1eJ5PbsBw==
X-Received: by 2002:a81:ed2:: with SMTP id 201mr5057568ywo.257.1550870706719;
        Fri, 22 Feb 2019 13:25:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaY2HxmINA8SRgWpFMWfSbqIk3JbHaLd5wkOxrF7JKJDfvYl+ni/COnCXebIhizSWQiuSkx
X-Received: by 2002:a81:ed2:: with SMTP id 201mr5057511ywo.257.1550870705722;
        Fri, 22 Feb 2019 13:25:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550870705; cv=none;
        d=google.com; s=arc-20160816;
        b=BtPNHO5DlMez3rqniBSqrEbhVIz/af3JhQQPYDIYu0LTcqYweKUR+BRhJJ6Jqhemp8
         yNOGUstWIWpVc0xADAInrHr5w4Q3uU9JzfLDQ27Jtcx2LqsFzb12Gmd4CLTbk0+29/U0
         v827HMm9KC60x4K/CBpSQcdGBCOZq9oW3VBhCqtzZIpC/bA7J8ie514N6d2KXLCN8NF7
         0rmOsdygDJxJbXE2laL1OhKXVCS588JjXs4GU9rdo6ZIyejdkfakZN/Uh8+a3cwaPehR
         L+9tpaDExRNqTVoYePR4wW94qSQ9DnItuVCLKmjSis6O1nM//eeKq5Ec7QohRanuIXBb
         ivXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=9karIuIHg1vtBYYf1M4HNuL4qkqDIYWqZ2VdtX6a7DQ=;
        b=Kuvoi3AinMEJBEO3r8M/35gNJDm5lEsgj9oGnpLmn5Fej/G6ZoWsrN00RtjmkJ6E6V
         aje8Y2MRNzfujFHq2+ODcTtwSc7GFnW8qvGIvIR1Tjc0jVR/RN90N6V985kcmKCiRhsQ
         e6bcLSNIQThj8YSoWoEp3/ytIDMwopFulevnDr5hgUnfbf/23Z7w3xOYIILY0aJDoHSj
         8Zw90xqJK+k8mm1gHypL4P6D+b17l0J1Tl7EjgFzeZshq0vW4wH99hGjIJJ3N+m9w9dl
         1IKEFQmsQaRhl25CXhatx91BJw5Od9xjzGy8lV/Vh4d3PalIB+s3ECGnEDpanYS3iqqN
         AmiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NHGD06wb;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id i9si1509616ybk.198.2019.02.22.13.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:25:05 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NHGD06wb;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7068b60000>; Fri, 22 Feb 2019 13:25:10 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 22 Feb 2019 13:25:04 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 22 Feb 2019 13:25:04 -0800
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 21:25:04 +0000
Subject: Re: [PATCH v5 5/9] mm/mmu_notifier: contextual information for event
 triggering invalidation v2
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
 <20190219200430.11130-6-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <ff09d22f-8eb8-ea19-0a65-7f5b38928cea@nvidia.com>
Date: Fri, 22 Feb 2019 13:25:03 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190219200430.11130-6-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550870710; bh=9karIuIHg1vtBYYf1M4HNuL4qkqDIYWqZ2VdtX6a7DQ=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=NHGD06wbFMzk6wx9UJ7KfOSbOHtmisry4usVAC/d5jMIwrQINwkIMVLDHUje0FHQ/
	 tm8t1YP0WB13tAdYQAClqrzZsDpUQH7ViUlKqfVD3GiJGu6gNyDHR/mBFkuKAymwko
	 0wk/aC9Q12UAb7EjawB0lZ/OuNzYbsSbRUUgdshlbsMxrVC8hfWX4vkMsVF1MxOowJ
	 ZoVAOL2P377kVPt6u8k9wu7bV8oI/w2n7e/xQ0WDTaTNna9581oyDRx3agYAWAJDeS
	 lR+6lndK1PDhrfsVuhsuunw/ngZGJSEdrpBVsCzTmA7q2LG6G37DBIg+EyIs7XjAoR
	 P6x4OHlTH5aoA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/19/19 12:04 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> CPU page table update can happens for many reasons, not only as a result
> of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> as a result of kernel activities (memory compression, reclaim, migration,
> ...).
>=20
> Users of mmu notifier API track changes to the CPU page table and take
> specific action for them. While current API only provide range of virtual
> address affected by the change, not why the changes is happening.
>=20
> This patchset do the initial mechanical convertion of all the places that
> calls mmu_notifier_range_init to also provide the default MMU_NOTIFY_UNMA=
P
> event as well as the vma if it is know (most invalidation happens against
> a given vma). Passing down the vma allows the users of mmu notifier to
> inspect the new vma page protection.
>=20
> The MMU_NOTIFY_UNMAP is always the safe default as users of mmu notifier
> should assume that every for the range is going away when that event
> happens. A latter patch do convert mm call path to use a more appropriate
> events for each call.
>=20
> Changes since v1:
>      - add the flags parameter to init range flags
>=20
> This is done as 2 patches so that no call site is forgotten especialy
> as it uses this following coccinelle patch:
>=20
> %<----------------------------------------------------------------------
> @@
> identifier I1, I2, I3, I4;
> @@
> static inline void mmu_notifier_range_init(struct mmu_notifier_range *I1,
> +enum mmu_notifier_event event,
> +unsigned flags,
> +struct vm_area_struct *vma,
> struct mm_struct *I2, unsigned long I3, unsigned long I4) { ... }
>=20
> @@
> @@
> -#define mmu_notifier_range_init(range, mm, start, end)
> +#define mmu_notifier_range_init(range, event, flags, vma, mm, start, end=
)
>=20
> @@
> expression E1, E3, E4;
> identifier I1;
> @@
> <...
> mmu_notifier_range_init(E1,
> +MMU_NOTIFY_UNMAP, 0, I1,
> I1->vm_mm, E3, E4)
> ...>
>=20
> @@
> expression E1, E2, E3, E4;
> identifier FN, VMA;
> @@
> FN(..., struct vm_area_struct *VMA, ...) {
> <...
> mmu_notifier_range_init(E1,
> +MMU_NOTIFY_UNMAP, 0, VMA,
> E2, E3, E4)
> ...> }
>=20
> @@
> expression E1, E2, E3, E4;
> identifier FN, VMA;
> @@
> FN(...) {
> struct vm_area_struct *VMA;
> <...
> mmu_notifier_range_init(E1,
> +MMU_NOTIFY_UNMAP, 0, VMA,
> E2, E3, E4)
> ...> }
>=20
> @@
> expression E1, E2, E3, E4;
> identifier FN;
> @@
> FN(...) {
> <...
> mmu_notifier_range_init(E1,
> +MMU_NOTIFY_UNMAP, 0, NULL,
> E2, E3, E4)
> ...> }
> ---------------------------------------------------------------------->%
>=20
> Applied with:
> spatch --all-includes --sp-file mmu-notifier.spatch fs/proc/task_mmu.c --=
in-place
> spatch --sp-file mmu-notifier.spatch --dir kernel/events/ --in-place
> spatch --sp-file mmu-notifier.spatch --dir mm --in-place
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

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

