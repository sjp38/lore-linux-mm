Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37908C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 15:32:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9A5D214C6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 15:32:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linaro.org header.i=@linaro.org header.b="Nm5ZwGWJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9A5D214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 772EF8E0003; Wed, 26 Dec 2018 10:32:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FA5F8E0001; Wed, 26 Dec 2018 10:32:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C2148E0003; Wed, 26 Dec 2018 10:32:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9EF8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 10:32:12 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id x82so20038980ita.9
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 07:32:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VNidTVK9BknK48wMc2d/FhziRGCtZRNJAoalJxL7/b4=;
        b=DPuiaMEgNUmS9gCtjaPHv6AsxcYbpwuiW6slUIpMZ0BIbffTKT87tgJzbYXaMzLfwD
         horkXTpX0tSWeyem5MhrvuvTIwJ8+tNeM0SzwQJ6Unede6yOsKNCj5p2FFMgLYnKtxu5
         eRl+82rI79ci6BF0zaj8em6mAkzhwMxmOWaQWuMSilCH+wbiokWqQK5ZluLIeCFdyv3/
         liMjOZDCt3Kqc+AfEA7nNxZB1gqdAe3eUZUrFTRLbY6xa8kiRsltH5SlQQLQgHLrwwt0
         jObT22VK2opNzf3zG6yZr8wKNtdJt3bUR/Lx+x+mLmgaJxrD9Z5A0LFV/mN8JXUYQJlK
         8feA==
X-Gm-Message-State: AJcUukf4dSFEcZoKb8VwQ2vHB/jznzjjar+B9U80ITPqmFfSV6yNqdNW
	25cj5d8uIyWs+uM8zeVgnOS5WMvwgAEe1GtTuH/DWAHLss3Zt3zk3KMUEEsLsOGSFdFX29kNDwi
	A3aZ0rianioocYGnWejgAI+CRTrTwzmHR6hN/j1idYJEMb//JBgdPxXqgJxRIV1z+wKA4TlVIvN
	hcCX7UVpiWKVWPJbM6K8fVjethgn6/HPFFz35oTMMFhZlCQAxn1SWRD0IlejLUHxaiHvUJA8vYt
	OQ4vMP4Pk4D2jv2aNvHxH7TGfo3E2yhwETi/xciqY5Y7uV4rW32KEZGrbcJJEzZ+GWU5Oi6k2RL
	TimHvewdkN4aruIlTkJ9dQIuOCWatQckxj8oXzLHwcfGLlfykDoinT4evGIvomw9xNdjG4oqjS0
	H
X-Received: by 2002:a6b:3a89:: with SMTP id h131mr13074308ioa.109.1545838331947;
        Wed, 26 Dec 2018 07:32:11 -0800 (PST)
X-Received: by 2002:a6b:3a89:: with SMTP id h131mr13074260ioa.109.1545838331110;
        Wed, 26 Dec 2018 07:32:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545838331; cv=none;
        d=google.com; s=arc-20160816;
        b=OAa/1TTkNbIZN4TguaU9VFSYX0inWYHa0c7vjP2k4mhGu2LEiHvZE79x2yVLoIEwGl
         wn851/eOvVXwnjnBfs3dhuFdt00Nu8hGL5mhvSQ1LhLIaat6vS2efJi0du1ffPatxe86
         KlqcooPs7LgNPpn6iSTuRq2TQ9YCi7trKMM/iuOfoz1tLKPHK4mNAkSCiLK/rfHz2BwQ
         Ldl6tqbBPHaRGD3fPXkZIKtc3Cei4/8b+sOyUmGlAkLNPEa5zNXZUfai9gcOCFHMVtR9
         z29jMLii7FIygKUEp90DFTsvOt54p8LCB8Q+iw1zs1ye2HHzbPNSp6sn8Ve/LoP/n4Jg
         QHxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VNidTVK9BknK48wMc2d/FhziRGCtZRNJAoalJxL7/b4=;
        b=gbFPvM19NIBrwPx/o65t/EiuQlH3jMAZyz/azKLS/V3k4EXCjUGUeHz8o9AL10Fd/m
         SwDfrU+H7QoDSd4JaRlGpPnYsH9yvQjOq0GvPI44je8CCg1loCV6V3OBjpXFJi+GwI3Q
         karb+y/3LgrgtMYlFjSguilwHlZNnMmDtAggs1oQKBb1tEfagLrXxlGFlMgx9BuEO0s4
         0SEtglGmmd/ja+fVUTFj/VpDe19XKC8hHo2b8B/BgHocN+dgfKDCJMnCXsOIYHoyrKkm
         ocqTyyaKugOyR6M4S6gUP9eNyX31BamgJbugfE7ZCw+bXuTI57Gblbu1l/5w+edUzToM
         lz3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=Nm5ZwGWJ;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h68sor15020524iof.5.2018.12.26.07.32.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Dec 2018 07:32:11 -0800 (PST)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=Nm5ZwGWJ;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VNidTVK9BknK48wMc2d/FhziRGCtZRNJAoalJxL7/b4=;
        b=Nm5ZwGWJMdkqCjEVY+whgnyQ+MTEuI/TPc20xQ+nY6GSGgEmNZusZIG/7FYK4nXKrD
         6rblYMPJpq13TXO9Fx/2aPiAYB5p5RaJVdbwBoJcQ6O53Q9+9yyHIhzSy2CC9BYQdLJF
         nn/Uer+CS8PECw2iNj8l4XJ85zY3S4ounApvM=
