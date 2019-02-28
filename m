Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E73EFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:45:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FD952184A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:45:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="sKjZahpq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FD952184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C2838E000C; Thu, 28 Feb 2019 11:45:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2490C8E0001; Thu, 28 Feb 2019 11:45:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EB808E000C; Thu, 28 Feb 2019 11:45:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D3EEF8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:45:45 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id i4so9940650otf.3
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:45:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GvhxX4m4DDgRvunBUbdiOHoUSvWB/Hk337al+7FlQLk=;
        b=rAoN5xZ3XLH+nDT4XWuglw0nZcT2V6HaAUT1yAG4Dwh/6AGKi0EOymqoIegElh1M+j
         SbwmEfEU8XDwkTfgGQ06TdCZL/ZhCTN5lE6Z3gnwcBN1z/QDGASA90Pnh2SOb6rYQ0oT
         6n+S+uYLevE80sve8mqe59T2pKOhM9HryL5/D9vH8R0EfjWRJETEk0lmgRfnNDFrwD76
         xLM9iGMMGBgFaIQlOhrqZ2UuetWFatJXDbYM1keZvrALpSCahncV9esCx8hEd8ESYEO5
         I8yeApYTkSin45gdyYb+m9wXUGiWJ8rcTE/Y/QQEMtcvYpVwtxVEk/fPHAIJCgt8G+cl
         m12g==
X-Gm-Message-State: APjAAAVsF5nFtNxNeZvhm/RekR5wn4CS/bc1MCOB0OqIWXC8kNdIlNio
	4MSOLwlD5q6/uuvxblQt/LrZkJnbJiFciKkl0ynfcOuzPq3XAiFOulwgphO5Rqs6OW4VnjJ2W5w
	WmG6qEoEOHgGhJ8pA8jAivs/ofTJODgXawH1ENiciVY/GyqjuBwUHxKlu7hZV59JjMaRPDjPOzj
	LZCbP/gwH6PaijQeU1vWpZftvBbPMltoQ+2S5WaDzcjbZpMhFFSGKZsm9u7fJGUJKjGH9hQqsRB
	sOizzBS7nn2otBgqUqbyWRMxLQyLztOZGemxQQPWVzMmU+SkLLhnzIGe5/bvwgVlV1Ew4gtFdKx
	S9Pf3tB2pEkNu7t9WzLQNBFpv98lgJQF/2aPV1CkDI0gybgyTq2Gj7y8SZpW+3uCsTBEqAhk6R0
	D
X-Received: by 2002:a9d:2944:: with SMTP id d62mr324212otb.193.1551372345633;
        Thu, 28 Feb 2019 08:45:45 -0800 (PST)
X-Received: by 2002:a9d:2944:: with SMTP id d62mr324151otb.193.1551372344630;
        Thu, 28 Feb 2019 08:45:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551372344; cv=none;
        d=google.com; s=arc-20160816;
        b=HJsKYPTcCLzytNrW5bf94sN2ksIc5FjwfXLNKG3Dut9S6D0Upii4BM1Ks7vdFyaaUW
         +Yo5KvlkHDTx3Bpsu5jRLQZ+ZTm0CMCkv8gco52F1IpxvOuSvUwbh42fm0/IF4qt7O06
         nB80D780Ghu1Qhoy2AlhfYPiFhHNG1GImDp81zmD3GciDvEGzZDALWqk4I6vB1lHJ3v6
         Vdv9QrshslcrbPV4vPBWNwJEWgEwr0i282xgXFILPtQqOgWr2arZkIyRaoOctgQwetbp
         fakmlZKy9Eyw3FgnGuVN2kv/dz3wdETSHWWu9tjsq6ykvuqyLwxGcU+KATPgT/45+h5P
         YfUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GvhxX4m4DDgRvunBUbdiOHoUSvWB/Hk337al+7FlQLk=;
        b=m9Oaohpn1foqr5VBIrcuMXF9+iOTB89NhglV92akjIqtx1rcy4S/WfayUWHSlNgBRC
         CE0CEApho4nmByYAoXPtBpKjbH2b8v6qRJ9BxdsiGrYTok5E7CjmFe29cBMP1rX/jTJ/
         i8NS0t/cZZHVZ2fas7Ln1RSoPtnkzibw+aYeSvA71anewjPc7823HMw72jm0EkE5GrQ5
         J9MZ/sW0Rnl8ZISdlNjBX2XbFVrWa2TkmXdxJfrfJ3VCMykIhqW04VsNQ5BNqler447c
         bJIZ/A24nFwTJKCmvHsjUTlKx/Bx4FNt3VkZMYy7H8l4sLLTMXjDjsKtED1QS4IPkVd0
         EH1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sKjZahpq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e68sor6436758oih.92.2019.02.28.08.45.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 08:45:44 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=sKjZahpq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GvhxX4m4DDgRvunBUbdiOHoUSvWB/Hk337al+7FlQLk=;
        b=sKjZahpqLoNNijSf1ASjSZV8KHb1T2pBvfJ8ZXu7oVWb4/P10/h8rJerPiBktmGf/z
         7NfEcLHD3p4zXo1ZmYr7MImWVn17oPPpOlQMe5LErUC9EIoXIaD6FTjJG9UM2GfOXNM6
         vFmRb4RxT+LbMnU5VU60eP+/722YCg4aFyiYs2S7A5jngKXOVsjRxC/1KNPMaKM71nT+
         mfcvH8LyhTwrnmpC0N1p7puJbqW752XYw6l//tQW8kvsUZvrKsKBNgyLyLfx5OOWa61R
         /c9koXc2E95zIEqo1Rbs06GS9SjZecXBT62GCD3n2g4xiAbfmeAMn/h9gUzD/D/+BwdJ
         wirw==
