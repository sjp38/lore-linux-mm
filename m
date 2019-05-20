Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85042C04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 19:33:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53398216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 19:33:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="1MsSopdT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53398216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0F7A6B0003; Mon, 20 May 2019 15:33:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D98D86B0005; Mon, 20 May 2019 15:33:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C60AC6B000A; Mon, 20 May 2019 15:33:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 998836B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 15:33:30 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x27so8492611ote.6
        for <linux-mm@kvack.org>; Mon, 20 May 2019 12:33:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qGBGhJB57YNAdImoizW32uytynq+gOiiGUhFhCXS0Eg=;
        b=CwLdA9Fey9nz1P2ql3cut54mtLSxkbtMV2sAGXNOzlwhKNPK1IycvTq9i1Wng6XsPY
         UPtX9j3esbMjQQRkCkUHyprw75jwHJ/BDJL8qPebf7yPG4Ggy/kt/GWK/m4NtdKwv1YN
         YLRynaX2SZ48EV4C7pMNcOFVDCDLwt7FG748f/JcNskP4Gqxtg9NEcBDzI/QClsUQq78
         NxEh6RsDp370+VAhZ/oYb9gPm/J+7uz404CD0QtZoKgIPVL7Z4kIiwmuYHeLP9W8de2d
         fEkTcKGDfy9UxnYhlOnYiZjkyhWQduKK+W0rCifWliK6dV9cY26F4e2ht1QX27pfxxVP
         vm5A==
X-Gm-Message-State: APjAAAUV95Q2Z4oElEZA4zKco64MiIrV+C90zOxkf4QJpu5w42k2pL/7
	6tMMLr8scGqZ5xYLHARU9g6EZxQyDkweMQC8NjYIE1mP+sZ6GyT8GEBAcAMpMhLOzZDGmUzyqRu
	Y2rDCX5ZoKnaXd8pqdLmgJxJ1VEglCKoM1a44VK7kZdTpfqyPpEtzisWpvFzqEzcQpQ==
X-Received: by 2002:a05:6808:18e:: with SMTP id w14mr662962oic.72.1558380810281;
        Mon, 20 May 2019 12:33:30 -0700 (PDT)
X-Received: by 2002:a05:6808:18e:: with SMTP id w14mr662914oic.72.1558380809654;
        Mon, 20 May 2019 12:33:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558380809; cv=none;
        d=google.com; s=arc-20160816;
        b=bj2reD7Q197aLvJeGBVeMNOYa8zTpzTJLwxWp2O6HEvopa1FhhtdNeuhp/M8vnxPhP
         aOn98VWwEBLtqEwfMGmI3DC223t3Ipry1sUIzn8Dt8H7h4P3epRQghOBPe0NppjXlaeo
         yj0KSyOgVF5mrabo9upsnFLOMcMkeCPyCI3yizn5QZicbOGUIJsW1Kn3CZ4zaGbAPow8
         NVwVkFlZQE7LqQ63OZJfLsNk78RZ0Q6TReqzB/VDN6iZfAHFCe9HKhiX75yD0OD0Ffbq
         Ll+3pxvIL0LdGojFmL23S9LxaMPJtL7kwnwXlggGaadUWYGuBjGWc0VUf1eTlVDoKH1a
         4NKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qGBGhJB57YNAdImoizW32uytynq+gOiiGUhFhCXS0Eg=;
        b=eVyzUbMAHuN551iwoIqYsM3ltya04WM8XK7bs+vzr6eycPVo8+KS2TnDtMyTVHU58k
         uvTr7R7SaUsrkptBBOQk8fQ8wS4zKw+bzFgWj8eXc2FLtuBya1N/9Efzo/1Bu7Ho4ZKI
         lSOziqN5XH0loa0PUoaMX/Yv27SV5gPtp0UQV5RDQKyZJEESMUzUX/wWBaqCB6YtOQCK
         +gx0+KPnyR7Roly4ZKytia6/3ATDbqvnXlYJvqa9eUX3ejs5WtPaBGN/BztTwBBh3PXA
         X9WltUhJ2AalQ01V6Qrqjg4Zvily/NrIhvKvwk73tf2DF4toByZUP3LZQRE3N7g3ZpZ6
         Bpug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1MsSopdT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10sor8583970otp.124.2019.05.20.12.33.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 12:33:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1MsSopdT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qGBGhJB57YNAdImoizW32uytynq+gOiiGUhFhCXS0Eg=;
        b=1MsSopdTCsKraANCSKqF8PkxUMuTUoIUX0XO+JfoxkweztyYhtzTmIQcE8sdcRWVP1
         Fg0I2uWxd6AfxohwPY4dVXOa5GSrBd8YuEgTpyjwQpaQMvUX5RMIyltCY8N1R74raqPP
         HjA8UzJ7Ok893kpAWJGplsaQ4/xqw/FC5u845MKOBoIRlf9j8440PEUtUsmBKg35J779
         oHgEefa+u6KkVzFDKrK9tMjfHTnogbSN9rtWs3uV3aH9slC9uklwamdRB6ILUVg5w8IA
         VFVQPjlq3w7YXuc88iwUhcMwzR5Fum0dqGybPoNp6dlZXnkXWg9APZOq/w6S85LcVRwe
         sc/Q==
