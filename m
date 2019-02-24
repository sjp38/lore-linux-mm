Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D505C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 20:07:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F0BB20651
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 20:07:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F0BB20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF4AF8E0168; Sun, 24 Feb 2019 15:07:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7BB38E0167; Sun, 24 Feb 2019 15:07:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96C4B8E0168; Sun, 24 Feb 2019 15:07:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6760C8E0167
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 15:07:16 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id s18so3168015oie.19
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 12:07:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=Y0IqkcdgngY/YGpOiQL7ywzKAqFIW/9T4EnT6V1cf8g=;
        b=iFKZziyknNgbM1Yr027s5kbqlpkeV0DAshTQxQ95DcxrwSvvACoji8z7X4v+gEAgCR
         GZwJow1gVPY9zhybLiBwkxxwM83o55r6mGI9D2uO2VKr8wUexmlBwoQdR6Wsp4oFMXRg
         S1n3DoLoo9eg9qjVANbMH+4ztZpVVnVoc8NqhOa3ajN7LoHa4c85PP80HP12gSWBfYBA
         /9gBHognderQskJeSkDM59wWaR3u84lItXnSMdTy4ZiKzkwJU5hdkn0v3PHIUjZUTm9p
         VQI+Vt62vytwWZetfhW7SVfrtQ9QgvULm3ZhegiN4nQKiNSZ0qITtoi0lb+UTa7Fz7xK
         u3XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYxEC19n/MHOe85RdVsd8JASiXjCVJ1lcMYjiaL0GZARDS7oQPg
	RGt5ZxwLq/fezycSDOWTU4eBG62Z2sBz5Mh/nGNh3j0umOYTDe3+eBSa/nys6nEIPY7e9cjJjql
	/gbAaU3S78IwemysOnkm1kxFIDoGev45GpiVRp836Bgct4eNtp1JOR24p97Apj6ZS3f1rI/KAy2
	4seGmsCupVOvksu/bOJPBoOo7vNCkXFgJpiUgk+tbtC8tRkRbNYC7Uadsq6gFo2ErY3ahRCpOGG
	c7rrgFpSEOftvuDqTr0BN8bU7Xf8P97SxVgeX+nhQ8uzoVZgPv65mSrRQCk0ela1dleqp2sBmH6
	H0ruIlQ680qNqyXT819oIENpho5AIGF/LT5JeZ2VlPJukcbgorogE+hMQZuhn5nnpaPL5gGI8Q=
	=
X-Received: by 2002:a9d:7b49:: with SMTP id f9mr9233651oto.211.1551038836073;
        Sun, 24 Feb 2019 12:07:16 -0800 (PST)
X-Received: by 2002:a9d:7b49:: with SMTP id f9mr9233616oto.211.1551038835194;
        Sun, 24 Feb 2019 12:07:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551038835; cv=none;
        d=google.com; s=arc-20160816;
        b=LETaLEQM03MYYxOltX5rtFDmY2xUWaUbueVgo3uPNf4FHaJELAPs0bwJo4HuqEQRsB
         HbxkBtYCI3gbFob7fLU4GH2LsRXbNjtgNx133PnqMT6BHnS9vH0kjkTlJ5fO6LGfYQKD
         P06sOkGUto7nLb2Guxqj2fTefOqwhJsQ+XNRP/rU5aEEWP4tzRcAPZgEPEQiJX/ecMRz
         KuR9LB8MX/rjhYAMN05AYPHqAEiKryVwH8h10Pbx7NcpfWoeIY6Ctn4ETR0NVgHBAlDl
         d66ubNvC2NG7F78FemNGf8et5QyKpuo/KBf3ztKJE8D2qkU+Oio2WJxcPdCtyR9jmCxm
         YqTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=Y0IqkcdgngY/YGpOiQL7ywzKAqFIW/9T4EnT6V1cf8g=;
        b=HaqBajKLKHk06RYID+oXncXvsSdiwb1jKNyN6UOM4Q9WJ3DhDiZVzmcnR3V3WsrAbj
         jbxU81ERFv+Az8p9rRWWGmzqypFMCK8nFwo9Ku9kgzp57nrYxAP21na7FEy2EbM6HkX3
         tyHIUKdWyECCwekRiiePgq/OZhfiGYccAyiemuJY0omE8sre5tregLjgDCEtx+C+JOR/
         1QMxki1UaqOmbUzHKz+esxRSIvw7krBYDGuYsqiRRct2UQxJM4QbzDHHcCtJY8Fr6+fY
         ueOOOsW0eNxyDbO5/UnQ5kMHBWSqgVnbuYC24+LLaqCge0+kknVerCpTuzB9dRtR94ML
         460w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g25sor3898095otl.124.2019.02.24.12.07.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 12:07:15 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IaHNS0WJfmSh2GiAwYr+yAYriNEsAvhKyb20CHj7QW3/rrWdSxXlK3Ty5fEaxR2f/Qsz2WXeKqI25AUWRh0+Lk=
