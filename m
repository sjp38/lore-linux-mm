Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15060C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B883E2077C
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:54:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="FWABCsfc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B883E2077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56F946B0005; Wed, 24 Apr 2019 15:54:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 520156B0006; Wed, 24 Apr 2019 15:54:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 437376B0007; Wed, 24 Apr 2019 15:54:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E90486B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:54:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o8so10476830edh.12
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:54:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NoQw6rZ1McAuWA48g8wjk6m9xf3EqIUgssJwMcJF7eQ=;
        b=iBwfoVi3s2o+ipt9qUH4bDGLg33P6Q0AsQCYrlHU9LXqFWp/8oGkT/aB0XM6+54fWT
         SZjZX+u4Lj0KBIyg1ElXYjwTbfjNBmUi5FiLyq7cBTZZIKVEMu7Pq4bXz+Rp5UL62WT7
         VFVCfShdpfqIrBuM1A8JR+o85puIDS/YMODgSmUteWoa5GARCm97faCcDOp2h9B1fihM
         JpumuetTHtBu9SoOOAJAiT2UxdIAtrI/pMRWuR0D7GynG+Yshf2gJ1AwCsORq8XT6yqV
         VfNrtNuBEzfO1lcvAUAh8dibrg3q0wlrnc5zRY2eSQO+QwxXrnzepPOSP75VyL1GHwt8
         41/g==
X-Gm-Message-State: APjAAAU+RmiWQU7VgSFaIBeDpktXZ79yT/U3KUYLRWJAiaLYb8nsEmOu
	q5fzUeoNi7bfjreq82fGvgTvIDujiU9/O6IIWgtFp4JzI0NivoQe/V2P+VrmFKaKZOkTdnGK0Qf
	29T1c5fT1Ac4t33b+nW4MyeXtOoiJmrVOyjoTRa4Rlv0xFIj5VpM5OqVWFpXOYzhB9g==
X-Received: by 2002:aa7:d899:: with SMTP id u25mr22213639edq.219.1556135678457;
        Wed, 24 Apr 2019 12:54:38 -0700 (PDT)
X-Received: by 2002:aa7:d899:: with SMTP id u25mr22213602edq.219.1556135677623;
        Wed, 24 Apr 2019 12:54:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556135677; cv=none;
        d=google.com; s=arc-20160816;
        b=Sk49YLbxMtDo+DX+AZi8ZLDMbvL1prpujZihVe/nS8nsCKLcAfna9xmANsraiS2gkP
         vbbT6qyCy5dKSBprrGEkJCg+SxL6DWp9CrEnHg9gRNQSphpv1/SvUGs+DbeKTP/aYUbi
         D05t3Y4JWkJfJXJ/z/LXRLW/9zihpmg8Iyas2togy1FMFJOj//AuAYjrjwAiUDCeYLIq
         rB+fQ9uXYSaWmxTCo8EopN6DwQIQQXz3kti755OP55THDLDV9srOvLeumoU5fWUAE6Fj
         aC7WYYTMrQgC0JcHfiJHF0xkyoMa7knI9p6dfwXlhS/2TuwO8OfKpmCemIg6wTY978Ml
         kjFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NoQw6rZ1McAuWA48g8wjk6m9xf3EqIUgssJwMcJF7eQ=;
        b=W0GDfnKdIRaYj6Mk44tZdfeHXlgzidGvQTZ1unGG2iuowrwCGK7UOtTo+jgd+YVMfB
         qHo10gG9JLL2PIihPm8GIJfJEBc7/SLdUBgnC/DTww2vWnCJeyyzR5Y0zDeXqK/oFgUj
         TM48XP/2Qlgj5MKUBLhxBbK9rdprnyxx/jkZFskzl3ud1iyryD+XLD1cWhMy7pywOCZ/
         0W9j3fF/kMT5gK4aQZuoPBXCw427GgpuZ3IwG5dPHy6ujijy9Mb1DnNaHvCxgbnz5htr
         r4a+7abhNwQdcvsW+sN4QlVpi9z8A3h9CDSXbLy9w12iI3noUR8FHH4+RoPEzoBkUaBP
         5gMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=FWABCsfc;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t35sor6969778edd.10.2019.04.24.12.54.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 12:54:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=FWABCsfc;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NoQw6rZ1McAuWA48g8wjk6m9xf3EqIUgssJwMcJF7eQ=;
        b=FWABCsfcDUGiyw2AJKt7/tqGtquTmKrMJwtTDm1UIkIn8sIiysQkYo7zN6jnpoWRJu
         n8Epr+xkic8xVfW6yServfaij14CAu17uMVbu7rd2T7Vvbprewku9FXUATHZnBIVdbY7
         45QxR360C3F9+Ll07NAgZN33BbNEPdTtrzen1OEp9crUlA0msc8afRtjDxrK7nKLmdOK
         bUiuaaAovpjYhEllJzUhXyfQKylPL4N42gNnURUhDynBR3JpC+Rv9eTXRWEp4eZSXHeL
         4c0w7t8Io4Lqq7Ip/pH4e98jRSL8a0IXICT1C8XkWF01hWJej9QkvoWCQ57PBfig9XLC
         Dh2g==
