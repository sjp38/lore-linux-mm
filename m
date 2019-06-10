Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA4ECC28CC7
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:16:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69DBD20679
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:16:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="ToX2hnaP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69DBD20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 157086B026A; Mon, 10 Jun 2019 09:16:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106B66B026B; Mon, 10 Jun 2019 09:16:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE9AA6B026C; Mon, 10 Jun 2019 09:16:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDC166B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:16:57 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id s2so8799958itl.7
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 06:16:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VNk3HOCqwDsrkq+M3DdByXFYq0E8aVmGy+Vn0t1wmaY=;
        b=H+LvW54hgL4+Im6jbnI/LBzu1vEx/Cn0BkjNGX/+KOsHqsBCADlBIna6+Tw2NpaKBC
         Trrz9lXrHhVNwse4tvZCegM20fxPm0o0vdZqV8mSYO1EFoTSl/hRnzNM1jJeGIgzCdck
         raOBmsq4mhFPYJ1HYN11bI/utIx3oAn76OCE/RASYmi+0/vItmjJwQQbROb2F4fZcS4K
         P1Qf8gc46TEGs6SdrdNqOQ3t/U8GPTdHNRGL61UABhl6M+uHOJ3Xh628BHQtd4mlggsS
         PykFVwq5KJxfc4veoBewGRdg3uxyBwf/Zn2KrRXN3Li3+HNr2dWsh9/GZ1DEy8rXH660
         60Pw==
X-Gm-Message-State: APjAAAUIPYdElJBPC+EMLbK421V44wd17PHP7H6a1xh/6aLSoVpVywQ1
	sD+/IchJpeaAPGEYePYJ79CeE6YLSYean5epWiL3OP3DdSiR/+n78vFxNTdnxN87FUP3lkcRUPi
	iLjcJctmugr8uJQ+Wufnlot1X2Ewknu6TZK1PTmisRNd2Qf9oJxm7SV96oCMlyU2/sg==
X-Received: by 2002:a24:9c04:: with SMTP id b4mr14845745ite.141.1560172617501;
        Mon, 10 Jun 2019 06:16:57 -0700 (PDT)
X-Received: by 2002:a24:9c04:: with SMTP id b4mr14845677ite.141.1560172616582;
        Mon, 10 Jun 2019 06:16:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560172616; cv=none;
        d=google.com; s=arc-20160816;
        b=BvGzsN6xdPC97l3tbSjJRePd/XoJXwifktLv0se4n1DjutOtFR7z7Zcfa5YTOV2+Jf
         rcfEtysL3F3ApW/dJOT6XZL3EusrIMjPO1pfOeaFKBVWo+YLylRAeik0iKJmfNRIcc82
         nuLrjAexAbC/gLUM47UlWbfmIPlvCvFcP1SukOQ3flDRjE6FUnXF/UDcqka8eSRBAb4h
         QKwXbgWR4cM80/SDPrlVElqsvfLv4OaMCTvpUP8kZmcZOlcJRcijK1TWjVGBxXiGyA/8
         juQK/ZnXD/SQ+MZvxoaI3XRouMEapKtoGSsfU4JEEFq/636dDe5tTwfQpqLvnNkcWlpe
         Dkdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VNk3HOCqwDsrkq+M3DdByXFYq0E8aVmGy+Vn0t1wmaY=;
        b=PQAas1GxUaUnLPsetKiYSOK4RwMVblDMJE+drfd3FimPv+7IAr52n/cspkcDRXIknn
         qK7eiAynqxz98boWURXWzvf84avDvVVK1iFX9pd/S298WoxIMppZoO4zqMz4YNk27vox
         utkYmAmfwcQn7TWtBcOEmObsutmvXXYVXZ5w8wrnxIleI3NR58sDo9brtZeFPNNyx5aR
         EMRoWMkeyo18+PNnDYRfhyUqghTSDtHxZpj4UOaYUXNZIJJAFYqGPlYAGzuWaKnrcff2
         j10HcCck1vzeDhEZHjboinlEimn6cvksFegCC3urTppIRwtPvKuyTuZCBoxZJMUlaW5S
         TudQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=ToX2hnaP;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l205sor4724508ioa.135.2019.06.10.06.16.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 06:16:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=ToX2hnaP;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VNk3HOCqwDsrkq+M3DdByXFYq0E8aVmGy+Vn0t1wmaY=;
        b=ToX2hnaPH/yjK/yvnjCSobIl6X1PxRHZMTxaYxnc93jtRyxCkM3sfJvZbB3eAFqge5
         z45yC+pgHMwEPckZDsqHcg3+caBoy+JVKU6sBaM7KXnyPck3vnFJCTBeAIu2luYq4rE7
         6jE4cIiKDovZWrh469CXU7kt6U5jlpxxU8KzxA4RSx9XNMVFQTzjfD5PZpFVNN56S/dC
         wfU4+tId3+iEaUkIFgfL12VBZ+n+AqnyyGI/Eri/43BgAjMUircdZ4iNrUmiAACGZ2oD
         UIUXMG9YKUl5xEuoDvNTIlCuEfIufTITNC74w5cX338XdLkR+BuY1t7qATuGZ1QjdeyV
         bZDw==
