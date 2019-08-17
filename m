Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48E9CC3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 16:59:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05CBC2086C
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 16:59:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="IpKtW8Cq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05CBC2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E9236B0008; Sat, 17 Aug 2019 12:59:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 899AE6B000A; Sat, 17 Aug 2019 12:59:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 787986B000C; Sat, 17 Aug 2019 12:59:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0187.hostedemail.com [216.40.44.187])
	by kanga.kvack.org (Postfix) with ESMTP id 508576B0008
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 12:59:42 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 04A72180AD808
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 16:59:42 +0000 (UTC)
X-FDA: 75832531404.15.trick50_1a493a4670c42
X-HE-Tag: trick50_1a493a4670c42
X-Filterd-Recvd-Size: 7874
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 16:59:40 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id j7so12402246ota.9
        for <linux-mm@kvack.org>; Sat, 17 Aug 2019 09:59:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=4ctyW3Vi5Ibh5x2BY4buy9E2tmdYqlztCCfXF658lFw=;
        b=IpKtW8Cqml+i67WZioOBoS6hJ3Dk8T2l5C48IQHH7rT1sBA07Wda3g+B+J25rzmOed
         9Qx2i000i+5Sq8rRYp2vbAoHZE02XNiTKcz/Au13aqzY9/pa7rFnoBfLd7B9nuB26GLq
         Y+BS4/6zRbLUvO1tOztSOjj4MBm4CQPn594UOZNJLi7bFtGBP1rj9+VwthDzYY8VVyOR
         UjPwA88/cVR/IQrgHEBKjDnQnFfVVKXL+DJl9I8Xuyb3TQxcwwobRlwgCjpm8tFraLxG
         77Qi/VbdlEFve00vn0i/pN1lTppPcFegYQlKHrgYu35UQxOCShgs1a8NfxLtFqTSool1
         L+8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=4ctyW3Vi5Ibh5x2BY4buy9E2tmdYqlztCCfXF658lFw=;
        b=Jp4Wp3m4l3p44+rf1xl1ZtCYVWpXYjE9t+n4XzuWVLSOFiHj+uC8wkLIM2dYZDXeOM
         +7DlqFueGP7Cz5siLY1vM15UItUqVMrgtCH1UpCWmNnhpbO1F9ry1CcbEPiCZ+VV2dDC
         8Km6UdROb747/k4qUDPGeULkLWZ12OcHN0rOVEHdFKY19npPx65PWb3VWQuBqNlthnTJ
         AFrr7YYuM7JUeHIrai6baKqXFO3MtWEsQGy//mm/noesxqhnuHAaeeTBJ6X7Q+HPD8ue
         1q3CNE+FJngZaVdsSCsk81pPPSdHQhPyjIZ4XvzjrsyfhJffHYFrGdalJfnj7DWjjTxU
         fPgg==
X-Gm-Message-State: APjAAAUv+7xAjj4hOePBMunxdiKJuw/Q6jwI16dpI+9ZZNUAIkguvCzb
	a8p5PQ4/eSRRJioInH8QNWi31rSG3W4Hsr9UiAkWLnSv
X-Google-Smtp-Source: APXvYqwHO8+aAVXPABURvgARXdHStxxHwkXAid2VAmlQqyuHa2oaAaLpAIKTgUvAj3/gNFVxCv21xdrPhnmQrGwBvxA=
X-Received: by 2002:a05:6830:1e05:: with SMTP id s5mr11126021otr.247.1566061179762;
 Sat, 17 Aug 2019 09:59:39 -0700 (PDT)
MIME-Version: 1.0
References: <1565991345.8572.28.camel@lca.pw> <CAPcyv4i9VFLSrU75U0gQH6K2sz8AZttqvYidPdDcS7sU2SFaCA@mail.gmail.com>
 <0FB85A78-C2EE-4135-9E0F-D5623CE6EA47@lca.pw> <CAPcyv4h9Y7wSdF+jnNzLDRobnjzLfkGLpJsML2XYLUZZZUPsQA@mail.gmail.com>
 <E7A04694-504D-4FB3-9864-03C2CBA3898E@lca.pw>
