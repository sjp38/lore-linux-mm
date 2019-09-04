Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAE64C3A5AB
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 21:11:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DCE221726
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 21:11:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="V7EVPD+f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DCE221726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30A2B6B0006; Wed,  4 Sep 2019 17:11:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B9996B0007; Wed,  4 Sep 2019 17:11:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F7786B0008; Wed,  4 Sep 2019 17:11:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0121.hostedemail.com [216.40.44.121])
	by kanga.kvack.org (Postfix) with ESMTP id F0C026B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 17:11:18 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 92C242DF0
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 21:11:18 +0000 (UTC)
X-FDA: 75898483836.26.limit13_458317eb5063c
X-HE-Tag: limit13_458317eb5063c
X-Filterd-Recvd-Size: 3976
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 21:11:17 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id n7so14741784otk.6
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 14:11:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DOJXX029rLk7A9iwm08b8/Tl49pqEw9N8S7iikumjN8=;
        b=V7EVPD+fthp2Q80ZJwJy+hxX6duKEdu7/VTcx6YCk7q0HWNV0qSkz0sS9fajCv9YLt
         kZ7Fmdk++yNzXS4WboBmvS9IZXHfPN+px0XZmekfpGt0/v+IMmaJXO3lW9jhZA9ffiyC
         MPCKZ1ratNZUFYN5RMYbhqOF5wbt25Pw2FFNks7TFpiuxNqkYnlebEOfluG1zKezJgib
         35GgMnC6P6PF2XOMZp8gk//4CUwUh0NXqzem0UlUM6zKjJEuBAaF0TdbOoTqwGnUr4OX
         hYqx6+7zIYDjo/zUUndobyd6up0UDtz1acNvOWuwmD906+9+y6Y7iiFn576BF/OZAfMP
         457A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=DOJXX029rLk7A9iwm08b8/Tl49pqEw9N8S7iikumjN8=;
        b=KQ+W/TaF4gKBtj+Po04lbBFC/XEF0m6hof+v6zMo/lbkhR1X1tgo46/FHXI3Rs4OUt
         j8IZJz3iZu812ydSLBa/H4wHAmqMetpopm42lk6FTDGMqcRsMVof1Zs93u01mn14gCVg
         mA4tjGpi+lw4pXYkc2/VIiIuEJtJlDNr2iR9JEudHHOaqQIALdPRdpkTA2jQqmGlxiVo
         hkP3txc1YlAjUH1t5cqhEkVvbv6/k09d8Kx9r6On23O1KhAeAgGKsLRXEjrEfZXrDnmk
         fyohki+wSmrRDL+93iM5aXEXvNTX7tNAVJ1tsQM7Y6m2N1X/oHxH95+20vOgQidGtskM
         j5Hw==
X-Gm-Message-State: APjAAAVZ6+1fbogb0/A14At9EzNicdkh1+bbOH7xTOtjf0wFz8bZZBI1
	fOHzU9UZo4NeqXP3I4TozOD0ABujLwQ1waDJ/xb3vQ==
X-Google-Smtp-Source: APXvYqx9jKkBHnd+DQIWXHwkuc52sRnnbaAsQKgvUKsZGTAH48zPPbXcKFWapnRn7Rw3Hu49a3/TdCstzgRe3NrlpAw=
X-Received: by 2002:a9d:2642:: with SMTP id a60mr9252305otb.247.1567631476902;
 Wed, 04 Sep 2019 14:11:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190904150920.13848.32271.stgit@localhost.localdomain> <20190904151036.13848.36062.stgit@localhost.localdomain>
In-Reply-To: <20190904151036.13848.36062.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 4 Sep 2019 14:11:06 -0700
Message-ID: <CAPcyv4hHdRbb2pLgeAYep8fXRxYwG3QixFBVfsO9FNtAzvo6mg@mail.gmail.com>
Subject: Re: [PATCH v7 2/6] mm: Move set/get_pcppage_migratetype to mmzone.h
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, KVM list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, 
	Oscar Salvador <osalvador@suse.de>, yang.zhang.wz@gmail.com, 
	Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 4, 2019 at 8:11 AM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
> In order to support page reporting it will be necessary to store and
> retrieve the migratetype of a page. To enable that I am moving the set and
> get operations for pcppage_migratetype into the mm/internal.h header so
> that they can be used outside of the page_alloc.c file.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

