Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33B4EC10F05
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 03:09:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E876D206BA
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 03:09:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O0DV7ewk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E876D206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CA026B0003; Wed, 20 Mar 2019 23:09:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77B126B0006; Wed, 20 Mar 2019 23:09:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 667A66B0007; Wed, 20 Mar 2019 23:09:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 406336B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 23:09:00 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id e124so1259962ita.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 20:09:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=krQUPeEhUeWHXrLxX44ZwDfZs9HTeNysg+aRzRJo4mk=;
        b=eW/CZG3eHxJ7MMYAf/xV7beqLyKh2wCiymcO0CjR9KtC1y6ZSeqLaI45hvCuePPIoe
         MaGQ0OOvmH2hwM+O+yh1t5PVjtwWc85bjxHh6v8LE9TK+SfWmL3krfWErlpBDIHSvYPS
         9Wlkw6ajNFq9bdjxvM1aQl6tHHjWHVKAA6rhln95TxGAGf5+Xn3yAtvoNsXTGP/D1sID
         SQJLTjzqXlZjUIN2v93xD1sQgf5I7HsXOUNqXUoqRV6EvtWcUQqQV2vkis9LzjnYIQ+l
         h3hJHXTGuQi6xuH8Ljv67EzHlKvhA01o1SIKipPX8JT6EvjyalDyPe1eTe6exQhN2jRm
         2Nmw==
X-Gm-Message-State: APjAAAVVJSs/jlFXQbOjzWY/QIY48qugEBeyYvZGkFg+wKL+s4JPAlqx
	/XEBtbN3ySePGSPZL3tfDw+Q8zLbJ6eCjmJVevDkhrMdBBLjffJlODVpt17IxBDSzMZCSk+GoYv
	CdI88AEk1BV6JqtxFkp/gzvxJFrSnTIDknykYGnrDH72oJqp2yd7m2mqbritCHGrnmQ==
X-Received: by 2002:a6b:7601:: with SMTP id g1mr1193934iom.108.1553137739923;
        Wed, 20 Mar 2019 20:08:59 -0700 (PDT)