X-Google-Smtp-Source: ALg8bN71ryeAV+qhfPw9GFhJo3aKcTrOxuxSO1CaHSSYuptFZmyAyO2hjX80J2gNwnyQQiYLF4gdKSIOIFiZrCgVHME=
X-Received: by 2002:a6b:5d01:: with SMTP id r1mr13163263iob.170.1545838330629;
 Wed, 26 Dec 2018 07:32:10 -0800 (PST)
MIME-Version: 1.0
References: <20181226023534.64048-1-cai@lca.pw> <CAKv+Gu_fiEDffKq_fONBYTOdSk-L7__+LgNEyVaNF3FGzBfAow@mail.gmail.com>
 <403405f1-b702-2feb-4616-35fc3dc3133e@lca.pw>
In-Reply-To: <403405f1-b702-2feb-4616-35fc3dc3133e@lca.pw>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 26 Dec 2018 16:31:59 +0100
Message-ID:
 <CAKv+Gu_e=NkKZ5C+KzBmgg2VMXNKPqXcPON8heRd0F_iW+aaEQ@mail.gmail.com>
Subject: Re: [PATCH -mmotm] efi: drop kmemleak_ignore() for page allocator
To: Qian Cai <cai@lca.pw>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Catalin Marinas <catalin.marinas@arm.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-efi <linux-efi@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226153159.XscFKhWWeaYNTuXG8lhBuibjTm76IZfSZpSNj2I8A4I@z>

On Wed, 26 Dec 2018 at 16:13, Qian Cai <cai@lca.pw> wrote:
>
> On 12/26/18 7:02 AM, Ard Biesheuvel wrote:
> > On Wed, 26 Dec 2018 at 03:35, Qian Cai <cai@lca.pw> wrote:
> >>
> >> a0fc5578f1d (efi: Let kmemleak ignore false positives) is no longer
> >> needed due to efi_mem_reserve_persistent() uses __get_free_page()
> >> instead where kmemelak is not able to track regardless. Otherwise,
> >> kernel reported "kmemleak: Trying to color unknown object at
> >> 0xffff801060ef0000 as Black"
> >>
> >> Signed-off-by: Qian Cai <cai@lca.pw>
> >
> > Why are you sending this to -mmotm?
> >
> > Andrew, please disregard this patch. This is EFI/tip material.
>
> Well, I'd like to primarily develop on the -mmotm tree as it fits in a
> sweet-spot where the mainline is too slow and linux-next is too chaotic.
>
> The bug was reproduced and the patch was tested on -mmotm. If for every bugs
> people found in -mmtom, they have to check out the corresponding sub-system tree
> and reproduce/verify the bug over there, that is quite a burden to bear.
>

Yes. But you know what? We all have our burden to bear, and shifting
this burden to someone else, in this case the subsystem maintainer who
typically deals with a sizable workload already, is not a very nice
thing to do.

> That's why sub-system maintainers are copied on those patches, so they can
> decide to fix directly in the sub-system tree instead of -mmotm, and then it
> will propagate to -mmotm one way or another.
>

Please stop sending EFI patches if you can't be bothered to
test/reproduce against the EFI tree.

Thanks,
Ard.

