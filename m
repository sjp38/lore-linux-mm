Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8D08C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:36:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E254206A1
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:36:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="1xeDdxfL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E254206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F08B6B0005; Fri,  6 Sep 2019 13:36:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17B656B0006; Fri,  6 Sep 2019 13:36:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0419F6B0007; Fri,  6 Sep 2019 13:36:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0175.hostedemail.com [216.40.44.175])
	by kanga.kvack.org (Postfix) with ESMTP id D07F06B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:36:39 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5ED7D180AD801
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:36:39 +0000 (UTC)
X-FDA: 75905200518.25.grain77_39e53e5198739
X-HE-Tag: grain77_39e53e5198739
X-Filterd-Recvd-Size: 3949
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:36:37 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id 67so6465070oto.3
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 10:36:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9q7uSrbhx9c5SQPYOEpNGzEqta+u5/vhXzE4QY3PuYk=;
        b=1xeDdxfLX0lsqrWJIjHKNvQ2mty+7kFEPueFcWSm7X+Uw/SIvO7sDyfqh+AfqAS86z
         wVdDeFcyAhtSZVSbwU1iw2RHcDZR/mb9lCaEbO8RIecoXv4cGE06VgWE8XThIHSdh2uK
         el35f5u7Cih4orBW7d6OL5E6g525/axBpJ1t+jNgcd9MPGZa1JMWfO+gNW4nSjIG7Yel
         +Ldr/Vw3HeWdYc0ZzT3IOFNWeA3Y8tM1ZzNN5aEk2UU57rg7816BPhyg6HvNe2tyIfEJ
         ZgiD9tfoVAaNOTdIjRjad6b0YzPXCSTAUyCzbdAyXBkgEdgqIkTmCJBxHbHrgZMGew1k
         e9vA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9q7uSrbhx9c5SQPYOEpNGzEqta+u5/vhXzE4QY3PuYk=;
        b=t0bs65AJy5LmmVxj4XYPMPNg3MOlQHbhTNQBSJ9TYDv171uDPa2WPuOD8MyhH5ozaK
         IntSrkj64nnizbCwyfEUPOZIc8uXzFI4HQmOz5ncSiDjmcII2ils2BGTjoyNUcZiJQKm
         MzI9umG76nO7Zc5M0Q3O7i7mckSJkONbtGJb/c90hPE7Wm3Yj5ehFyqvwUquZb6L2cX8
         lU3IqwWK4t5XKIkXEfrcRoVBWSSTUeJf8V9M/9gjeTdJ5/+o296D0j3/kbdzjH69zqa9
         VvegQGKgFEz+Ynbn0P4MziafQfodBzrcXtDOwnst4FGsaojgJ3PPcbzs1/qOpkYJZZxb
         GjQA==
X-Gm-Message-State: APjAAAVus1+Jkj/qjwXtq+RYxcnhqjBiJOYJQlH86Mp4DWhaqpCLBAuY
	B59+gEpwDxLglESipW0gLMfS2YuBFuSi/Ps4a7nNbQ==
X-Google-Smtp-Source: APXvYqyOD0SaICilU+ItDzyAjDJkuOCP1Wrc86Psdszc/WfYmakgphsYB7srn4wzOxwYsCcwbO5QfPkMEm4wQHJN9Z0=
X-Received: by 2002:a9d:5ccc:: with SMTP id r12mr7873840oti.71.1567791397118;
 Fri, 06 Sep 2019 10:36:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190906145213.32552.30160.stgit@localhost.localdomain> <20190906145333.32552.95238.stgit@localhost.localdomain>
In-Reply-To: <20190906145333.32552.95238.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 6 Sep 2019 10:36:26 -0700
Message-ID: <CAPcyv4hjDpd63f1oYRUHkUjF-E_zJDfY1C36tM5LS=W+QbeRcg@mail.gmail.com>
Subject: Re: [PATCH v8 2/7] mm: Adjust shuffle code to allow for future coalescing
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

On Fri, Sep 6, 2019 at 7:53 AM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
> Move the head/tail adding logic out of the shuffle code and into the
> __free_one_page function since ultimately that is where it is really
> needed anyway. By doing this we should be able to reduce the overhead
> and can consolidate all of the list addition bits in one spot.

Looks good, thanks for doing the split:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

