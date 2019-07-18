Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48814C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:45:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07AC221849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:45:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="PzoghoiU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07AC221849
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97B3D8E0007; Thu, 18 Jul 2019 12:45:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 903148E0005; Thu, 18 Jul 2019 12:45:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CA938E0007; Thu, 18 Jul 2019 12:45:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4F58E0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:45:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n3so20319462edr.8
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:45:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=KgRfHejv/zIzuUta64QTdW+DJVmqS0zjC4X90cCy9QI=;
        b=J8UO/fCgK8vhb0rZk+unWnpf2FxiNU+RxGdzlRY24R19k2FEzQbiEjl7jfvZQfqIDa
         mzM3NO4Tx6KiymvDQ0pmmFDLdJq7dqV8XsA6lt/hqNWGktfLV7IyQEKP2cAmEL+VEzad
         dqN38H7009+aYJLLaPcbSWkwqf+58xIfSxLd3GaiSUorEgfp+46bIW8kAckkfFp6Ps49
         h2SU+O3EWXbTM92JXwWk7cTdsQ7rsxCVbPXJyZ/EUTrWXtKjpSy0ZSUQHlw9pnLqGm5m
         ErxuXET0x7xwdX36a6QOGPFBBdS7q7Ee7fZ+Nac9PrbUYPH/dzUuRsteXAIsEY/r63ha
         42Vw==
X-Gm-Message-State: APjAAAVuRt4bBIgC5pZon8MyGAkXCRVWtQsSNoKFZcS80zV1j+XCVj8i
	+4bQnWMiFYFeAZgu7rPvr1Jk1U7+1yIbD0aDzp03tLhtJKErouZWSmrJbSxlLIP5tXZs+qK29uN
	RsIvcmNgAimudRfbuT2Y2xUg3W4mdk7gEWDpMf/gVgOH3+4xtQ/WNWYwjBQ9Xsc27sQ==
X-Received: by 2002:a50:c081:: with SMTP id k1mr41483981edf.19.1563468348762;
        Thu, 18 Jul 2019 09:45:48 -0700 (PDT)
X-Received: by 2002:a50:c081:: with SMTP id k1mr41483916edf.19.1563468348157;
        Thu, 18 Jul 2019 09:45:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563468348; cv=none;
        d=google.com; s=arc-20160816;
        b=w7FfSKVYpDa9V8+uhIVK2spB1i7WPns5Xam9aW9fGTC6YFLoK/H2DkUtfTO53uVdxh
         5jmGqlZnBOxPke8qUSuI2iSFoJFZb/VFvRwANp75vw+s3mbNuZ8zKZFHQ1fK2l62eihV
         OVnkHaOQZLzJnVaw9zkHEvrtzG2utYIxUSorJA5K2TTs8qOjw/KzBQvjfV+Yrz7l/j2c
         6kT/i0doPh38lHSH0KETWQR/UcZ+ZOMhHfc1wh9BNMNCX6961Hz66szq/Q/Txpml1kIJ
         yXFd1p6K4LgvbyTTFRf10zC3ReHIsrB4oo1Yfe//+ket4qPSTknKKUo8I6cjCoN9X3/J
         H1vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=KgRfHejv/zIzuUta64QTdW+DJVmqS0zjC4X90cCy9QI=;
        b=mYEdE3WUR1pUWtq57bIYoJJG7tQMrOwCgXPyHwLisvpJVldzTgQ+Zr1YlfCIIbBlFb
         W74aPLBt9Gz21PAZgLRmuLjbZ9cfVUbWAB4CjuqbzqKuOlW751ub9dn/NIDaPsMxniTT
         ZkFTu/TbIpeK3qMrW98b8O3xtAM09ZXxpZPO6olXhlxc8AOk0+5MyMuxCT595xEyzLWa
         6gXs1y3lkIizxiy6TsP2JfztvEUrHl4iJIGHNwmIASvxRGa/5d3gqQ6rFblwRn4PTIC7
         WIGFvz/k+KeBd4+7hEk5wi7oPk1JWyFGH9XqmlibyQxP3k3t9Ksiq9ygyICkbvBhBPQn
         yjBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=PzoghoiU;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b16sor9285890ejd.61.2019.07.18.09.45.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 09:45:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=PzoghoiU;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=KgRfHejv/zIzuUta64QTdW+DJVmqS0zjC4X90cCy9QI=;
        b=PzoghoiUeT+cfTCoJNBcMdcHj4lUEnnKPdIB0RIR7UfIhBNExY45DGUWwEb6VInVhX
         cdfKfmcchZblLxSSZF5AFrMDhwPcAlqFPUCLjsX8x8+8Zcs2u2GmFaiF1ECh4v8PQ2F8
         j4HhGExKdqzRvuS2Dl4OmXpajh5psO9uuIZTpdM7O5nZPeYs4yVRzt8mIMiynp96OWiC
         uDolhH6hlq7pA1VxLsr2gjfo3hvLExYypRB7JfUrW4J1IQdRCAoGrAG5ih/r8aFRnlxJ
         PBn48/MCV1UMTY8QGKa/jew7xYNxn6sUpCvfRcBqSKGRUcEPnUkv/zraQfpIgkIpixCd
         ortg==
