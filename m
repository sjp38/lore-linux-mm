Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9599C31E4D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9FEC2173C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:15:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9FEC2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ACULAB.COM
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41FD76B026A; Fri, 14 Jun 2019 10:15:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A8AF6B026B; Fri, 14 Jun 2019 10:15:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2227D6B026C; Fri, 14 Jun 2019 10:15:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA9156B026A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:15:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so1873493pfj.4
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:15:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:mime-version
         :content-transfer-encoding;
        bh=8s9Y789jojRACIOdg4oE9yM9u11l1ueOEgNpAKb+nRY=;
        b=OSjeQSWkPEIKm0Qs9cK+dUaMfCta8FhKikkpwBuy7W7OSUzUys07aBn2hfx9Wn3p7+
         8FwxmI2qLs8BSgkSKBJQtGxSBxhraLGDGABtxCYevHlDSr99FAcdIJpXPYNCuUl5fVtO
         s0swKcFhEd7FUf+OfM37gKoFGwLTS6yK9y6XPuUlgNwyvosrxlfdFAKtrQ6BaaQA4RKn
         llKr0Y0GInAE4/286vI0NQm56ikJoFYsfqGRnNOBKDx9Mk9C2JURdGsVV2FUyWYNelt6
         P3btVL2IlH4Mc6S/3w7HtMC7vvg3bEh6iG8iqOkaiCv9ODesVuGVHQl1OXJnsSqOs1GX
         EMig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david.laight@aculab.com designates 146.101.78.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
X-Gm-Message-State: APjAAAWCyyB9XnLKoYokccpKrp+hCV7RXmST7xJRLG6ej1mA/Fd44FwT
	DrD3bY/+MBYz868w7sa6LJ0aQGtx+ZGeLQMr9g68XnCspP78kfwccwCbZpZYofxYFTIkyaWrkvb
	DeAcjZnbX6RZ7VaHBzVO4ECOZ/FjE3PKC2MiVNfU8iDs9PAxcnSM14GWmSSp+2EQBAg==
X-Received: by 2002:a17:90a:480a:: with SMTP id a10mr11541066pjh.57.1560521749481;
        Fri, 14 Jun 2019 07:15:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTS7GDWtwsZ53caCS9B8mqzs9Vu7H2w3L5aOCjVly054NapjZcDjW8ggjwbGhiQY5eOOeb
X-Received: by 2002:a17:90a:480a:: with SMTP id a10mr11540998pjh.57.1560521748610;
        Fri, 14 Jun 2019 07:15:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560521748; cv=none;
        d=google.com; s=arc-20160816;
        b=Ni301J+gCQ562JPSfrGDM9ApXqTg/EOokTZACPl2WXdWpeYMW2c3gEO7CVJwjKkYYI
         dXKVlTAB5Xs7o099q8neuOeawBT9G2yfFqQ3A0SzgfxWL95QLzNpKSHhslzLBOy4mp3K
         OoDscf8mMf1dKYVxDsSsjxewtbLaQT416zLeDVt4/Vr59H3BzPR7S/DGOejrN/3dMOjM
         TMb2BdpEndngqFxPmN88Z0hyTNoRVLYWXzEhcOJtDQotMjfWXbZidh/QZNf3NexJEALU
         CxMFnBehpk2MEjwZApIFqst2e6cwwy/tyvkzaH+LPierwyf7ICoHLNfOQYgBeZR5DdWv
         v6ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=8s9Y789jojRACIOdg4oE9yM9u11l1ueOEgNpAKb+nRY=;
        b=L7ytKeuZlJqayCvLwQTLcuwacB1qX4da0ny/30TarmX+NVVJPddHRVFXM1TDZRzLi0
         b9zTNHFsX7vEpiYzx9ZdupPT0bRfXunsIrNb3x9cfo2JxKq/IMB1GJB3j09/M7jeNbFC
         Qg6MnwZ9ojgVx7L4RyMlvZC9op1FzLzSqdO9CDE2vwgHlZBbfmoOJSe5K4A7quxxb2q5
         stnClgHHqtoctAenmfTAH4LVLTWHFPKB6TmT3YPXOlqgv0AEw35TgSkMvG/5BcfZkKUV
         jCT1PBwjmYn039GbRrbydPkuX9YHW508SBbbjtSzORsvQU4yhT2KACwwzxKjBqycYC6M
         yG2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david.laight@aculab.com designates 146.101.78.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [146.101.78.151])
        by mx.google.com with ESMTPS id b1si2523086pjb.92.2019.06.14.07.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 07:15:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of david.laight@aculab.com designates 146.101.78.151 as permitted sender) client-ip=146.101.78.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david.laight@aculab.com designates 146.101.78.151 as permitted sender) smtp.mailfrom=david.laight@aculab.com
