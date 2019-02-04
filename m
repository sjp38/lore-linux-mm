Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9B0BC4151A
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 14:38:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DD032083B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 14:38:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=bofh-nu.20150623.gappssmtp.com header.i=@bofh-nu.20150623.gappssmtp.com header.b="gR/zZavk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DD032083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bofh.nu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECBDD8E0047; Mon,  4 Feb 2019 09:38:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7AAB8E001C; Mon,  4 Feb 2019 09:38:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D91F08E0047; Mon,  4 Feb 2019 09:38:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id B0B548E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 09:38:29 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id m52so39654otc.13
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 06:38:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hE4P+KtbkIDEo8Lq8LirA+lBCYJX0HyoYvS1ea+soVo=;
        b=c3XG0RDFylV3rksudbq0TI6oGOFufIKTNFc/+eCTKm7lWrU8y8K2Wff22U8o6RVabn
         BFSIHgSb5+n2/clqPOdZNvJOnmmV5I0nqXtaKaN8CTUZjwPfS6FDwGR5RzHCjUSqS3EZ
         jtrNnC+8+YUMKPyBZr9b2x6dk4co0/DC5HqZWGPMSm7VhIVZPWYbnCuCJQZ1/puoqOIl
         OwIsk1JR8pHI9jlXufPNRQlH/EF6Bjfnnwk9kL2VChkhBw5SMEnEw+ZewOMgrumlezVP
         R/RimYda9lMD3bdwR2/FOTHvO37iHda5p1wLtygawHDt7JLPVpln0OXBkVFXC99odUZg
         nbdg==
X-Gm-Message-State: AHQUAuaf5068mSf28ifycF+gH5jXnE5YhcrGxFDM+I+7NPgyEmhf8LbI
	S8gLZJVa8LkrHD3ENLIFDZMrgsQEinkNWAoNqwfxc3XCWN5bY8XsYTAbVwyZRBT6mXP9AyGCl+G
	KNBh2KT+E6n6phQY7F4W6ZF6AT5Z0Aaz0gmNPRSbvIp9Kpr0ec8eTi+WVC9BE7ZE+comtcKoW4q
	C1O/AdkknFl0PzFDHq0H4QUmFM1yu1PCpcUrmMzkKLVF/PjP0GWda6u/eOxr/ItIKx7o3i2uTyj
	uZJgWZqA/liz5hb35LtoKdYCWofpMhdwBgb4kvkNI45vDMRVUTaVLUO1nnQnQJXKaqeVwJaVinu
	k8vSy6PcMJ9s30wbpnzYo+U9M0ULi+I2D10UWOuZfwyEcLlVil0FosPmoC5CMfrJcMM/+QcveKV
	e
X-Received: by 2002:a54:4393:: with SMTP id u19mr24926657oiv.99.1549291109294;
        Mon, 04 Feb 2019 06:38:29 -0800 (PST)