In-Reply-To: <E7A04694-504D-4FB3-9864-03C2CBA3898E@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 17 Aug 2019 09:59:27 -0700
Message-ID: <CAPcyv4gofF-Xf0KTLH4EUkxuXdRO3ha-w+GoxgmiW7gOdS2nXQ@mail.gmail.com>
Subject: Re: devm_memremap_pages() triggers a kasan_add_zero_shadow() warning
To: Qian Cai <cai@lca.pw>
Cc: Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	kasan-dev@googlegroups.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 17, 2019 at 4:13 AM Qian Cai <cai@lca.pw> wrote:
>
>
>
> > On Aug 16, 2019, at 11:57 PM, Dan Williams <dan.j.williams@intel.com> w=
rote:
> >
> > On Fri, Aug 16, 2019 at 8:34 PM Qian Cai <cai@lca.pw> wrote:
> >>
> >>
> >>
> >>> On Aug 16, 2019, at 5:48 PM, Dan Williams <dan.j.williams@intel.com> =
wrote:
> >>>
> >>> On Fri, Aug 16, 2019 at 2:36 PM Qian Cai <cai@lca.pw> wrote:
> >>>>
> >>>> Every so often recently, booting Intel CPU server on linux-next trig=
gers this
> >>>> warning. Trying to figure out if  the commit 7cc7867fb061
> >>>> ("mm/devm_memremap_pages: enable sub-section remap") is the culprit =
here.
> >>>>
> >>>> # ./scripts/faddr2line vmlinux devm_memremap_pages+0x894/0xc70
> >>>> devm_memremap_pages+0x894/0xc70:
> >>>> devm_memremap_pages at mm/memremap.c:307
> >>>
> >>> Previously the forced section alignment in devm_memremap_pages() woul=
d
> >>> cause the implementation to never violate the KASAN_SHADOW_SCALE_SIZE
> >>> (12K on x86) constraint.
> >>>
> >>> Can you provide a dump of /proc/iomem? I'm curious what resource is
> >>> triggering such a small alignment granularity.
> >>
> >> This is with memmap=3D4G!4G ,
> >>
> >> # cat /proc/iomem
> > [..]
> >> 100000000-155dfffff : Persistent Memory (legacy)
> >>  100000000-155dfffff : namespace0.0
> >> 155e00000-15982bfff : System RAM
> >>  155e00000-156a00fa0 : Kernel code
> >>  156a00fa1-15765d67f : Kernel data
> >>  157837000-1597fffff : Kernel bss
> >> 15982c000-1ffffffff : Persistent Memory (legacy)
> >> 200000000-87fffffff : System RAM
> >
> > Ok, looks like 4G is bad choice to land the pmem emulation on this
> > system because it collides with where the kernel is deployed and gets
> > broken into tiny pieces that violate kasan's. This is a known problem
> > with memmap=3D. You need to pick an memory range that does not collide
> > with anything else. See:
> >
> >    https://nvdimm.wiki.kernel.org/how_to_choose_the_correct_memmap_kern=
el_parameter_for_pmem_on_your_system
> >
> > ...for more info.
>
> Well, it seems I did exactly follow the information in that link,
>
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093fff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x0000000000094000-0x000000000009ffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000005a7a0fff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x000000005a7a1000-0x000000005b5e0fff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x000000005b5e1000-0x00000000790fefff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x00000000790ff000-0x00000000791fefff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000791ff000-0x000000007b5fefff] ACP=
I NVS
> [    0.000000] BIOS-e820: [mem 0x000000007b5ff000-0x000000007b7fefff] ACP=
I data
> [    0.000000] BIOS-e820: [mem 0x000000007b7ff000-0x000000007b7fffff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x000000007b800000-0x000000008fffffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000087fffffff] usa=
ble
>
> Where 4G is good. Then,
>
> [    0.000000] user-defined physical RAM map:
> [    0.000000] user: [mem 0x0000000000000000-0x0000000000093fff] usable
> [    0.000000] user: [mem 0x0000000000094000-0x000000000009ffff] reserved
> [    0.000000] user: [mem 0x00000000000e0000-0x00000000000fffff] reserved
> [    0.000000] user: [mem 0x0000000000100000-0x000000005a7a0fff] usable
> [    0.000000] user: [mem 0x000000005a7a1000-0x000000005b5e0fff] reserved
> [    0.000000] user: [mem 0x000000005b5e1000-0x00000000790fefff] usable
> [    0.000000] user: [mem 0x00000000790ff000-0x00000000791fefff] reserved
> [    0.000000] user: [mem 0x00000000791ff000-0x000000007b5fefff] ACPI NVS
> [    0.000000] user: [mem 0x000000007b5ff000-0x000000007b7fefff] ACPI dat=
a
> [    0.000000] user: [mem 0x000000007b7ff000-0x000000007b7fffff] usable
> [    0.000000] user: [mem 0x000000007b800000-0x000000008fffffff] reserved
> [    0.000000] user: [mem 0x00000000ff800000-0x00000000ffffffff] reserved
> [    0.000000] user: [mem 0x0000000100000000-0x00000001ffffffff] persiste=
nt (type 12)
> [    0.000000] user: [mem 0x0000000200000000-0x000000087fffffff] usable
>
> The doc did mention that =E2=80=9CThere seems to be an issue with CONFIG_=
KSAN at the moment however.=E2=80=9D
> without more detail though.

Does disabling CONFIG_RANDOMIZE_BASE help? Maybe that workaround has
regressed. Effectively we need to find what is causing the kernel to
sometimes be placed in the middle of a custom reserved memmap=3D range.