X-Google-Smtp-Source: AHgI3Ialxeei+TqZP4it7v2/IHqhibSwTNUvWajfoBg7rMbaO6RwmNOzFKIZGvWfOT0mpIi9Wh7jEeFSztTtzScKpmE=
X-Received: by 2002:aca:32c3:: with SMTP id y186mr388997oiy.118.1551372344134;
 Thu, 28 Feb 2019 08:45:44 -0800 (PST)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
In-Reply-To: <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 28 Feb 2019 08:45:32 -0800
Message-ID: <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: Oliver <oohall@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, 
	Michael Ellerman <mpe@ellerman.id.au>, Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:
>
> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
> >
> > Add a flag to indicate the ability to do huge page dax mapping. On architecture
> > like ppc64, the hypervisor can disable huge page support in the guest. In
> > such a case, we should not enable huge page dax mapping. This patch adds
> > a flag which the architecture code will update to indicate huge page
> > dax mapping support.
>
> *groan*
>
> > Architectures mostly do transparent_hugepage_flag = 0; if they can't
> > do hugepages. That also takes care of disabling dax hugepage mapping
> > with this change.
> >
> > Without this patch we get the below error with kvm on ppc64.
> >
> > [  118.849975] lpar: Failed hash pte insert with error -4
> >
> > NOTE: The patch also use
> >
> > echo never > /sys/kernel/mm/transparent_hugepage/enabled
> > to disable dax huge page mapping.
> >
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> > ---
> > TODO:
> > * Add Fixes: tag
> >
> >  include/linux/huge_mm.h | 4 +++-
> >  mm/huge_memory.c        | 4 ++++
> >  2 files changed, 7 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > index 381e872bfde0..01ad5258545e 100644
> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -53,6 +53,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
> >                         pud_t *pud, pfn_t pfn, bool write);
> >  enum transparent_hugepage_flag {
> >         TRANSPARENT_HUGEPAGE_FLAG,
> > +       TRANSPARENT_HUGEPAGE_DAX_FLAG,
> >         TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> >         TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
> >         TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
> > @@ -111,7 +112,8 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
> >         if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
> >                 return true;
> >
> > -       if (vma_is_dax(vma))
> > +       if (vma_is_dax(vma) &&
> > +           (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_DAX_FLAG)))
> >                 return true;
>
> Forcing PTE sized faults should be fine for fsdax, but it'll break
> devdax. The devdax driver requires the fault size be >= the namespace
> alignment since devdax tries to guarantee hugepage mappings will be
> used and PMD alignment is the default. We can probably have devdax
> fall back to the largest size the hypervisor has made available, but
> it does run contrary to the design. Ah well, I suppose it's better off
> being degraded rather than unusable.

Given this is an explicit setting I think device-dax should explicitly
fail to enable in the presence of this flag to preserve the
application visible behavior.

I.e. if device-dax was enabled after this setting was made then I
think future faults should fail as well.