X-Google-Smtp-Source: APXvYqxLMFozNV6q34tnpQxP/V7RDYkIWBzc4fvMUALsYjtMGCEcUw5ebnzdkghF4wJZ7BssXKYTwlfrdTh73iXn4bA=
X-Received: by 2002:a05:6830:1182:: with SMTP id u2mr34896558otq.71.1558380809245;
 Mon, 20 May 2019 12:33:29 -0700 (PDT)
MIME-Version: 1.0
References: <1558089514-25067-1-git-send-email-anshuman.khandual@arm.com>
 <20190517145050.2b6b0afdaab5c3c69a4b153e@linux-foundation.org>
 <cb8cbd57-9220-aba9-7579-dbcf35f02672@arm.com> <20190520192721.GA4049@redhat.com>
In-Reply-To: <20190520192721.GA4049@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 20 May 2019 12:33:17 -0700
Message-ID: <CAPcyv4gN0Pz66a_dEMxkS5xvCyPoboGEkyxZFHQU3L2DDj8fAg@mail.gmail.com>
Subject: Re: [PATCH] mm/dev_pfn: Exclude MEMORY_DEVICE_PRIVATE while computing
 virtual address
To: Jerome Glisse <jglisse@redhat.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Laurent Dufour <ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 12:27 PM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Mon, May 20, 2019 at 11:07:38AM +0530, Anshuman Khandual wrote:
> > On 05/18/2019 03:20 AM, Andrew Morton wrote:
> > > On Fri, 17 May 2019 16:08:34 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> > >
> > >> The presence of struct page does not guarantee linear mapping for the pfn
> > >> physical range. Device private memory which is non-coherent is excluded
> > >> from linear mapping during devm_memremap_pages() though they will still
> > >> have struct page coverage. Just check for device private memory before
> > >> giving out virtual address for a given pfn.
> > >
> > > I was going to give my standard "what are the user-visible runtime
> > > effects of this change?", but...
> > >
> > >> All these helper functions are all pfn_t related but could not figure out
> > >> another way of determining a private pfn without looking into it's struct
> > >> page. pfn_t_to_virt() is not getting used any where in mainline kernel.Is
> > >> it used by out of tree drivers ? Should we then drop it completely ?
> > >
> > > Yeah, let's kill it.
> > >
> > > But first, let's fix it so that if someone brings it back, they bring
> > > back a non-buggy version.
> >
> > Makes sense.
> >
> > >
> > > So...  what (would be) the user-visible runtime effects of this change?
> >
> > I am not very well aware about the user interaction with the drivers which
> > hotplug and manage ZONE_DEVICE memory in general. Hence will not be able to
> > comment on it's user visible runtime impact. I just figured this out from
> > code audit while testing ZONE_DEVICE on arm64 platform. But the fix makes
> > the function bit more expensive as it now involve some additional memory
> > references.
>
> A device private pfn can never leak outside code that does not understand it
> So this change is useless for any existing users and i would like to keep the
> existing behavior ie never leak device private pfn.

The issue is that only an HMM expert might know that such a pfn can
never leak, in other words the pfn concept from a code perspective is
already leaked / widespread. Ideally any developer familiar with a pfn
and the core-mm pfn helpers need only worry about pfn semantics
without being required to go audit HMM users.

