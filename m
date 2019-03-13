Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6730BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:07:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 170FF20643
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:07:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Ev3mjXd6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 170FF20643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FCCC8E0003; Wed, 13 Mar 2019 12:07:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8ADAA8E0001; Wed, 13 Mar 2019 12:07:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79EDF8E0003; Wed, 13 Mar 2019 12:07:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 473CD8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:07:26 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id b21so992653otl.7
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:07:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=/XfqRx4tzKzsjCcb8QbRLqX/uBHxzCtpu1uDPCItsOs=;
        b=HBd7mlt+kFvxtxNoKC6Dr90DQukl9GE+zG/gOOhy64BubJVAuYBDj1qHegEQlSHnm5
         yOObwoL8QgnO9tJhdEs7Xi+YelXamLni/625knbmvNgT+uO8fAKgGL6i0OaShPfQaCbn
         66VC2C/nB8Lg3+hmp9dDFQuAz3eYQTWnhPWP0tdGN2XJ5qIPG/AohwAaOTwQ9X3Y86jy
         hWV1j4OS2Meatswge23fZIj/KAv+BB6RdXjTlF03/RHImYjXZ/6QADGIxYrD3JPCfPTP
         yIBG7nx9tfpngrofI6qmnV7uJJHNEZDqrG2LmIflogXdnIDmCCz4sp8awma3PwnoULjO
         C1Rw==
X-Gm-Message-State: APjAAAVNYcpIGYdoDHXxPUQtuHvWng1v5WhI+R0Cgjv+WyrXbb/OFVF2
	B3igM1awGcZwnIF7+JnQ7fLz2XLNksG3Lo9fXCb7ahlQPmbhGAZMkxQhJ3PQqIx1jq+qZUVxYri
	M0kQclnQ41GzkkxgbtdQrNu8RuENAh5bIV3dTZ5C2lJQxdR/Xv5jBjSJ5zfZbIDB2BQx1yEvu7o
	r4W7usO7ignveH6+er+LbA98o5UpYeRclfJ/ojQyQH92PBqV/fJbdyFsnu5PLbOcLYWKjTLlLuz
	V5cdOtWtlkbyM32GFAm5H8RI1j8Nf7TVcyl7kEB6UxYOiRNHr4p8u3ZmYSTTTj8EC57HWaWROlS
	g3oyZNDeaTmETbNxFrLE7IC3UohnKjntpcz6nMKP83Cc/hMFiLUCHcBWeUba0An7toquDODERUK
	S
X-Received: by 2002:a05:6830:1547:: with SMTP id l7mr27211009otp.196.1552493245961;
        Wed, 13 Mar 2019 09:07:25 -0700 (PDT)