X-Google-Smtp-Source: APXvYqxFDf5VCS9acxFCu5q7BESVni3L/MJZz4NoBB7LBP3pSJFBG6PopXkq/zkj8QMkeiPsyBwKVx67bKcjyYdDtg4=
X-Received: by 2002:a17:906:9447:: with SMTP id z7mr37111939ejx.165.1563468347812;
 Thu, 18 Jul 2019 09:45:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190718024133.3873-1-leonardo@linux.ibm.com> <CA+CK2bBu7DnG73SaBDwf9cBceNvKnZDEqA-gBJmKC9K_rqgO+A@mail.gmail.com>
 <6cd8f8f753881aa14d9dfec9a018326abc1e3847.camel@linux.ibm.com>
In-Reply-To: <6cd8f8f753881aa14d9dfec9a018326abc1e3847.camel@linux.ibm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 18 Jul 2019 12:45:36 -0400
Message-ID: <CA+CK2bA9_B8siPCSSdrN_yecGZZy82UNx7P=QK8N5GuPjto1HQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in ZONE_MOVABLE
To: Leonardo Bras <leonardo@linux.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Pasha Tatashin <Pavel.Tatashin@microsoft.com>, 
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 12:04 PM Leonardo Bras <leonardo@linux.ibm.com> wro=
te:
>
> On Thu, 2019-07-18 at 08:19 -0400, Pavel Tatashin wrote:
> > On Wed, Jul 17, 2019 at 10:42 PM Leonardo Bras <leonardo@linux.ibm.com>=
 wrote:
> > > Adds an option on kernel config to make hot-added memory online in
> > > ZONE_MOVABLE by default.
> > >
> > > This would be great in systems with MEMORY_HOTPLUG_DEFAULT_ONLINE=3Dy=
 by
> > > allowing to choose which zone it will be auto-onlined
> >
> > This is a desired feature. From reading the code it looks to me that
> > auto-selection of online method type should be done in
> > memory_subsys_online().
> >
> > When it is called from device online, mem->online_type should be -1:
> >
> > if (mem->online_type < 0)
> >      mem->online_type =3D MMOP_ONLINE_KEEP;
> >
> > Change it to:
> > if (mem->online_type < 0)
> >      mem->online_type =3D MMOP_DEFAULT_ONLINE_TYPE;
> >
> > And in "linux/memory_hotplug.h"
> > #ifdef CONFIG_MEMORY_HOTPLUG_MOVABLE
> > #define MMOP_DEFAULT_ONLINE_TYPE MMOP_ONLINE_MOVABLE
> > #else
> > #define MMOP_DEFAULT_ONLINE_TYPE MMOP_ONLINE_KEEP
> > #endif
> >
> > Could be expanded to support MMOP_ONLINE_KERNEL as well.
> >
> > Pasha
>
> Thanks for the suggestions Pasha,
>
> I was made aware there is a kernel boot option "movable_node" that
> already creates the behavior I was trying to reproduce.

I agree with others, no need to duplicate this functionality in a
config, and Michal in a separate e-mail explained the reasons why we
have MEMORY_HOTPLUG_DEFAULT_ONLINE.

>
> I was thinking of changing my patch in order to add a config option
> that makes this behavior default (i.e. not need to pass it as a boot
> parameter.
>
> Do you think that it would still be a desired feature?
>
> Regards,
>
> Leonardo Br=C3=A1s

