Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C709C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 20:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CC0522CE8
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 20:33:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="psHWRrKd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CC0522CE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C35D26B0007; Mon, 19 Aug 2019 16:33:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE62D6B0008; Mon, 19 Aug 2019 16:33:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFCB36B000A; Mon, 19 Aug 2019 16:33:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id 900B26B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:33:39 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 3F87A181AC9B4
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 20:33:39 +0000 (UTC)
X-FDA: 75840328158.26.range67_771ec514b2805
X-HE-Tag: range67_771ec514b2805
X-Filterd-Recvd-Size: 6427
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 20:33:38 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id m24so2916141otp.12
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:33:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=B0w/srl7CvMR3sGmFMfU5XCGV1/r89NViS9qVVWCBSI=;
        b=psHWRrKd3x75XaBq4Qa+LS1cLPahMqjrX1Wn9mxcApv8yxQqSht7/8v5RuDSONcTl0
         ehqF6W3K8BdBMNPmHEpQENl+LP9kj1ttVSPpJsNMgb4CFrSpSHeTXJfrbNIlcP/4P2ax
         v/WYGq8gB4lM4fAbHXnXRH5vG+D6KqARROwqYsqvxa0BEXVHuSqlzyvY4cBCrpe0qGoz
         SPOArGDUJmF04uROBncNRtZ5jVqMijWggZ1TrKwCut/1onZ9d8tQoJx1S9Oj2RYVRSO9
         UDY9LRaj95qDLjn1TjoKhMj94FU49Cs6G2ne+/7PDV66Ps0ReP7phOU9Vmk0BhC4KDNz
         5niQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=B0w/srl7CvMR3sGmFMfU5XCGV1/r89NViS9qVVWCBSI=;
        b=VTOznkY1TeUkAJZslfkv3lnYpFm1qwe3QTa17v/VYvQU+03YNvTAF8/OmaLkgvYkv6
         8BMIjAoPVXSz6Pwiu/UDM+jAl1Z1sX04O+u4O3EUgnAT5DdzEHe9PoUPEj5rvgK2pkOP
         vxprkMD810/oRT2UKrXK0cvo9QMjNaycJwVF7gik1al7Y0v/lFtBYkvjDZ/Xc4Jz4/3G
         hVN6ByKvZDjTe22xO5RHCAlN4XpLtpiV7zxEm6sGwk05GKbF0IWWqwXw8TItHrGeYafo
         BsueZiRZ+ZEYja0ZdiVzD4xS3QG/DHwzfNGnDyYfWDKh/4KRV80mfV/gw3aXVx9Lpa7T
         7ktg==
X-Gm-Message-State: APjAAAWSBxico1J4JvnleMYgEY8PCY/Xsrh1nWau7fUvAMRCKIvCZYds
	HTxnAIDibEABfPv4ir9uUoJkGZEbFjf5SuNBBrun2w==
X-Google-Smtp-Source: APXvYqy9tHBQADa1qvVeSsghOJr6TWr+3Lup/KNrD2wljjZJ0t87Se7fCmBqBKSv6ZJkJN9H9FM27wQ23v9EoryQYPc=
X-Received: by 2002:a05:6830:458:: with SMTP id d24mr19105752otc.126.1566246817595;
 Mon, 19 Aug 2019 13:33:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190809074520.27115-1-aneesh.kumar@linux.ibm.com>
 <20190809074520.27115-4-aneesh.kumar@linux.ibm.com> <CAPcyv4hc_-oGMp6jGVknnYs+rmj4W1A_gFCbmAX2LFw0hsfL5g@mail.gmail.com>
 <87v9ut1vev.fsf@linux.ibm.com> <87mug5biyg.fsf@linux.ibm.com>
In-Reply-To: <87mug5biyg.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 19 Aug 2019 13:33:26 -0700
Message-ID: <CAPcyv4hTQ8iVPbOmQNHEeT9-Z6-52k4dxexq5mTr-A4cru0OkQ@mail.gmail.com>
Subject: Re: [PATCH v5 3/4] mm/nvdimm: Use correct #defines instead of open coding
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 2:32 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com> writes:
>
> > Dan Williams <dan.j.williams@intel.com> writes:
> >
> >> On Fri, Aug 9, 2019 at 12:45 AM Aneesh Kumar K.V
> >> <aneesh.kumar@linux.ibm.com> wrote:
> >>>
> >>
>
> ...
>
> >>> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> >>> index 37e96811c2fc..c1d9be609322 100644
> >>> --- a/drivers/nvdimm/pfn_devs.c
> >>> +++ b/drivers/nvdimm/pfn_devs.c
> >>> @@ -725,7 +725,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
> >>>                  * when populating the vmemmap. This *should* be equal to
> >>>                  * PMD_SIZE for most architectures.
> >>>                  */
> >>> -               offset = ALIGN(start + SZ_8K + 64 * npfns, align) - start;
> >>> +               offset = ALIGN(start + SZ_8K + sizeof(struct page) * npfns,
> >>
> >> I'd prefer if this was not dynamic and was instead set to the maximum
> >> size of 'struct page' across all archs just to enhance cross-arch
> >> compatibility. I think that answer is '64'.
> >
> >
> > That still doesn't take care of the case where we add new elements to
> > struct page later. If we have struct page size changing across
> > architectures, we should still be ok as long as new size is less than what is
> > stored in pfn superblock? I understand the desire to keep it
> > non-dynamic. But we also need to make sure we don't reserve less space
> > when creating a new namespace on a config that got struct page size >
> > 64?
>
>
> How about
>
> libnvdimm/pfn_dev: Add a build check to make sure we notice when struct page size change
>
> When namespace is created with map device as pmem device, struct page is stored in the
> reserve block area. We need to make sure we account for the right struct page
> size while doing this. Instead of directly depending on sizeof(struct page)
> which can change based on different kernel config option, use the max struct
> page size (64) while calculating the reserve block area. This makes sure pmem
> device can be used across kernels built with different configs.
>
> If the above assumption of max struct page size change, we need to update the
> reserve block allocation space for new namespaces created.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>
> 1 file changed, 7 insertions(+)
> drivers/nvdimm/pfn_devs.c | 7 +++++++
>
> modified   drivers/nvdimm/pfn_devs.c
> @@ -722,7 +722,14 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>                  * The altmap should be padded out to the block size used
>                  * when populating the vmemmap. This *should* be equal to
>                  * PMD_SIZE for most architectures.
> +                *
> +                * Also make sure size of struct page is less than 64. We
> +                * want to make sure we use large enough size here so that
> +                * we don't have a dynamic reserve space depending on
> +                * struct page size. But we also want to make sure we notice
> +                * if we end up adding new elements to struct page.
>                  */
> +               BUILD_BUG_ON(64 < sizeof(struct page));

Looks ok to me. There are ongoing heroic efforts to make sure 'struct
page' does not grown beyond the size of cacheline. The fact that
'struct page_ext' is allocated out of line makes it safe to assume
that 'struct page' will not be growing larger in the foreseeable
future.