X-Received: by 2002:a05:6830:1547:: with SMTP id l7mr27210951otp.196.1552493244974;
        Wed, 13 Mar 2019 09:07:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552493244; cv=none;
        d=google.com; s=arc-20160816;
        b=ZMq3Ps8A80pYMMSHMO6iG/vP2gaYRozypiJxXXgco33N3Xu6ErzFMaT8hNOn7tHMzs
         OshF+J7MhO0SYM8asG/JdfcCYKgUwXVYmayNKKVLZjCXzPyAzh5y28vY3e9FEsHxqqtk
         +vRUKiD3x/fpOMXchqb9E7oNWR3Whm3g6bQldOnREDrSptI3bnxmG7RdhLFLtSseRU0C
         ELmPZX18QTfm68hXJ3FeiPYeLzZxdAStgZ+XvcWoqAtmjE/ML9gOVa97ROw/L4TyfMad
         hF1uUjCPxln1Eujdj8wC9EprcPZJWS4izZ7fHt839bhrTSrn8biq3/Md7/GVBBwUJl0C
         ILkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=/XfqRx4tzKzsjCcb8QbRLqX/uBHxzCtpu1uDPCItsOs=;
        b=FBNEMMRqyJ1V4cFAac7ki03bnIV2mY2bXZgWyei3NCNENswgMryb4MNmhGLDi2Gnwd
         pQCCTIo4pwjg9tcGI9kzaVmCtnjtqdjZFOPcbC3ko9MVcQiN52UkinPkLauaGvdQanpL
         GbAkREOrz4fwBXV0jpHovLABdEHo6906BxacddilbYQg4YXohKWMEcvJ7ulNXqk1A0Gl
         Di4d9sQkofObLMtj6NIPJ/TMPYfV0CSmQFeX5ktX85Uw6RiYV6hJtIeIXIUxktf2bM0f
         XL6YK3qGbkgDK2oe1BZMIcMuoFlKJMfhXexNSR/glSKDg0W+449ZeKpSxRWP/c6oM5d+
         iRUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Ev3mjXd6;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v88sor6386470otb.110.2019.03.13.09.07.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 09:07:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Ev3mjXd6;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=/XfqRx4tzKzsjCcb8QbRLqX/uBHxzCtpu1uDPCItsOs=;
        b=Ev3mjXd6En91xODIUX56pYwhJLO9DdmQ95Gif+qABOQYxSXLSsL3HdkZ996LpFM0Ok
         BNFXboh0vkQcZET1UNi2xWbfJOgLi7YJOBlDe07HQIOTkXhyuZZtxYx1Jr323nQBINw1
         bCIVmxF4JR2efLcgr/ZOkQzDj5SYAbGOQud/xj7awoc+6yVUoor9qC0PAVErRf0dlx+t
         qM1zGEHB4PSIuwMXtFmThJuVWsfXkY8L4/6g612b2JAC90VycrbkkPGVtxjK+QjLV1tp
         zV3E3pIxFXDm4fJ1q4lhu5iiryNlMnlw3ajMFHOD83PMclLscUSXLEmMdZOnDZ62lqrK
         YZQA==
X-Google-Smtp-Source: APXvYqzH9OHk6fwYw9vNd25aIvBEiA2sVSv1vjB2i+lT3GwQjeRBJM8aOKz1bJJDYo3s88am/imNu4byiUR9Jvcm8nc=
X-Received: by 2002:a9d:224a:: with SMTP id o68mr16122221ota.214.1552493244500;
 Wed, 13 Mar 2019 09:07:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com> <20190306124453.126d36d8@naga.suse.cz> <df01bf6e-84a1-53fb-bf0c-0957af2f79e1@linux.ibm.com>
In-Reply-To: <df01bf6e-84a1-53fb-bf0c-0957af2f79e1@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 13 Mar 2019 09:07:13 -0700
Message-ID: <CAPcyv4iLm09DSiF3niFprP3PTFrgB5pZPp9AysBpRa-m725tmw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: =?UTF-8?Q?Michal_Such=C3=A1nek?= <msuchanek@suse.de>, 
	Oliver <oohall@gmail.com>, Jan Kara <jack@suse.cz>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Ross Zwisler <zwisler@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 4:46 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> On 3/6/19 5:14 PM, Michal Such=C3=A1nek wrote:
> > On Wed, 06 Mar 2019 14:47:33 +0530
> > "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
> >
> >> Dan Williams <dan.j.williams@intel.com> writes:
> >>
> >>> On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:
> >>>>
> >>>> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
> >>>> <aneesh.kumar@linux.ibm.com> wrote:
> >
> >> Also even if the user decided to not use THP, by
> >> echo "never" > transparent_hugepage/enabled , we should continue to ma=
p
> >> dax fault using huge page on platforms that can support huge pages.
> >
> > Is this a good idea?
> >
> > This knob is there for a reason. In some situations having huge pages
> > can severely impact performance of the system (due to host-guest
> > interaction or whatever) and the ability to really turn off all THP
> > would be important in those cases, right?
> >
>
> My understanding was that is not true for dax pages? These are not
> regular memory that got allocated. They are allocated out of /dev/dax/
> or /dev/pmem*. Do we have a reason not to use hugepages for mapping
> pages in that case?

The problem with the transparent_hugepage/enabled interface is that it
conflates performing compaction work to produce THP-pages with the
ability to map huge pages at all. The compaction is a nop for dax
because the memory is already statically allocated. If the
administrator does not want dax to consume huge TLB entries then don't
configure huge-page dax. If a hypervisor wants to force disable
huge-page-configured device-dax instances after the fact it seems we
need an explicit interface for that and not overload
transparent_hugepage/enabled.