X-Google-Smtp-Source: APXvYqzarBFbSF1naKHDvaWpGg/Ufru9EOjzFBYFWaY07cg7Q42+dj/GPRcQhIHhjw/DdT+Mn5GafMfhlQuQGHRdbPM=
X-Received: by 2002:a5d:9d83:: with SMTP id 3mr37963127ion.65.1560172616087;
 Mon, 10 Jun 2019 06:16:56 -0700 (PDT)
MIME-Version: 1.0
References: <1534907237-2982-1-git-send-email-jia.he@hxt-semitech.com>
 <CAKv+Gu9u8RcrzSHdgXiqHS9HK1aSrjbPxVUSCP0DT4erAhx0pw@mail.gmail.com>
 <20180907144447.GD12788@arm.com> <84b8e874-2a52-274c-4806-968470e66a08@huawei.com>
In-Reply-To: <84b8e874-2a52-274c-4806-968470e66a08@huawei.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 10 Jun 2019 15:16:43 +0200
Message-ID: <CAKv+Gu9fd2Y7USDYnQdUuYd9L2OD99kU4A1x1JSF442KN96TTA@mail.gmail.com>
Subject: Re: [PATCH v11 0/3] remain and optimize memblock_next_valid_pfn on
 arm and arm64
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Kemi Wang <kemi.wang@intel.com>, 
	Wei Yang <richard.weiyang@gmail.com>, Linux-MM <linux-mm@kvack.org>, 
	Eugeniu Rosca <erosca@de.adit-jv.com>, Petr Tesarik <ptesarik@suse.com>, 
	Nikolay Borisov <nborisov@suse.com>, Russell King <linux@armlinux.org.uk>, 
	Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, 
	Mel Gorman <mgorman@suse.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Laura Abbott <labbott@redhat.com>, Daniel Vacek <neelx@redhat.com>, 
	Vladimir Murzin <vladimir.murzin@arm.com>, Kees Cook <keescook@chromium.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, 
	YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Jia He <jia.he@hxt-semitech.com>, 
	Jia He <hejianet@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Steve Capper <steve.capper@arm.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, James Morse <james.morse@arm.com>, 
	Philip Derrin <philip@cog.systems>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Jun 2019 at 06:22, Hanjun Guo <guohanjun@huawei.com> wrote:
>
> Hi Ard, Will,
>
> This week we were trying to debug an issue of time consuming in mem_init(),
> and leading to this similar solution form Jia He, so I would like to bring this
> thread back, please see my detail test result below.
>
> On 2018/9/7 22:44, Will Deacon wrote:
> > On Thu, Sep 06, 2018 at 01:24:22PM +0200, Ard Biesheuvel wrote:
> >> On 22 August 2018 at 05:07, Jia He <hejianet@gmail.com> wrote:
> >>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> >>> where possible") optimized the loop in memmap_init_zone(). But it causes
> >>> possible panic bug. So Daniel Vacek reverted it later.
> >>>
> >>> But as suggested by Daniel Vacek, it is fine to using memblock to skip
> >>> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
> >>>
> >>> More from what Daniel said:
> >>> "On arm and arm64, memblock is used by default. But generic version of
> >>> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
> >>> not always return the next valid one but skips more resulting in some
> >>> valid frames to be skipped (as if they were invalid). And that's why
> >>> kernel was eventually crashing on some !arm machines."
> >>>
> >>> About the performance consideration:
> >>> As said by James in b92df1de5,
> >>> "I have tested this patch on a virtual model of a Samurai CPU with a
> >>> sparse memory map.  The kernel boot time drops from 109 to 62 seconds."
> >>> Thus it would be better if we remain memblock_next_valid_pfn on arm/arm64.
> >>>
> >>> Besides we can remain memblock_next_valid_pfn, there is still some room
> >>> for improvement. After this set, I can see the time overhead of memmap_init
> >>> is reduced from 27956us to 13537us in my armv8a server(QDF2400 with 96G
> >>> memory, pagesize 64k). I believe arm server will benefit more if memory is
> >>> larger than TBs
> >>>
> >>
> >> OK so we can summarize the benefits of this series as follows:
> >> - boot time on a virtual model of a Samurai CPU drops from 109 to 62 seconds
> >> - boot time on a QDF2400 arm64 server with 96 GB of RAM drops by ~15
> >> *milliseconds*
> >>
> >> Google was not very helpful in figuring out what a Samurai CPU is and
> >> why we should care about the boot time of Linux running on a virtual
> >> model of it, and the 15 ms speedup is not that compelling either.
>
> Testing this patch set on top of Kunpeng 920 based ARM64 server, with
> 384G memory in total, we got the time consuming below
>
>              without this patch set      with this patch set
> mem_init()        13310ms                      1415ms
>
> So we got about 8x speedup on this machine, which is very impressive.
>

Yes, this is impressive. But does it matter in the grand scheme of
things? How much time does this system take to arrive at this point
from power on?

> The time consuming is related the memory DIMM size and where to locate those
> memory DIMMs in the slots. In above case, we are using 16G memory DIMM.
> We also tested 1T memory with 64G size for each memory DIMM on another ARM64
> machine, the time consuming reduced from 20s to 2s (I think it's related to
> firmware implementations).
>

I agree that this optimization looks good in isolation, but the fact
that you spotted a bug justifies my skepticism at the time. On the
other hand, now that we have several independent reports (from you,
but also from the Renesas folks) that the speedup is worthwhile for
real world use cases, I think it does make sense to revisit it.

So what I would like to see is the patch set being proposed again,
with the new data points added for documentation. Also, the commit
logs need to crystal clear about how the meaning of PFN validity
differs between ARM and other architectures, and why the assumptions
that the optimization is based on are guaranteed to hold.



> >>
> >> Apologies to Jia that it took 11 revisions to reach this conclusion,
> >> but in /my/ opinion, tweaking the fragile memblock/pfn handling code
> >> for this reason is totally unjustified, and we're better off
> >> disregarding these patches.
>
> Indeed this patch set has a bug, For exampe, if we have 3 regions which
> is [a, b] [c, d] [e, f] if address of pfn is bigger than the end address of
> last region, we will increase early_region_idx to count of region, which is
> out of bound of the regions. Fixed by patch below,
>
>  mm/memblock.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 8279295..8283bf0 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1252,13 +1252,17 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
>                 if (pfn >= start_pfn && pfn < end_pfn)
>                         return pfn;
>
> -               early_region_idx++;
> +               /* try slow path */
> +               if (++early_region_idx == type->cnt)
> +                       goto slow_path;
> +
>                 next_start_pfn = PFN_DOWN(regions[early_region_idx].base);
>
>                 if (pfn >= end_pfn && pfn <= next_start_pfn)
>                         return next_start_pfn;
>         }
>
> +slow_path:
>         /* slow path, do the binary searching */
>         do {
>                 mid = (right + left) / 2;
>
> As the really impressive speedup on our ARM64 server system, could you reconsider
> this patch set for merge? if you want more data I'm willing to clarify and give
> more test.
>

