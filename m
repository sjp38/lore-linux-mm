Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B686BC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:29:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5328520844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:29:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BE9/o/N5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5328520844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C845F8E0002; Tue, 29 Jan 2019 16:29:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C31388E0001; Tue, 29 Jan 2019 16:29:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B21CC8E0002; Tue, 29 Jan 2019 16:29:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB6A8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:29:12 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id h11so8555815wrs.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:29:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=z3ULGENtuqL5tguf/8dKX/9QWEPMLkVQYxE/Khek8q0=;
        b=s0EUBs4+jPdocxGOa1Zo4w5nFFI76ormEMaC/yAxuJYTG21fHN4SJZdZSvrc7fW5Im
         Kp9qF40ihy0WzjBlwLBpapysSoEeCQZM20qXMOLNAGAPtXOHaMg5YEwzCHtOaNbM6Ey4
         841nq+3e0pbgylf1SR28R0zpuEe25xcolVFzK9XDNNid8SKfnERBi091GSoRZdxZsKIt
         TKKaCsTsq1rCrHFGpvvukFUqhe+twJOVFgCsO8g127NlefrWBw0mI0B9K1tiZ+bT2lym
         Bf2IQ3lwhP2KR81QzgpM2crRr2mnzi5RlyK6TKJtPtYtSF4XEeVhjXgzU7S303nBiGFI
         NghA==
X-Gm-Message-State: AJcUukcStCAYcJ3y+0w5G3uTxh/C9s2R3ZeSy1gDORTeKbauzM6hbj1r
	v7tkzl8azBmKidvkCZbS3DzaGmT1QWqIi3aiVm73ePPsfauLFu8cU+hXnp6xH7lV1lHnWVqN7u8
	dc5MqRbn1ACPKmw3dEt6rgBESZuIyfp7rG18B6nqOfDiz1oFbJ8EfPtnw5BM+qq2T0qZzR0etbD
	I6nQ306qrIINJi95o78CdPmmYyhmBTU0VGdjo4vusx19gWmb1d17Rjz6viAPACa/BN/gG9OeHva
	GdOal44cNVeEHrWjcJiPx1+U7sXoY92nw9Y2JWVFo4HSDyDukI6cTdFoaj+pGRoGls+fXuymCBB
	HgkochmRFdiEHD4MamCYtFw2ci28EuE5/kLRJolPPUAcooA7Xi/FXBx65SrQ4TOI25J60NZQ/OT
	c
X-Received: by 2002:a1c:9a0d:: with SMTP id c13mr23397933wme.41.1548797351789;
        Tue, 29 Jan 2019 13:29:11 -0800 (PST)
X-Received: by 2002:a1c:9a0d:: with SMTP id c13mr23397892wme.41.1548797350862;
        Tue, 29 Jan 2019 13:29:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548797350; cv=none;
        d=google.com; s=arc-20160816;
        b=v6+W5YV1q4mCsm4qhLiDm6BhZTDpMw0LNmsmi4pq8yQnKNDAya3tvyH5E2qKNzD98h
         BvA3n3OjDVMNFJ5IWNhgaI7yrqBN1rGKmlBw9yokMBYcNAcnAXwJAbhVH5Lw4O7Ej7W9
         /aeYNp/VS7thSSYwJI3oU8D36jbkuT4R6/hAYWNERVkxH5NTnsS2IPWl5PCDeLDMAA0b
         7u4eeRi4r00vW1w/bEaYLKn58TmzZfQhwhy0qFyulHz0b05xGNGf7+MiGak27s7Evo1I
         Mvu05RjjKvjsEz/CXBwMOFXNnLON2NaY9J9dJNGalr2WPaKVih8TGBZdAW3WTADFWKUt
         dtZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=z3ULGENtuqL5tguf/8dKX/9QWEPMLkVQYxE/Khek8q0=;
        b=mSRBx+gcBiHtGMoLSkhh4OR033sgKwsKM/HwGtjXk6kKIruQiOghm+c37pi9JpYHXy
         0JGB4ZRsAkcf43J0TQ1zuPaQOXpITpM2vXscox1aIW+h+epLM1jCZ9dUA7jxw2nnCtjS
         S4YIewEGofYmyP23dwxrsqTdDvlvEx9goGOGWIMDS5T7To4QwZlJ1W7VmfVvu871a52h
         VaSG9KzbeV//87FDnjiPwpFUVXbsms8n9HPKGLz55fZhTg0+k1zN/z9Rxz9hMyMyZ0mt
         VSdPsBKkV7rd/zPQoefuIQVnmXrTqWvY4wlyQ8DQdg/79JH9TNhFH/13awkJ1h4TCJTD
         5ajg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BE9/o/N5";
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j30sor81327130wrd.23.2019.01.29.13.29.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 13:29:10 -0800 (PST)
Received-SPF: pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BE9/o/N5";
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=z3ULGENtuqL5tguf/8dKX/9QWEPMLkVQYxE/Khek8q0=;
        b=BE9/o/N5/jPw61vFbCALWK6WGrmrDJnuNbyw+0eBRu9kl8/mJdGZbhnoC519Q6v0vN
         pfouBi1cLQPNO4tlcu51UrzZ/cG65MblzRN8snO+yQNiq6Kt0dgdwK6rPLEg6gGIavD9
         RSe85gbDSyA7AWnhpbuo76EL5wJQIiSFZV6AScHhbk5kX/F7ZsS7U8IP1lT3pG+Wcpmb
         FqicFEYoajuKenDYi4jlHLwMJoss9n47tcIES5sRFnlRMT+GelIJzjtNeIgUUpO49Lgp
         K4nhu+OtQ9H9/Wi9pK6hPEnW8Z+0ZYgIljy/BsHoYjz4AsBp6I48/ljOQObddstEENGc
         eUMA==
