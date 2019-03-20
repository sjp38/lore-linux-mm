Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88544C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:34:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 392DE2183E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:34:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="S1BTeZ60"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 392DE2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C467E6B0282; Wed, 20 Mar 2019 11:34:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF8F56B0284; Wed, 20 Mar 2019 11:34:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC1206B0285; Wed, 20 Mar 2019 11:34:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 783226B0282
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:34:33 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id e12so1391495otl.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:34:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=uNIyVUbxeFEDoIbxgtBJkCNkY0r/4CBODhtc3HnZvfo=;
        b=AukWpX7Gtnzx4wbBUBcu/FJPgS7fNWaNUqSFYKCXmiKYhzpJz6WilY5BX4A0n/KNGM
         Qa0zOryVvphOlCFo61qzbg5JJtpOtMRHh2drfkJLE9cU3vKfHbufH7+oMGqxM+8cKPnu
         AvfYF8s5sNP96xwSq+yEsgMgGjYommMRJ3mKSiUvvO8iJ0ZZ2Xzpm0UZgnuC4N4MWkh+
         FFBRtq6NTiK7iUp7shPsxLOptT9azEOmIu19nJwjk4rU9ylZ/K78q/qBb/HhfkBa9lZ4
         yf8Gspkwv2aJ0zFJTrx+R58oj9YiL0CSIh/YZM3T5sL6Vkz+ewgfWiZO7VcqdcIyXkwJ
         mshQ==
X-Gm-Message-State: APjAAAUy2QLNUQVvxzjyuVQTnGnD4jKhkkdCW79AesDmJc6PWs79bOwG
	iV32LNiKKsj9eL5WZNmCsMGjS0sjYvNIJjR2+XXKvRflhUPs+K/m0GYOfVeF3NLI6V8SxAW+iAE
	bMWh6SM24zen0gHP0OAwcGlMGQo7feBLr2GueV9JX7QorlePWiBBYk6qJRHbNDXQ6tA==
X-Received: by 2002:a9d:6e88:: with SMTP id a8mr6408123otr.117.1553096073035;
        Wed, 20 Mar 2019 08:34:33 -0700 (PDT)
X-Received: by 2002:a9d:6e88:: with SMTP id a8mr6408042otr.117.1553096072136;
        Wed, 20 Mar 2019 08:34:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553096072; cv=none;
        d=google.com; s=arc-20160816;
        b=n0VVRGtAwDVgmpiosJN/Ikfn/AP3HbeiluBO2cBpN129Fj0vJm88rcWAqIElvIBW5d
         l9GMQvuw7Z0kE9KtPdmcHgOOL9c6tXvdQ706rkHg0TBJvu5swbg9iQiG3a3DyEysgg6V
         i7oQw5jHFSD5IMYS/tHiho2o0bwNMPGkr/XEydaopiaLHiY2gx+nsotmOPgMhMArLn9C
         Fo1jXpZhi6ZCF7JhqsvsV7VPtdqZSTBf64Hp9eWGD8epICVvdkoHTZhUZ6ucgSjd32gl
         EKDQd79Hxty1NC2l+0Czw7pG1PXVIqisCz1AII3Xcv9OnqdzUCvB9SlRjrlVNRjiWTO9
         HU/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=uNIyVUbxeFEDoIbxgtBJkCNkY0r/4CBODhtc3HnZvfo=;
        b=OmiwPevc4irAhXiE9wf8zVI+2kV5CLCEHD9R+ho5sLOoJ/8AjUr9mN9Whqh3VOotMD
         lcJendiOV6VAGawvpRRThSemjOJMBi50C055Xys1fZWEV3xAsNmU+dtqPO+N1NxkaTIa
         Et8AivnC9HcoRcVdilrBW9RsByNXRRlisbmATccHcBCirsgJn7yPpq/YePIGryPDM83X
         B5EGkLLVHV8CDNvsXRqJJmqvRHdvKJcJy8U5i3KL1klKR8P8+SXjQ0EYZheKHAT7agFb
         Ha+2f6AdUmUl0WyAsuWX4avc8XQoTDt1kZFAsOQftaOjffwPontc7bG6GGSgyBgOtsO0
         WoWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=S1BTeZ60;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z16sor1711854oth.36.2019.03.20.08.34.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 08:34:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=S1BTeZ60;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uNIyVUbxeFEDoIbxgtBJkCNkY0r/4CBODhtc3HnZvfo=;
        b=S1BTeZ60qB8Kcw6wQHVvBU2Cw4rNly7jAnT1sv/cmmSV2k4deA9yMb7w1j6/m2Q7eN
         I0qQK4ihRRtoLqjMr9JBlDJxL03hrUvIAZ4zrfaYSZwb9Rz9vc0AqJaovdTBauLDCGg2
         5ak3wWitVxY9gkpb4x+iB0EYEiq5A8H80kh1YPOC6PxGa9koz5UavcxbNY+BLgYvx3Dh
         J6CAW3BvJDoHbLCvHJV56Y1nul+KP6YMIlIA2Wo3Ei5mh1A0af24SEv5q1xMa9+k6XxD
         mjNrgoBWeZEj3sPoSMDW+6K9ngq6F4U19oVo6Hc1SCLZkYrHIijoo2AnD4h8DCLqdEFt
         xSiw==