Received: from AcuMS.aculab.com (156.67.243.126 [156.67.243.126]) (Using
 TLS) by relay.mimecast.com with ESMTP id
 uk-mta-171-6ZL5OlDfPHWG6RvRpXiEQg-1; Fri, 14 Jun 2019 15:15:45 +0100
Received: from AcuMS.Aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) by
 AcuMS.aculab.com (fd9f:af1c:a25b:0:43c:695e:880f:8750) with Microsoft SMTP
 Server (TLS) id 15.0.1347.2; Fri, 14 Jun 2019 15:15:44 +0100
Received: from AcuMS.Aculab.com ([fe80::43c:695e:880f:8750]) by
 AcuMS.aculab.com ([fe80::43c:695e:880f:8750%12]) with mapi id 15.00.1347.000;
 Fri, 14 Jun 2019 15:15:44 +0100
From: David Laight <David.Laight@ACULAB.COM>
To: 'Christoph Hellwig' <hch@lst.de>, Maarten Lankhorst
	<maarten.lankhorst@linux.intel.com>, Maxime Ripard
	<maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>, David Airlie
	<airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, Jani Nikula
	<jani.nikula@linux.intel.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
	"Ian Abbott" <abbotti@mev.co.uk>, H Hartley Sweeten
	<hsweeten@visionengravers.com>
CC: Intel Linux Wireless <linuxwifi@intel.com>, "moderated list:ARM PORT"
	<linux-arm-kernel@lists.infradead.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "intel-gfx@lists.freedesktop.org"
	<intel-gfx@lists.freedesktop.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "linux-wireless@vger.kernel.org"
	<linux-wireless@vger.kernel.org>, "linux-s390@vger.kernel.org"
	<linux-s390@vger.kernel.org>, "devel@driverdev.osuosl.org"
	<devel@driverdev.osuosl.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 16/16] dma-mapping: use exact allocation in
 dma_alloc_contiguous
Thread-Topic: [PATCH 16/16] dma-mapping: use exact allocation in
 dma_alloc_contiguous
Thread-Index: AQHVIrfpTFjppS25RkWUhwqPPyqZ4qabLzdw
Date: Fri, 14 Jun 2019 14:15:44 +0000
Message-ID: <a90cf7ec5f1c4166b53c40e06d4d832a@AcuMS.aculab.com>
References: <20190614134726.3827-1-hch@lst.de>
 <20190614134726.3827-17-hch@lst.de>
In-Reply-To: <20190614134726.3827-17-hch@lst.de>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.202.205.107]
MIME-Version: 1.0
X-MC-Unique: 6ZL5OlDfPHWG6RvRpXiEQg-1
X-Mimecast-Spam-Score: 0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig
> Sent: 14 June 2019 14:47
>=20
> Many architectures (e.g. arm, m68 and sh) have always used exact
> allocation in their dma coherent allocator, which avoids a lot of
> memory waste especially for larger allocations.  Lift this behavior
> into the generic allocator so that dma-direct and the generic IOMMU
> code benefit from this behavior as well.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/dma-contiguous.h |  8 +++++---
>  kernel/dma/contiguous.c        | 17 +++++++++++------
>  2 files changed, 16 insertions(+), 9 deletions(-)
>=20
> diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguou=
s.h
> index c05d4e661489..2e542e314acf 100644
> --- a/include/linux/dma-contiguous.h
> +++ b/include/linux/dma-contiguous.h
> @@ -161,15 +161,17 @@ static inline struct page *dma_alloc_contiguous(str=
uct device *dev, size_t size,
>  =09=09gfp_t gfp)
>  {
>  =09int node =3D dev ? dev_to_node(dev) : NUMA_NO_NODE;
> -=09size_t align =3D get_order(PAGE_ALIGN(size));
> +=09void *cpu_addr =3D alloc_pages_exact_node(node, size, gfp);
>=20
> -=09return alloc_pages_node(node, gfp, align);
> +=09if (!cpu_addr)
> +=09=09return NULL;
> +=09return virt_to_page(p);
>  }

Does this still guarantee that requests for 16k will not cross a 16k bounda=
ry?
It looks like you are losing the alignment parameter.

There may be drivers and hardware that also require 12k allocates
to not cross 16k boundaries (etc).

=09David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1=
PT, UK
Registration No: 1397386 (Wales)