X-Google-Smtp-Source: APXvYqwIKfB190CTRW4eiQZHchohbyuWQ9ao6ccKR/jzQFiEa1MtpZ8e5nsTiBNSRhDrst2+6ow+bgf4eCZZRpTH1gk=
X-Received: by 2002:aa7:cf8f:: with SMTP id z15mr18858819edx.190.1556135677145;
 Wed, 24 Apr 2019 12:54:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
 <7f7499bd-8d48-945b-6d69-60685a02c8da@arm.com> <CA+CK2bCD11x64pJj5gSnsu5jsUqJyU6o+=J4K8oYAsHqz9ULqQ@mail.gmail.com>
In-Reply-To: <CA+CK2bCD11x64pJj5gSnsu5jsUqJyU6o+=J4K8oYAsHqz9ULqQ@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Wed, 24 Apr 2019 15:54:26 -0400
Message-ID: <CA+CK2bB5ahqLrekkTUSdzTE2BPSPbB9nk6nKs+LjTap2oF8X-w@mail.gmail.com>
Subject: Re: [PATCH] arm64: configurable sparsemem section size
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	catalin.marinas@arm.com, Will Deacon <will.deacon@arm.com>, rppt@linux.vnet.ibm.com, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, andrew.murray@arm.com, james.morse@arm.com, 
	Marc Zyngier <marc.zyngier@arm.com>, sboyd@kernel.org, 
	linux-arm-kernel@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

<resending> from original email

On Wed, Apr 24, 2019 at 3:48 PM Pavel Tatashin
<patatash@linux.microsoft.com> wrote:
>
> On Wed, Apr 24, 2019 at 5:07 AM Anshuman Khandual
> <anshuman.khandual@arm.com> wrote:
> >
> > On 04/24/2019 02:08 AM, Pavel Tatashin wrote:
> > > sparsemem section size determines the maximum size and alignment that
> > > is allowed to offline/online memory block. The bigger the size the less
> > > the clutter in /sys/devices/system/memory/*. On the other hand, however,
> > > there is less flexability in what granules of memory can be added and
> > > removed.
> >
> > Is there any scenario where less than a 1GB needs to be added on arm64 ?
>
> Yes, DAX hotplug loses 1G of memory without allowing smaller sections.
> Machines on which we are going to be using this functionality have 8G
> of System RAM, therefore losing 1G is a big problem.
>
> For details about using scenario see this cover letter:
> https://lore.kernel.org/lkml/20190421014429.31206-1-pasha.tatashin@soleen.com/
>
> >
> > >
> > > Recently, it was enabled in Linux to hotadd persistent memory that
> > > can be either real NV device, or reserved from regular System RAM
> > > and has identity of devdax.
> >
> > devdax (even ZONE_DEVICE) support has not been enabled on arm64 yet.
>
> Correct, I use your patches to enable ZONE_DEVICE, and  thus devdax on ARM64:
> https://lore.kernel.org/lkml/1554265806-11501-1-git-send-email-anshuman.khandual@arm.com/
>
> >
> > >
> > > The problem is that because ARM64's section size is 1G, and devdax must
> > > have 2M label section, the first 1G is always missed when device is
> > > attached, because it is not 1G aligned.
> >
> > devdax has to be 2M aligned ? Does Linux enforce that right now ?
>
> Unfortunately, there is no way around this. Part of the memory can be
> reserved as persistent memory via device tree.
>         memory@40000000 {
>                 device_type = "memory";
>                 reg = < 0x00000000 0x40000000
>                         0x00000002 0x00000000 >;
>         };
>
>         pmem@1c0000000 {
>                 compatible = "pmem-region";
>                 reg = <0x00000001 0xc0000000
>                        0x00000000 0x80000000>;
>                 volatile;
>                 numa-node-id = <0>;
>         };
>
> So, while pmem is section aligned, as it should be, the dax device is
> going to be pmem start address + label size, which is 2M. The actual
> DAX device starts at:
> 0x1c0000000 + 2M.
>
> Because section size is 1G, the hotplug will able to add only memory
> starting from
> 0x1c0000000 + 1G
>
> > 27 and 28 do not even compile for ARM64_64_PAGES because of MAX_ORDER and
> > SECTION_SIZE mismatch.
>
> Can you please elaborate what configs are you using? I have no
> problems compiling with 27 and 28 bit.
>
> Thank you,
> Pasha