X-Received: by 2002:a54:4393:: with SMTP id u19mr24926608oiv.99.1549291107960;
        Mon, 04 Feb 2019 06:38:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549291107; cv=none;
        d=google.com; s=arc-20160816;
        b=xiNWIT5BDl5xrv67A2YBQ7VhFvRjOKLxo3RDFmeLuTRZd+R5vTHH6ghVJDZVUhj7cw
         TuKdWQ/CLTF0AQgkjFFo7gKvNnITrd6Qbh1F8vda8QolaYnmSmtTkQVM1lU4cAtti4Nh
         JGytBGN7APgS2NbE+iux1zmhjJ3AGy25k3FPltYqAt+G382GuOk6RlMt+2+gmgM8VNlu
         K3TeCcBCJnvLa4F0L8MVwV/vsXN53kU1gg9vKQn5pDuiVbirpgB3G1WTmzBp7HJLDrVd
         q6R8hhQcvjNzPsaIaFt+9ygoja+4PraH6PGxCz+64wU+yeB8ToTNTHauCQnIygglFaXr
         WjOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hE4P+KtbkIDEo8Lq8LirA+lBCYJX0HyoYvS1ea+soVo=;
        b=IHDj0GDhAe2R4H2tcbYiZRc0f4zOh9D0U4HC7tlSSHD4CedHGq+O3I10DV6wMhQaHa
         srHT9Jr7DgqJkFpK9NEjLdjO/FyRJxa3gXgXm62CQ2eaxtaRnXsBvzKZfKCj05LcAHtu
         IDJpoaHrc6/16fEvwN6xuRwhYjTu5RAks2NQzvCFLhcWQDfxkgWeOpuodLqk3WGOx73M
         nghea6PqQ6Bn9wnrfnFil1soqZ2OhkNeoGy6+Ffq/1yWe5EcutcuHOQMoms2g96Jmj08
         C+QUpTxBv6yW+wNgeb3IcSAQ+RYRKK9p9KHZde8qQ41Pmpy0Ac+eWHq+84vdRttwlv1C
         018A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@bofh-nu.20150623.gappssmtp.com header.s=20150623 header.b="gR/zZavk";
       spf=pass (google.com: domain of lists@bofh.nu designates 209.85.220.65 as permitted sender) smtp.mailfrom=lists@bofh.nu
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v16sor11623425oth.145.2019.02.04.06.38.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 06:38:27 -0800 (PST)
Received-SPF: pass (google.com: domain of lists@bofh.nu designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@bofh-nu.20150623.gappssmtp.com header.s=20150623 header.b="gR/zZavk";
       spf=pass (google.com: domain of lists@bofh.nu designates 209.85.220.65 as permitted sender) smtp.mailfrom=lists@bofh.nu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bofh-nu.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hE4P+KtbkIDEo8Lq8LirA+lBCYJX0HyoYvS1ea+soVo=;
        b=gR/zZavk3CYa4DG+Ph3OjsiOWR7TLgXCMFT4CmXfn2xyMbzSDl01rXjLTDmotJVr3Y
         jLQECb2aQLuL5PEvld4Khkq/T9BmZjbqCTpHIH+sajbTZXjc9vO06gVdAFbyL9YbzEV2
         OKXD98b7dmLfmW7/W6moS1XkS8RkcWEU30akRoZqggEkFMd1HIHNxKfyMOMq4tDuInjr
         TK3G4vXUkuWCL7ajhGQphRXXbAkrsi9C/hHPd7nqnsXKOQ3dE75MdpUiXp/6jBO1ohBM
         IxJXbiYW6iqt8df6Gi/+7/N0J+gzbiqhFdMcloI8pLeiVspBHeIosJYf9hXv78lQKUgK
         O9HQ==
X-Google-Smtp-Source: ALg8bN5KquqFlYTgdJC/ellz83ijzDv/em8YEw1FVNV8LvRiqMW03VSTlb5X+p+9a2MOdkcGENiQmXRdq1ATZTpccH0=
X-Received: by 2002:a9d:2186:: with SMTP id s6mr39476545otb.346.1549291107471;
 Mon, 04 Feb 2019 06:38:27 -0800 (PST)
MIME-Version: 1.0
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
 <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
In-Reply-To: <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
From: Lars Persson <lists@bofh.nu>
Date: Mon, 4 Feb 2019 15:38:16 +0100
Message-ID: <CADnJP=vsum7_YYWBpknpahTQFAzm7G40_E2dLMB_poFEhPKEfw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: page_mapped: don't assume compound page is huge or THP
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, lersek@redhat.com, alex.williamson@redhat.com, 
	aarcange@redhat.com, rientjes@google.com, kirill@shutemov.name, 
	mgorman@techsingularity.net, mhocko@suse.com, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 30, 2018 at 1:07 PM Jan Stancek <jstancek@redhat.com> wrote:
>
> LTP proc01 testcase has been observed to rarely trigger crashes
> on arm64:
>     page_mapped+0x78/0xb4
>     stable_page_flags+0x27c/0x338
>     kpageflags_read+0xfc/0x164
>     proc_reg_read+0x7c/0xb8
>     __vfs_read+0x58/0x178
>     vfs_read+0x90/0x14c
>     SyS_read+0x60/0xc0
>
> Issue is that page_mapped() assumes that if compound page is not
> huge, then it must be THP. But if this is 'normal' compound page
> (COMPOUND_PAGE_DTOR), then following loop can keep running
> (for HPAGE_PMD_NR iterations) until it tries to read from memory
> that isn't mapped and triggers a panic:
>         for (i = 0; i < hpage_nr_pages(page); i++) {
>                 if (atomic_read(&page[i]._mapcount) >= 0)
>                         return true;
>         }
>
> I could replicate this on x86 (v4.20-rc4-98-g60b548237fed) only
> with a custom kernel module [1] which:
> - allocates compound page (PAGEC) of order 1
> - allocates 2 normal pages (COPY), which are initialized to 0xff
>   (to satisfy _mapcount >= 0)
> - 2 PAGEC page structs are copied to address of first COPY page
> - second page of COPY is marked as not present
> - call to page_mapped(COPY) now triggers fault on access to 2nd
>   COPY page at offset 0x30 (_mapcount)
>
> [1] https://github.com/jstancek/reproducers/blob/master/kernel/page_mapped_crash/repro.c
>
> Fix the loop to iterate for "1 << compound_order" pages.
>
> Debugged-by: Laszlo Ersek <lersek@redhat.com>
> Suggested-by: "Kirill A. Shutemov" <kirill@shutemov.name>
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> ---
>  mm/util.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Changes in v2:
> - change the loop instead so we check also mapcount of subpages
>
> diff --git a/mm/util.c b/mm/util.c
> index 8bf08b5b5760..5c9c7359ee8a 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -478,7 +478,7 @@ bool page_mapped(struct page *page)
>                 return true;
>         if (PageHuge(page))
>                 return false;
> -       for (i = 0; i < hpage_nr_pages(page); i++) {
> +       for (i = 0; i < (1 << compound_order(page)); i++) {
>                 if (atomic_read(&page[i]._mapcount) >= 0)
>                         return true;
>         }
> --
> 1.8.3.1

Hi all

This patch landed in the 4.9-stable tree starting from 4.9.151 and it
broke our MIPS1004kc system with CONFIG_HIGHMEM=y.

The breakage consists of random processes dying with SIGILL or SIGSEGV
when we stress test the system with high memory pressure and explicit
memory compaction requested through /proc/sys/vm/compact_memory.
Reverting this patch fixes the crashes.

We can put some effort on debugging if there are no obvious
explanations for this. Keep in mind that this is 32-bit system with
HIGHMEM.

BR,
 Lars

