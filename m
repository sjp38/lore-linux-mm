Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B567C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:22:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C89720848
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:22:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="le6/IjvK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C89720848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD40E6B0003; Fri, 17 May 2019 13:22:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5C286B0005; Fri, 17 May 2019 13:22:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C71326B0006; Fri, 17 May 2019 13:22:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7296B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 13:22:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d15so11658954edm.7
        for <linux-mm@kvack.org>; Fri, 17 May 2019 10:22:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1NWuugkWpQRRWA/1rSmW1lzMgKVNslNjLRYEkdR1Nr8=;
        b=uPRkudxkLBuH/5SuvYhbpzVfidVPka6geWT4SXTDcH/G4hZofVgb+kGFJoVU6fKbPI
         QhzG+8zchwtGJXUtlBaFXpy3/R4Ch1pXxYaI71LDZzuUH4feoRGMr+PrQ8Wiw26ENOq4
         /bhrdbHpaLOWowrNB17KyHH3WE2ztwKzJ4CBOEQxcsEbeW9jqZ+KqC5YnapvyKfnT0YY
         nKKdKe1crnbZfPnatN9Aeyb9UweK1LmhEFWTRgsEdkOjSpfLKYU5QmSWG7HZSqrbYshB
         d55KD6csQSnFahAs/Ep5nizKxgPbYRTl29uT5wOHMrg7CMVVy3Vo4g/7zmLq+IGe3T8b
         MECg==
X-Gm-Message-State: APjAAAVSOL80V8jJKcUyYgv6wOI7MpOMkeQqLWLb5UKQ71h+7rmcz1T1
	xmLb/DdmEaq9ar9OofrviXRV4c1AtipAOOp4DaxfyQo71BZOH8EFiundwmQMmsvtbFsdp+yzRbs
	nVBiyNjzgAGpzFXEaXJ66/kU8ikYg0nJHLqOv/goJFSRqZjv5Pv0QwDS3CniBElkAyg==
X-Received: by 2002:a17:906:6d3:: with SMTP id v19mr9730024ejb.46.1558113734029;
        Fri, 17 May 2019 10:22:14 -0700 (PDT)
X-Received: by 2002:a17:906:6d3:: with SMTP id v19mr9729957ejb.46.1558113733304;
        Fri, 17 May 2019 10:22:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558113733; cv=none;
        d=google.com; s=arc-20160816;
        b=FWCEVm9vTswVFz89vLD54WBIvq6pLwQ98MKSMlbzUmfoKBr1cKM+8tgOH1yYE/c/Eq
         vJ4oCajpCyaoq3Sk2gFUGfL+Z/Zw1vujQis4CGa0TmuAebLPEns4pB7Qtrn13tmRpHVf
         yWXtIrKcS2nGD7pvpEKxR0C3pSbzFU2iWMWvpHdZQ37VkyIZ9UznJY8y01dQkmgTtnSf
         t8JH+/zYE7oFfaQ/5MkhtsDt5ddJfK4vCTPjliqdB5m2S5U76ZhJ/tHg2/Opun8pNjvi
         yROvx05IYby573A/5hk1HUCmaYVEk8fMkwgSBrTOBg8GrWx+i+dPuqhRO4SyN0PJ9n80
         vW3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1NWuugkWpQRRWA/1rSmW1lzMgKVNslNjLRYEkdR1Nr8=;
        b=pyHRwSWqVLh1nE62/mM23RYfjHZpecU6PN3R1WHfWsOWD86MYstqotW47JeXouSpyY
         7xO9DA53ZFR8/PY2r1hb+M2m6nNvsPNWMKW8n+mbOpO0WLosfSeZ9bS5OPsuJD5Il9fo
         /oIqHzlyuSStIqclZuSRSdRL8NHYtPL5EZqJfPSQdNh8tdobMg/HnzpdXcLRL5U53PN1
         1nqgwDrkDCwG5p+zlCcqC4DttU5uBrMu6gKYbSszvGhzk4gfXVo3WsdPJ9qb3cuJpOOi
         hvmWmeTqWRVwi5XND3+3pTG7yFVIpUTbynzcItbM4D6VkGCiv6CZJ7d3nt9S2HvmoseP
         aw9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="le6/IjvK";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d35sor1126961ede.13.2019.05.17.10.22.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 10:22:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="le6/IjvK";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1NWuugkWpQRRWA/1rSmW1lzMgKVNslNjLRYEkdR1Nr8=;
        b=le6/IjvKmu1b5/J+EeSLlKWUQDlzA2Aar3VHLn8ExShqMsFCKjqEBf+toX4TliPE0H
         eb+VONE8jljaQgC23HLZmR5QS5UHQ14s4T0FxyYIFc1hvnC7sseb5WD9AvBCBynEFdA1
         lrQnNndD0CS9PvrNd4djxjYrHkGXrpWHkuZzQhKz2o77NRvXkFxRo3BMupdD9bP4JwDh
         yQuehqXV3ucui8vm8YCOufYwj2Wjwx3CcE2DourDzyTtKv53LPK/Fz1M5PAGRNdsAIKj
         bO3vOu6X06VOTo0XH8SXdjrvrE9azf4qJEek9V7PjsFw50AHNk+SxUWS1jrukw+OJIJ/
         FaZA==
X-Google-Smtp-Source: APXvYqx8zTScvrcOMIUQcp6YiIXAtTO5C4EC3YusWLTaHpQGKmpnKkByyxWWHYm2mGvPVmZ4pHgwJqvrnr9pIKweO4c=
X-Received: by 2002:a50:f48d:: with SMTP id s13mr59668225edm.151.1558113732961;
 Fri, 17 May 2019 10:22:12 -0700 (PDT)
MIME-Version: 1.0
References: <CA+CK2bBeOJPnnyWBgj0CJ7E1z9GVWVg_EJAmDs07BSJDp3PYfQ@mail.gmail.com>
 <20190517143816.GO6836@dhcp22.suse.cz>
In-Reply-To: <20190517143816.GO6836@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 17 May 2019 13:22:02 -0400
Message-ID: <CA+CK2bA+2+HaV4GWNUNP04fjjTPKbEGQHSPrSrmY7HLD57au1Q@mail.gmail.com>
Subject: Re: NULL pointer dereference during memory hotremove
To: Michal Hocko <mhocko@kernel.org>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, 
	"tiwai@suse.de" <tiwai@suse.de>, "sashal@kernel.org" <sashal@kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "david@redhat.com" <david@redhat.com>, 
	"bp@suse.de" <bp@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, 
	"zwisler@kernel.org" <zwisler@kernel.org>, "Jiang, Dave" <dave.jiang@intel.com>, 
	"bhelgaas@google.com" <bhelgaas@google.com>, "Busch, Keith" <keith.busch@intel.com>, 
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	"Wu, Fengguang" <fengguang.wu@intel.com>, 
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 10:38 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 17-05-19 10:20:38, Pavel Tatashin wrote:
> > This panic is unrelated to circular lock issue that I reported in a
> > separate thread, that also happens during memory hotremove.
> >
> > xakep ~/x/linux$ git describe
> > v5.1-12317-ga6a4b66bd8f4
>
> Does this happen on 5.0 as well?

Yes, just reproduced it on 5.0 as well. Unfortunately, I do not have a
script, and have to do it manually, also it does not happen every
time, it happened on 3rd time for me.

Pasha

