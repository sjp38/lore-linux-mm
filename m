Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D67E6B02C3
	for <linux-mm@kvack.org>; Tue, 23 May 2017 21:55:14 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g55so64180404qtc.8
        for <linux-mm@kvack.org>; Tue, 23 May 2017 18:55:14 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id j12si23358943qta.322.2017.05.23.18.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 18:55:13 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id l39so24645146qtb.1
        for <linux-mm@kvack.org>; Tue, 23 May 2017 18:55:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170522165206.6284-1-jglisse@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 24 May 2017 11:55:12 +1000
Message-ID: <CAKTCnzn2rTnqq62JY3GfAd7SCv1PChTrHSB6ikJzdjNzXC9cGA@mail.gmail.com>
Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v22
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>

On Tue, May 23, 2017 at 2:51 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.co=
m> wrote:
> Patchset is on top of mmotm mmotm-2017-05-18, git branch:
>
> https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-v22
>
> Change since v21 is adding back special refcounting in put_page() to
> catch when a ZONE_DEVICE page is free (refcount going from 2 to 1
> unlike regular page where a refcount of 0 means the page is free).
> See patch 8 of this serie for this refcounting. I did not use static
> keys because it kind of scares me to do that for an inline function.
> If people strongly feel about this i can try to make static key works
> here. Kirill will most likely want to review this.
>
>
> Everything else is the same. Below is the long description of what HMM
> is about and why. At the end of this email i describe briefly each patch
> and suggest reviewers for each of them.
>
>
> Heterogeneous Memory Management (HMM) (description and justification)
>

Thanks for the patches! These patches are very helpful. There are a
few additional things we would need on top of this (once HMM the base
is merged)

1. Support for other architectures, we'd like to make sure we can get
this working for powerpc for example. As a first step we have
ZONE_DEVICE enablement patches, but I think we need some additional
patches for iomem space searching and memory hotplug, IIRC
2. HMM-CDM and physical address based migration bits. In a recent RFC
we decided to try and use the HMM CDM route as a route to implementing
coherent device memory as a starting point. It would be nice to have
those patches on top of these once these make it to mm -
https://lwn.net/Articles/720380/

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