X-Received: by 2002:a6b:7601:: with SMTP id g1mr1193848iom.108.1553137737331;
        Wed, 20 Mar 2019 20:08:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553137737; cv=none;
        d=google.com; s=arc-20160816;
        b=JBG8nSYnGN+YaUFPFn+SF4h3f9bH1CiUydEi5RC6ZhoTRdEreIxWl4ghDJ+QcFcdQK
         wp3a9U6weyHMMS6OIluJY4B0nmQQdYdcQFMyyrSOkBtoIV0KdYJ0ChCQ6MJKXQTgZipe
         yDfWPfRZPdRTQNQbk3uPASnxwhE8oBnbwrVQqOIKDjKOTXiObhYIDoquvgo6pXXy1u4p
         EfuVXSi33Bokz//Q6f++S3zMBWH9kP9Tc/viMsZ4vzjKdY/8uX3B1TlD8wGSsoD9PdvH
         lOSJGiD+S6wWI/4bshQbKpkY6tTqr7fPln6rlFeujj5cenWYhEpmuD64AuZAhdgmxRPc
         V9ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=krQUPeEhUeWHXrLxX44ZwDfZs9HTeNysg+aRzRJo4mk=;
        b=vXnZs8oVQ2AaboeGvboTT9YiVfG1OlLXtWYD92LNVemuiRPQON2jFcNucd89OznTyr
         HSSnSnkjgvtURKGtKiwq2fEfq91CB/FFELuJRfGinwzADM3LT+bORlrGFJB+HWtrdc/d
         CIKpzAV3B9R7596ZgeZIBPTMLGgeswi53yYtX7DzWwRRqcP8ZjCA5MJQxb9ou+7gyzoe
         04ZzFwQUbd6AY15iqJ7Jb59WWc/ROVB3igrOqGGmt4avu+nHkONgMgjalQ/Z0JfwbB05
         PDGedTnCGyCRU3lgPfnxtHbUoqsSuoipZi11UEqRdToQ94giUAwcHFoEq3UKzfvqfpI0
         ujbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O0DV7ewk;
       spf=pass (google.com: domain of oohall@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oohall@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q67sor7410492ita.3.2019.03.20.20.08.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 20:08:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of oohall@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=O0DV7ewk;
       spf=pass (google.com: domain of oohall@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oohall@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=krQUPeEhUeWHXrLxX44ZwDfZs9HTeNysg+aRzRJo4mk=;
        b=O0DV7ewkSoAZ/rqPwD5L5473opI76dKFPGAiGF1OEwhywBkZXgX0LqbWbZqlvBGki1
         JUgZihhN+9Eegjweh1YadYSub4LnZEHgYfGo2pJo2VsZV4Ptx3MBkLMGs+FcNQwrWmVm
         oE4tFDGaihV8Ir9e01BOPMcWIBq87rX1NxpRuNSgEzO51deT3tCnYfJym9Z2j/sEClaU
         CCZWJQmwrlkuCDH9iW0k1J4Dge2iudMPauqmu3TpSqHCQjx8j/3TVNMoJZ/CcIkcKiuj
         A/NQ87nXc4Ko7AlFTxb/8AxRdB9GfQeszs1EvWxmc2R58s7HGmYeh+wQ0AJXoQnN7eDM
         0Rdw==
X-Google-Smtp-Source: APXvYqwRkBEj4osIJj129KBcDzogr3ZyjA2aRAcSNZSClpJrTRzqCvw6s6lxH3oEPU2CgdaZoAaEOubD8csvDUwrQ1A=
X-Received: by 2002:a24:eb0e:: with SMTP id h14mr1176796itj.100.1553137736931;
 Wed, 20 Mar 2019 20:08:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com> <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com>
 <871s3aqfup.fsf@linux.ibm.com> <CAPcyv4i0SahDP=_ZQV3RG_b5pMkjn-9Cjy7OpY2sm1PxLdO8jA@mail.gmail.com>
 <87bm267ywc.fsf@linux.ibm.com> <878sxa7ys5.fsf@linux.ibm.com>
 <CAPcyv4iuAPg3HWh5e8-Ud3oCrvp5AoFmjOzf4bbA+VLgR7NLFg@mail.gmail.com> <CAPcyv4hMzVuOYzy2tTq-my8Z1y+X6Ug-fyObpKTxVU44p5rBZw@mail.gmail.com>
In-Reply-To: <CAPcyv4hMzVuOYzy2tTq-my8Z1y+X6Ug-fyObpKTxVU44p5rBZw@mail.gmail.com>
From: Oliver <oohall@gmail.com>
Date: Thu, 21 Mar 2019 14:08:45 +1100
Message-ID: <CAOSf1CEZoLw5QqEMTKwiZ+d_qPLp_D9pJZUtnQWMXWpAXOQ2YA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: Dan Williams <dan.j.williams@intel.com>
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

On Thu, Mar 21, 2019 at 7:57 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Wed, Mar 20, 2019 at 8:34 AM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Wed, Mar 20, 2019 at 1:09 AM Aneesh Kumar K.V
> > <aneesh.kumar@linux.ibm.com> wrote:
> > >
> > > Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com> writes:
> > >
> > > > Dan Williams <dan.j.williams@intel.com> writes:
> > > >
> > > >>
> > > >>> Now what will be page size used for mapping vmemmap?
> > > >>
> > > >> That's up to the architecture's vmemmap_populate() implementation.
> > > >>
> > > >>> Architectures
> > > >>> possibly will use PMD_SIZE mapping if supported for vmemmap. Now a
> > > >>> device-dax with struct page in the device will have pfn reserve area aligned
> > > >>> to PAGE_SIZE with the above example? We can't map that using
> > > >>> PMD_SIZE page size?
> > > >>
> > > >> IIUC, that's a different alignment. Currently that's handled by
> > > >> padding the reservation area up to a section (128MB on x86) boundary,
> > > >> but I'm working on patches to allow sub-section sized ranges to be
> > > >> mapped.
> > > >
> > > > I am missing something w.r.t code. The below code align that using nd_pfn->align
> > > >
> > > >       if (nd_pfn->mode == PFN_MODE_PMEM) {
> > > >               unsigned long memmap_size;
> > > >
> > > >               /*
> > > >                * vmemmap_populate_hugepages() allocates the memmap array in
> > > >                * HPAGE_SIZE chunks.
> > > >                */
> > > >               memmap_size = ALIGN(64 * npfns, HPAGE_SIZE);
> > > >               offset = ALIGN(start + SZ_8K + memmap_size + dax_label_reserve,
> > > >                               nd_pfn->align) - start;
> > > >       }
> > > >
> > > > IIUC that is finding the offset where to put vmemmap start. And that has
> > > > to be aligned to the page size with which we may end up mapping vmemmap
> > > > area right?
> >
> > Right, that's the physical offset of where the vmemmap ends, and the
> > memory to be mapped begins.
> >
> > > > Yes we find the npfns by aligning up using PAGES_PER_SECTION. But that
> > > > is to compute howmany pfns we should map for this pfn dev right?
> > > >
> > >
> > > Also i guess those 4K assumptions there is wrong?
> >
> > Yes, I think to support non-4K-PAGE_SIZE systems the 'pfn' metadata
> > needs to be revved and the PAGE_SIZE needs to be recorded in the
> > info-block.
>
> How often does a system change page-size. Is it fixed or do
> environment change it from one boot to the next? I'm thinking through
> the behavior of what do when the recorded PAGE_SIZE in the info-block
> does not match the current system page size. The simplest option is to
> just fail the device and require it to be reconfigured. Is that
> acceptable?

The kernel page size is set at build time and as far as I know every
distro configures their ppc64(le) kernel for 64K. I've used 4K kernels
a few times in the past to debug PAGE_SIZE dependent problems, but I'd
be surprised if anyone is using 4K in production.

Anyway, my view is that using 4K here isn't really a problem since
it's just the accounting unit of the pfn superblock format. The kernel
reading form it should understand that and scale it to whatever
accounting unit it wants to use internally. Currently we don't so that
should probably be fixed, but that doesn't seem to cause any real
issues. As far as I can tell the only user of npfns in
__nvdimm_setup_pfn() whih prints the "number of pfns truncated"
message.

Am I missing something?

> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

