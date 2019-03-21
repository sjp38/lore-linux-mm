Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E41BC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 03:12:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B7BE218A5
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 03:12:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="O8Sexf3a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B7BE218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCEE46B0003; Wed, 20 Mar 2019 23:12:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7F9F6B0006; Wed, 20 Mar 2019 23:12:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6E8B6B0007; Wed, 20 Mar 2019 23:12:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 823B06B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 23:12:47 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id i4so2379852otf.3
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 20:12:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hNRCxCN0CPAwwEtkaOPrHmrtVKrkPJRIrqfUj9WvgyM=;
        b=qdjcptDl3ro+EI1aBEEhFouUQVvnJnw9sP9Ch43HdVodBjuo7iQae1b/Swmx/fzCTa
         LbR13DQtY5oBsd+E11hJl2v00cJ3V45Se9BpmYuvMd1/53VLZKT+pqtgvpmb/xIgMmx2
         lTXq2dymQPosDqrY73pOE6BzNB8vmu+QEif5O5o91HeeroehrbSejFIjQ4CP7t4wcW53
         Zy2vPOkZm7W5sKXLDOaSW+DQwy5zYKB0OwKXgHW19YuMJGQdLuVfHMARGFofRYIk3jbJ
         cdV2nmcgLWGBZ8zYiiuEHuZKQCC3+xckiWIfgSg1iNIvqQ7EDT7TBKCxey1AAI76gqLT
         Xzzg==
X-Gm-Message-State: APjAAAXANxSGTPC3VhXCQ65rjhoXCKgX5TtJYwxuVhyE1HLRbKPg469T
	qA6kbnyRDGJLqf6h5+7ZBLjhsSLnzSsYol+M/qZ6U6YIhcunL9JyHvupqKzqxhTJfIL5HRRN5FL
	G7uRWrzi8ukZVdyWNXWBj/bfq1iZU4SJmoCuyyzQCAXOvgbKiUWTb1p8Lk5B5JnHB7g==
X-Received: by 2002:aca:5d0a:: with SMTP id r10mr783457oib.92.1553137967054;
        Wed, 20 Mar 2019 20:12:47 -0700 (PDT)
X-Received: by 2002:aca:5d0a:: with SMTP id r10mr783432oib.92.1553137966176;
        Wed, 20 Mar 2019 20:12:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553137966; cv=none;
        d=google.com; s=arc-20160816;
        b=Dj0rw+lNLn43t8Clivpx4yhY913CEEu7IC2FB6qACjSCdQpqXk9XzMMDSAJH3UnqcG
         dMuomm2AwPW8dNZT5BqMs6VLHaUD1URbg7D+FNB87z+5qHJ9SgbaQX1WnW6wLt3wJ0z8
         UquaKJFv5VXdtYkuGnc59rZ3cBeUbRAa2Roxmf5LmZb7Cm5dW9YRfrWFSkl8+D6ueLyX
         LT1pg5Ot+3HQ7MQnzcR4rX50NvYbTwV988zzrNN0QJ2DdJaQ68TMRYEtp1J0V1d6rpkP
         l3YOyXcaRtGcxCgcc2NlZafiU7Dr63FPZNMhfylzld7Gp7QOecmFGXPsBBfSq42TXpea
         tGSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hNRCxCN0CPAwwEtkaOPrHmrtVKrkPJRIrqfUj9WvgyM=;
        b=sOdTAniUlnXCYLOTN0anedaAc81v6x5Kiq2IAImUFyfh2flhAMUnF672BnUN78KfEw
         kcqgXTYpRGHwDymB7HegALHqe8Zs3VIU+qs4fv1/K7x6rPoCOK+M6838kdlQTNvaae9a
         tdwpKu6X75fd+MTbS49SOf2Hx3SnUfiOPOMgk3lSVSdT9AkH4VOD8pkDpT3C4rBAJmTV
         buRz6x7EBSTy1QxG3lBCFAlMvO+m/S41RcoEh3mpC5nNVgUinuEdetaeRVTz8D7yZAy9
         PvhIKROmFMujra9gdxXJdIhngPPcSTE2ckVOSgZy83nBaSbvwPsqLdHOlbai3GKePrRZ
         h4Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=O8Sexf3a;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s19sor2473736ois.68.2019.03.20.20.12.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 20:12:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=O8Sexf3a;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hNRCxCN0CPAwwEtkaOPrHmrtVKrkPJRIrqfUj9WvgyM=;
        b=O8Sexf3atM7lpmy9ftmXKY6Rq98VWw6kJJHp0jYrLWOxjKwD7nE0qEKAHLQw6tCuKX
         CM3Nvb9Wm0GwBB9S3f2lVuH2umS5O6KixZnJsQyPudc/BqA0kVTOWcwRgBy1XKC0eBiR
         7gsbJROskxVR1QLdM0WLyxbmhIJNcahTso9WIpLFOAEnIk9FmrLxfXAUzdcWujrcRaks
         NApVOGxVkBqnNBpIXs+AdbmuKY/PCohhzkgNnFYt893m1QMRVT0cf+FGjN/q9omQ7D0c
         lRSZuUG8JgbCDVde+5KpKNZ/v/wMiSE5W4hsCzH/hGCaCBNP6w/5MQyi1tNi/IJipRVH
         ysDA==