X-Received: by 2002:a9d:7cd3:: with SMTP id r19mr9880945otn.139.1551038834827;
 Sun, 24 Feb 2019 12:07:14 -0800 (PST)
MIME-Version: 1.0
References: <20190214171017.9362-1-keith.busch@intel.com> <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
 <20190222184831.GF10237@localhost.localdomain> <CAPcyv4jpP0CP-QxWDc_E1QwL736PLwh8ZPrnKJzVnYrAk++93g@mail.gmail.com>
In-Reply-To: <CAPcyv4jpP0CP-QxWDc_E1QwL736PLwh8ZPrnKJzVnYrAk++93g@mail.gmail.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Sun, 24 Feb 2019 21:07:03 +0100
Message-ID: <CAJZ5v0gyEJ59qSno_MKjr97zeYaLp=v1=ZYz1twM1eZJCP_DTw@mail.gmail.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
To: Dan Williams <dan.j.williams@intel.com>
Cc: Keith Busch <keith.busch@intel.com>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 8:21 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Fri, Feb 22, 2019 at 10:48 AM Keith Busch <keith.busch@intel.com> wrote:
> >
> > On Wed, Feb 20, 2019 at 11:02:01PM +0100, Rafael J. Wysocki wrote:
> > > On Thu, Feb 14, 2019 at 6:10 PM Keith Busch <keith.busch@intel.com> wrote:
> > > >  config ACPI_HMAT
> > > >         bool "ACPI Heterogeneous Memory Attribute Table Support"
> > > >         depends on ACPI_NUMA
> > > > +       select HMEM_REPORTING
> > >
> > > If you want to do this here, I'm not sure that defining HMEM_REPORTING
> > > as a user-selectable option is a good idea.  In particular, I don't
> > > really think that setting ACPI_HMAT without it makes a lot of sense.
> > > Apart from this, the patch looks reasonable to me.
> >
> > I'm trying to implement based on the feedback, but I'm a little confused.
> >
> > As I have it at the moment, HMEM_REPORTING is not user-prompted, so
> > another option needs to turn it on. I have ACPI_HMAT do that here.
> >
> > So when you say it's a bad idea to make HMEM_REPORTING user selectable,
> > isn't it already not user selectable?
> >
> > If I do it the other way around, that's going to make HMEM_REPORTING
> > complicated if a non-ACPI implementation wants to report HMEM
> > properties.
>
> Agree. If a platform supports these HMEM properties then they should
> be reported.

Well, I'm not sure if everybody is in agreement on that.

> ACPI_HMAT is that opt-in for ACPI based platforms, and
> other archs can do something similar. It's not clear that one would
> ever want to opt-in to HMAT support and opt-out of reporting any of it
> to userspace.

In my view, ACPI_HMAT need not be an opt-in in the first place.  The
only reason to avoid compiling HMAT parsing it would be if there were
no users of it in the kernel IMO.