X-Google-Smtp-Source: ALg8bN4oqlozqvBx62ZOKCap1Q/HPcNNVezF3INCpbFnWNa8lhuzX+yfDeJxf3h2fdiUfk76PHTMpUi7jABP0nz7gLo=
X-Received: by 2002:adf:d0c9:: with SMTP id z9mr26313114wrh.317.1548797350317;
 Tue, 29 Jan 2019 13:29:10 -0800 (PST)
MIME-Version: 1.0
References: <20190129174728.6430-1-jglisse@redhat.com> <20190129174728.6430-2-jglisse@redhat.com>
 <CADnq5_N8QLA_80j+iCtMHvSZhc-WFpzdZhpk6jR9yhoNoUDFZA@mail.gmail.com> <83acb590-25a5-f8ae-1616-bdb8b069fa0f@deltatee.com>
In-Reply-To: <83acb590-25a5-f8ae-1616-bdb8b069fa0f@deltatee.com>
From: Alex Deucher <alexdeucher@gmail.com>
Date: Tue, 29 Jan 2019 16:28:57 -0500
Message-ID: <CADnq5_NOm8DkHWCw-s9B4+n=9qezS8kg9TXDK0fz9nP1vFB+mw@mail.gmail.com>
Subject: Re: [RFC PATCH 1/5] pci/p2p: add a function to test peer to peer capability
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Joerg Roedel <jroedel@suse.de>, "Rafael J . Wysocki" <rafael@kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Christoph Hellwig <hch@lst.de>, 
	iommu@lists.linux-foundation.org, Jason Gunthorpe <jgg@mellanox.com>, 
	Linux PCI <linux-pci@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, 
	Robin Murphy <robin.murphy@arm.com>, Christian Koenig <christian.koenig@amd.com>, 
	Marek Szyprowski <m.szyprowski@samsung.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 3:25 PM Logan Gunthorpe <logang@deltatee.com> wrote=
:
>
>
>
> On 2019-01-29 12:56 p.m., Alex Deucher wrote:
> > On Tue, Jan 29, 2019 at 12:47 PM <jglisse@redhat.com> wrote:
> >>
> >> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> >>
> >> device_test_p2p() return true if two devices can peer to peer to
> >> each other. We add a generic function as different inter-connect
> >> can support peer to peer and we want to genericaly test this no
> >> matter what the inter-connect might be. However this version only
> >> support PCIE for now.
> >>
> >
> > What about something like these patches:
> > https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=3Dp2p&id=3D4f=
ab9ff69cb968183f717551441b475fabce6c1c
> > https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=3Dp2p&id=3Df9=
0b12d41c277335d08c9dab62433f27c0fadbe5
> > They are a bit more thorough.
>
> Those new functions seem to have a lot of overlap with the code that is
> already upstream in p2pdma.... Perhaps you should be improving the
> p2pdma functions if they aren't suitable for what you want already
> instead of creating new ones.

Could be.  Those patches are pretty old.  They probably need to be
rebased on the latest upstream p2p stuff.

Alex

