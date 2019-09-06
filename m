Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68036C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:25:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C1F02070C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:25:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bgqPFZOd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C1F02070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEDE76B000C; Fri,  6 Sep 2019 11:25:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B782F6B026B; Fri,  6 Sep 2019 11:25:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3F336B026C; Fri,  6 Sep 2019 11:25:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0098.hostedemail.com [216.40.44.98])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7246B000C
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:25:56 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 32041824CA20
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:25:56 +0000 (UTC)
X-FDA: 75904871112.25.run82_50d8716789239
X-HE-Tag: run82_50d8716789239
X-Filterd-Recvd-Size: 5401
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:25:55 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id s21so13628177ioa.1
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 08:25:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=N3FQEUSrBcDUfBeBfn5iCz+oSEqlloCS/pOKCoa2Zr0=;
        b=bgqPFZOdreq6PKuwjn62NrUjiulsqs09d/Gb8LjLNEs9G7HSU/RYbrcusE7+j93bbt
         ZNsiZhnSpiVn4xshXGTOP41Zhh95aNeL6YoFa4FzsIe4j81n7vD4tXH/11gzKEMpbsWG
         sODjHkkbKsQhVeBDNX0+hFtrjw8zAjfPhVHcKf0zbVkHuqfr+UUXFofddBouEiQhNFQc
         h5lD1fsFu5fy1FMAXTqksih7B3M/LRJrZKA8nyi2MKYfIY0EF76p3ur4BAidhBzLdOfN
         qMUoNboAFq7Ftys58HMDjwz72VDg0e7C72Gs5afM6ENseG/z+X5YA6JPCfMSOoUDsoE0
         z0Og==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=N3FQEUSrBcDUfBeBfn5iCz+oSEqlloCS/pOKCoa2Zr0=;
        b=M8+m9v594l40z2h1fHKDNuDAYnvJwSQeVOVUITrDVCRProhhOQQs36lsmicM7yemxd
         nDC+i6IWPVH3abSl3s3Gg262z/XnSut1HeGyG+3dMSWUSGa5rjQpmVKBY4xe4W+IoXBi
         9YJ3dZzEVFvL/uQUVbVNd+GW4ly4mX+cW4ZmeQl1+aA52ow+1GI5AenIzR+GzzClvmaW
         k9Gjgp7oEL5QzTnfEKucKKk8cQEV+xOtG3jFvs9z6Eni4lCz7NQAymDqpVxLg82BlUDA
         Vl5RMcu1PdewtAiskELdTR1iDSz9PM/jCQDaSn5JBt1Q5dC+YmnqhMRtT7qdZWfsbYW3
         Ixfw==
X-Gm-Message-State: APjAAAU2qY9oBbfGxNmhE6QQ32Ax/ostGBox95nhXkCAec/rmNrQz2wx
	U9SnIMcetQecWTEX/VQtn+g2LHqE4eGloz8ngpQ=
X-Google-Smtp-Source: APXvYqwcGzRHOiIe83l2KSz9xAxgf3rf+jrakAFe9L11I466Xd43WAGC5SKvXq6IpFJAS6PXb2pvUJF/d3rtHSR26Kw=
X-Received: by 2002:a5d:8908:: with SMTP id b8mr11171098ion.237.1567783554482;
 Fri, 06 Sep 2019 08:25:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190906145213.32552.30160.stgit@localhost.localdomain> <20190906112155-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190906112155-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 6 Sep 2019 08:25:43 -0700
Message-ID: <CAKgT0UcXLesZ2tBwp9u05OpBJpVDFL61qX9Qpj7VUqdRqw=U_Q@mail.gmail.com>
Subject: Re: [PATCH v8 0/7] mm / virtio: Provide support for unused page reporting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, 
	Oscar Salvador <osalvador@suse.de>, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 6, 2019 at 8:23 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Fri, Sep 06, 2019 at 07:53:21AM -0700, Alexander Duyck wrote:
> > This series provides an asynchronous means of reporting to a hypervisor
> > that a guest page is no longer in use and can have the data associated
> > with it dropped. To do this I have implemented functionality that allows
> > for what I am referring to as unused page reporting
> >
> > The functionality for this is fairly simple. When enabled it will allocate
> > statistics to track the number of reported pages in a given free area.
> > When the number of free pages exceeds this value plus a high water value,
> > currently 32, it will begin performing page reporting which consists of
> > pulling pages off of free list and placing them into a scatter list. The
> > scatterlist is then given to the page reporting device and it will perform
> > the required action to make the pages "reported", in the case of
> > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > and as such they are forced out of the guest. After this they are placed
> > back on the free list, and an additional bit is added if they are not
> > merged indicating that they are a reported buddy page instead of a
> > standard buddy page. The cycle then repeats with additional non-reported
> > pages being pulled until the free areas all consist of reported pages.
> >
> > I am leaving a number of things hard-coded such as limiting the lowest
> > order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
> > determine what the limit is on how many pages it wants to allocate to
> > process the hints. The upper limit for this is based on the size of the
> > queue used to store the scattergather list.
>
> I queued this  so this gets tested on linux-next but the mm core changes
> need acks from appropriate people.

Thanks. I will see what I can do to get some more mm people reviewing
these changes.

- Alex

