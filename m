Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5050C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 21:10:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 438B52339E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 21:10:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="cr/2pcTa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 438B52339E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99A646B0003; Wed,  4 Sep 2019 17:10:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 971516B0006; Wed,  4 Sep 2019 17:10:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AE846B0007; Wed,  4 Sep 2019 17:10:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0183.hostedemail.com [216.40.44.183])
	by kanga.kvack.org (Postfix) with ESMTP id 69F4B6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 17:10:30 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B86F8181AC9AE
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 21:10:29 +0000 (UTC)
X-FDA: 75898481778.04.list65_3e690d7c33a3b
X-HE-Tag: list65_3e690d7c33a3b
X-Filterd-Recvd-Size: 4487
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 21:10:28 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id r20so22154165ota.5
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 14:10:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wPMWwNSvV9eb5rCu0YMNtiK3/0cR200eFpdZP8tToms=;
        b=cr/2pcTab+KUWoDNVNzO2zJ+8zFyfJbc3u75JTwJU8kJ7gWl3gxzG5ENnPPSyVrSCq
         SuBqAQ8RzhaV2a/HxduSt7ppLV/eWGTtUx/a6wNjIODvqE88o+7S1ZWGc6I6GW/lWSco
         ugSco9IMYbUbbhVhb7LB51QAUisJGNylBc2XTRY+ofuMS4mtW7yB+nBDwcC8Eflg+DIh
         C47efgC6cD78+M5RvB3gTx+JoWSmjAvaaa2GqDhJjsgLFt59c15hiEh1Ur3QDfAToi1y
         ZJezHfiZrelD2BcNYDQu3jmZ72RSuDo/vns5bY+ZuJ10WxhXfVOcTURaAUZLAfLH4A1T
         NulQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=wPMWwNSvV9eb5rCu0YMNtiK3/0cR200eFpdZP8tToms=;
        b=Y+AkoGH6r21ynI/sqjpuypXSXkxkkXfbJpYDlq7QhZcuSXKR46Id+OwF5pA4nFS+mR
         MRMPVjdeZ2Bx9xIJTgauY+c6CHOhuxPOPq3z+7Zrl9NQkDBJPI0Ey1Hey8kBkxcwUzir
         Xzk5bnEDqCZfP8CcfWcv+4V8Vtuu0D3AtjfIP0HKGq+FmtOEzGUeZhwO1d/gYhEa74xn
         FRPmP1PUGp3iusyBw8CjLeGVvqni2MiQu3awfo48I/0llVfkInKVxzlFl1PTdrs26Kgi
         sjIIDm6vHzNAC61GynHjZCAfBl/kp2qOqaO7re/9WTOIiT6biIcBiyIMakrXB9HKMi5A
         V/zA==
X-Gm-Message-State: APjAAAWzCAQkqLdmzm/bOHeW3wjO3RBdh1jcQw/1WTGEAFN3AnjTShuG
	BYFrM3kETR4habXRDIIpyGVuQWEEmCc/2SQnHiGzbg==
X-Google-Smtp-Source: APXvYqzFh8uueHK+qUmQpwTm/TlKG431AzcbA3p2O6x4cql8knUN37kiD/jGqwHTO7K8qxaIQLqXw5St076KjdfoMnU=
X-Received: by 2002:a9d:6d15:: with SMTP id o21mr9381251otp.363.1567631427871;
 Wed, 04 Sep 2019 14:10:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190904150920.13848.32271.stgit@localhost.localdomain> <20190904151030.13848.25822.stgit@localhost.localdomain>
In-Reply-To: <20190904151030.13848.25822.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 4 Sep 2019 14:10:17 -0700
Message-ID: <CAPcyv4jZVoztoRA7hEq5xzbwg0QJ+UVASuk5XQmB5KHQrvAmfA@mail.gmail.com>
Subject: Re: [PATCH v7 1/6] mm: Adjust shuffle code to allow for future coalescing
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

On Wed, Sep 4, 2019 at 8:10 AM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
> Move the head/tail adding logic out of the shuffle code and into the
> __free_one_page function since ultimately that is where it is really
> needed anyway. By doing this we should be able to reduce the overhead
> and can consolidate all of the list addition bits in one spot.
>
> While changing out the code I also opted to go for a bit more thread safe
> approach to getting the boolean value. This way we can avoid possible cache
> line bouncing of the batched entropy between CPUs.

The original version of this patch just did the movement, but now the
patch also does the percpu optimization. At this point it warrants
being split into a "move" patch and then "rework". Otherwise the bulk
of the patch is not really well described by the patch title. With the
split there's a commit id for each of the performance improvement
claims.

Other than that the percpu logic changes look good to me.