X-Google-Smtp-Source: APXvYqxh599eRoi9kopKodFa8svBbY69SGQsc6Ak3KgIjjSVU6tD1uVGa0VbJ5R8O2CduKZXexy6I0CD6Z58iDK2Ytg=
X-Received: by 2002:a9d:224a:: with SMTP id o68mr6279518ota.214.1553096071716;
 Wed, 20 Mar 2019 08:34:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com> <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com>
 <871s3aqfup.fsf@linux.ibm.com> <CAPcyv4i0SahDP=_ZQV3RG_b5pMkjn-9Cjy7OpY2sm1PxLdO8jA@mail.gmail.com>
 <87bm267ywc.fsf@linux.ibm.com> <878sxa7ys5.fsf@linux.ibm.com>
In-Reply-To: <878sxa7ys5.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 20 Mar 2019 08:34:20 -0700
Message-ID: <CAPcyv4iuAPg3HWh5e8-Ud3oCrvp5AoFmjOzf4bbA+VLgR7NLFg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, 
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

On Wed, Mar 20, 2019 at 1:09 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com> writes:
>
> > Dan Williams <dan.j.williams@intel.com> writes:
> >
> >>
> >>> Now what will be page size used for mapping vmemmap?
> >>
> >> That's up to the architecture's vmemmap_populate() implementation.
> >>
> >>> Architectures
> >>> possibly will use PMD_SIZE mapping if supported for vmemmap. Now a
> >>> device-dax with struct page in the device will have pfn reserve area aligned
> >>> to PAGE_SIZE with the above example? We can't map that using
> >>> PMD_SIZE page size?
> >>
> >> IIUC, that's a different alignment. Currently that's handled by
> >> padding the reservation area up to a section (128MB on x86) boundary,
> >> but I'm working on patches to allow sub-section sized ranges to be
> >> mapped.
> >
> > I am missing something w.r.t code. The below code align that using nd_pfn->align
> >
> >       if (nd_pfn->mode == PFN_MODE_PMEM) {
> >               unsigned long memmap_size;
> >
> >               /*
> >                * vmemmap_populate_hugepages() allocates the memmap array in
> >                * HPAGE_SIZE chunks.
> >                */
> >               memmap_size = ALIGN(64 * npfns, HPAGE_SIZE);
> >               offset = ALIGN(start + SZ_8K + memmap_size + dax_label_reserve,
> >                               nd_pfn->align) - start;
> >       }
> >
> > IIUC that is finding the offset where to put vmemmap start. And that has
> > to be aligned to the page size with which we may end up mapping vmemmap
> > area right?

Right, that's the physical offset of where the vmemmap ends, and the
memory to be mapped begins.

> > Yes we find the npfns by aligning up using PAGES_PER_SECTION. But that
> > is to compute howmany pfns we should map for this pfn dev right?
> >
>
> Also i guess those 4K assumptions there is wrong?

Yes, I think to support non-4K-PAGE_SIZE systems the 'pfn' metadata
needs to be revved and the PAGE_SIZE needs to be recorded in the
info-block.