X-Google-Smtp-Source: APXvYqylwiscCu6ZjtkuX8ZDMdHYFpCCnDQq/QDcOH9L7ss0xpeIBR+ZWTttEz8AazBy4cqY+C3YbuRNm+DG7x8rkms=
X-Received: by 2002:aca:ed88:: with SMTP id l130mr798985oih.70.1553137965862;
 Wed, 20 Mar 2019 20:12:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com> <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com>
 <871s3aqfup.fsf@linux.ibm.com> <CAPcyv4i0SahDP=_ZQV3RG_b5pMkjn-9Cjy7OpY2sm1PxLdO8jA@mail.gmail.com>
 <87bm267ywc.fsf@linux.ibm.com> <878sxa7ys5.fsf@linux.ibm.com>
 <CAPcyv4iuAPg3HWh5e8-Ud3oCrvp5AoFmjOzf4bbA+VLgR7NLFg@mail.gmail.com>
 <CAPcyv4hMzVuOYzy2tTq-my8Z1y+X6Ug-fyObpKTxVU44p5rBZw@mail.gmail.com> <CAOSf1CEZoLw5QqEMTKwiZ+d_qPLp_D9pJZUtnQWMXWpAXOQ2YA@mail.gmail.com>
In-Reply-To: <CAOSf1CEZoLw5QqEMTKwiZ+d_qPLp_D9pJZUtnQWMXWpAXOQ2YA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 20 Mar 2019 20:12:34 -0700
Message-ID: <CAPcyv4hiAE9Y3Jeudr=Ys=eu2gei088xGyTCJGOoz04iUExUfw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: Oliver <oohall@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Jan Kara <jack@suse.cz>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Michael Ellerman <mpe@ellerman.id.au>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Ross Zwisler <zwisler@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 8:09 PM Oliver <oohall@gmail.com> wrote:
>
> On Thu, Mar 21, 2019 at 7:57 AM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Wed, Mar 20, 2019 at 8:34 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > On Wed, Mar 20, 2019 at 1:09 AM Aneesh Kumar K.V
> > > <aneesh.kumar@linux.ibm.com> wrote:
> > > >
> > > > Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com> writes:
> > > >
> > > > > Dan Williams <dan.j.williams@intel.com> writes:
> > > > >
> > > > >>
> > > > >>> Now what will be page size used for mapping vmemmap?
> > > > >>
> > > > >> That's up to the architecture's vmemmap_populate() implementation.
> > > > >>
> > > > >>> Architectures
> > > > >>> possibly will use PMD_SIZE mapping if supported for vmemmap. Now a
> > > > >>> device-dax with struct page in the device will have pfn reserve area aligned
> > > > >>> to PAGE_SIZE with the above example? We can't map that using
> > > > >>> PMD_SIZE page size?
> > > > >>
> > > > >> IIUC, that's a different alignment. Currently that's handled by
> > > > >> padding the reservation area up to a section (128MB on x86) boundary,
> > > > >> but I'm working on patches to allow sub-section sized ranges to be
> > > > >> mapped.
> > > > >
> > > > > I am missing something w.r.t code. The below code align that using nd_pfn->align
> > > > >
> > > > >       if (nd_pfn->mode == PFN_MODE_PMEM) {
> > > > >               unsigned long memmap_size;
> > > > >
> > > > >               /*
> > > > >                * vmemmap_populate_hugepages() allocates the memmap array in
> > > > >                * HPAGE_SIZE chunks.
> > > > >                */
> > > > >               memmap_size = ALIGN(64 * npfns, HPAGE_SIZE);
> > > > >               offset = ALIGN(start + SZ_8K + memmap_size + dax_label_reserve,
> > > > >                               nd_pfn->align) - start;
> > > > >       }
> > > > >
> > > > > IIUC that is finding the offset where to put vmemmap start. And that has
> > > > > to be aligned to the page size with which we may end up mapping vmemmap
> > > > > area right?
> > >
> > > Right, that's the physical offset of where the vmemmap ends, and the
> > > memory to be mapped begins.
> > >
> > > > > Yes we find the npfns by aligning up using PAGES_PER_SECTION. But that
> > > > > is to compute howmany pfns we should map for this pfn dev right?
> > > > >
> > > >
> > > > Also i guess those 4K assumptions there is wrong?
> > >
> > > Yes, I think to support non-4K-PAGE_SIZE systems the 'pfn' metadata
> > > needs to be revved and the PAGE_SIZE needs to be recorded in the
> > > info-block.
> >
> > How often does a system change page-size. Is it fixed or do
> > environment change it from one boot to the next? I'm thinking through
> > the behavior of what do when the recorded PAGE_SIZE in the info-block
> > does not match the current system page size. The simplest option is to
> > just fail the device and require it to be reconfigured. Is that
> > acceptable?
>
> The kernel page size is set at build time and as far as I know every
> distro configures their ppc64(le) kernel for 64K. I've used 4K kernels
> a few times in the past to debug PAGE_SIZE dependent problems, but I'd
> be surprised if anyone is using 4K in production.

Ah, ok.

> Anyway, my view is that using 4K here isn't really a problem since
> it's just the accounting unit of the pfn superblock format. The kernel
> reading form it should understand that and scale it to whatever
> accounting unit it wants to use internally. Currently we don't so that
> should probably be fixed, but that doesn't seem to cause any real
> issues. As far as I can tell the only user of npfns in
> __nvdimm_setup_pfn() whih prints the "number of pfns truncated"
> message.
>
> Am I missing something?

No, I don't think so. The only time it would break is if a system with
64K page size laid down an info-block with not enough reserved
capacity when the page-size is 4K (npfns too small). However, that
sounds like an exceptional case which is why no problems have been
reported to date.

