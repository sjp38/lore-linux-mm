Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EB29C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 05:16:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EFC620828
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 05:16:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="hS0iaKXN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EFC620828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60BA46B0003; Thu,  5 Sep 2019 01:16:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BB766B0005; Thu,  5 Sep 2019 01:16:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AA226B0006; Thu,  5 Sep 2019 01:16:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0209.hostedemail.com [216.40.44.209])
	by kanga.kvack.org (Postfix) with ESMTP id 2390E6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 01:16:12 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C02BF824CA2C
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 05:16:11 +0000 (UTC)
X-FDA: 75899705742.07.price51_52fe40ba82f51
X-HE-Tag: price51_52fe40ba82f51
X-Filterd-Recvd-Size: 5546
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com [209.85.167.193])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 05:16:10 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id 7so753358oip.5
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 22:16:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ANhLYAgQ2zCWY2vllIvc9e5G3lO6EoINw8yyuu02p0I=;
        b=hS0iaKXNIbotJ+Fjgi1/OUgawZQUWZTYSUmhPvi3DURqLT1lmHweT0Mm9pWTBXzCMG
         JuORyrCopHp/A7Pv2z5ddLAbuNfwNtEIdF/uciR8X3gv1kZfEchsRqs+cWukNVKJNS+s
         4HmSLbGXcbWIgVvY/i8yyrW5nf/9N/XDJJhdDMhsgj2UAyeZUUHetwmZ1PaSE9yEFlJ4
         wI9agMu+PPRxyjzkaARo+swU106HGYUJUnzDKS6ckFvHvukxT1rBlq/XCxQe3NW+3vbs
         pHdOAHM99oipC+0kELDhrpGkcAb5WXqh8SFCdGtQKZwEehCbkzuRQB8NjIf0hoAE9ZD/
         xUww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ANhLYAgQ2zCWY2vllIvc9e5G3lO6EoINw8yyuu02p0I=;
        b=CoZH7fPkMtWWqe6x05cUjPdINrRlQqGqUYPG7cthaBDBv6en4lE7SJdOraqR6lQAsf
         UUj2w/UVuPZhPViOWKDzR+RKbIHQHTtQsS1jy71JT7N8L8vb2LbZ/l6VN0w3FAebIGMP
         5bXpaeMeL4qVZo6cG2o2a2giqOKDRDbMWUKYJSur7B8aFIqsYJgbH/KIQt/7Wg+3RwBB
         cCaJDERNX25ADnjPKK8JwDdqsWnZiQzEQ+2c5+aS3aZcf8Ch+XNEo4kt7514aakbRnzS
         cgpBaBsxVTRD9BM6f6HR9UNmIGB38l+FFdYoaMOG1/kOYwwNN33MwwTOsLluS2xjDyt/
         QvXQ==
X-Gm-Message-State: APjAAAVHn2RKaxLIZmz22KjxifjaKCRPYZyMIUC50vT7LmzohAT+mYwC
	UH56Orr1ZAZfNw/RQTd2I5NUK+hGbrnHihOFk5S8HQ==
X-Google-Smtp-Source: APXvYqycF0lLajdtVSDJ/9mSRESb/gnmYCZAkHRCTFQQQl6Q4b+o9jzD3IOoxCwZchC5glo463Ur6N0lTu7KnxGWDW8=
X-Received: by 2002:aca:5dc3:: with SMTP id r186mr1119653oib.73.1567660569341;
 Wed, 04 Sep 2019 22:16:09 -0700 (PDT)
MIME-Version: 1.0
References: <20190904065320.6005-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hD8SAFNNAWBP9q55wdPf-HYTEjpS4m+rT0VPoGodZULw@mail.gmail.com>
 <33b377ac-86ea-b195-fd83-90c01df604cc@linux.ibm.com> <CAPcyv4hBHjrTSHRkwU8CQcXF4EHoz0rzu6L-U-QxRpWkPSAhUQ@mail.gmail.com>
 <d46212fb-7bbb-3db8-5a65-2c8799021fd6@linux.ibm.com>
In-Reply-To: <d46212fb-7bbb-3db8-5a65-2c8799021fd6@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 4 Sep 2019 22:15:57 -0700
Message-ID: <CAPcyv4impX2OEd3ZATz_4_UjOvC4N78uU+PBPRK+id3Nh0EPCw@mail.gmail.com>
Subject: Re: [PATCH v8] libnvdimm/dax: Pick the right alignment default when
 creating dax devices
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 4, 2019 at 9:10 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> On 9/5/19 8:29 AM, Dan Williams wrote:
> >>> Keep this 'static' there's no usage of this routine outside of pfn_devs.c
> >>>
> >>>>    {
> >>>> -       /*
> >>>> -        * This needs to be a non-static variable because the *_SIZE
> >>>> -        * macros aren't always constants.
> >>>> -        */
> >>>> -       const unsigned long supported_alignments[] = {
> >>>> -               PAGE_SIZE,
> >>>> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >>>> -               HPAGE_PMD_SIZE,
> >>>> +       static unsigned long supported_alignments[3];
> >>>
> >>> Why is marked static? It's being dynamically populated each invocation
> >>> so static is just wasting space in the .data section.
> >>>
> >>
> >> The return of that function is address and that would require me to use
> >> a global variable. I could add a check
> >>
> >> /* Check if initialized */
> >>    if (supported_alignment[1])
> >>          return supported_alignment;
> >>
> >> in the function to updating that array every time called.
> >
> > Oh true, my mistake. I was thrown off by the constant
> > re-initialization. Another option is to pass in the storage since the
> > array needs to be populated at run time. Otherwise I would consider it
> > a layering violation for libnvdimm to assume that
> > has_transparent_hugepage() gives a constant result. I.e. put this
> >
> >          unsigned long aligns[4] = { [0] = 0, };
> >
> > ...in align_store() and supported_alignments_show() then
> > nd_pfn_supported_alignments() does not need to worry about
> > zero-initializing the fields it does not set.
>
> That requires callers to track the size of aligns array. If we add
> different alignment support later, we will end up updating all the call
> site?

2 sites for something that gets updated maybe once a decade?

>
> How about?
>
> static const unsigned long *nd_pfn_supported_alignments(void)
> {
>         static unsigned long supported_alignments[4];
>
>         if (supported_alignments[0])
>                 return supported_alignments;
>
>         supported_alignments[0] = PAGE_SIZE;
>
>         if (has_transparent_hugepage()) {
>                 supported_alignments[1] = HPAGE_PMD_SIZE;
>                 if (IS_ENABLED(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD))
>                         supported_alignments[2] = HPAGE_PUD_SIZE;
>         }

Again, this makes assumptions that has_transparent_hugepage() always
returns the same result every time it is called.

