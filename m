Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 644A1C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 17:44:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B75D21873
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 17:44:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="XjPpCD+Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B75D21873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4E746B0003; Wed, 20 Mar 2019 13:44:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD7236B0006; Wed, 20 Mar 2019 13:44:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E3456B0007; Wed, 20 Mar 2019 13:44:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 751BE6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:44:37 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id e124so64607ita.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:44:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XJWBhpRbEsqIJ/DPGDyokhV3NlZo8RjYnfZk7wmzygQ=;
        b=e3goN9TPBQELmStiDvznBk/OlqvxomUZjbAT1Ks9OWpPjOcLII5iScMFZ5rEqwlKlL
         zYetuXcKe1gekMRBcHW2JQsvQOVL3d9W2ouXmQ6wzC54ezkjJaiPCTKgiyoHeFpjpLyR
         ChRKQujjBkFzIFxOH9/AkRZsz8tevNVewqYu2EDvMjXfohN5wThJEydUNfd1yA6vxHyT
         DJvtkP7dxWJr1tz/mYV8Bh3zPmQ4hxgB6eNdgiY5+kE4fIp/H8vsJZKbfOB0fAipCW57
         ZYYzROeB71Dxo06JjtLwkCZ/yqiwBwjnBqIsqXocMJEBvwZjBLMWrxjUPxC9XUnHwPak
         b7BA==
X-Gm-Message-State: APjAAAWyeoAqOFWlCcCyAMhH+PXRhcaDWdwxTyCKSN+xF8BJT0h+oEut
	wKrurVtshIBu1FU/1d8xdRfEPipfuSywnUFZiIe9cad7WueTvZlNPvTqyewLbmFykgjDgNSdegN
	Rg7iIddOMBY5Bgu6xcGpBBEGINTWMWBUtWcugh6VylmvGzkgypZzieY3fIjZA2frhGQ==
X-Received: by 2002:a5d:9715:: with SMTP id h21mr6753443iol.266.1553103877238;
        Wed, 20 Mar 2019 10:44:37 -0700 (PDT)
X-Received: by 2002:a5d:9715:: with SMTP id h21mr6753412iol.266.1553103876637;
        Wed, 20 Mar 2019 10:44:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553103876; cv=none;
        d=google.com; s=arc-20160816;
        b=yABKJo1sBBoOoaQMP1mguX56lfiNfHrAgecK17otOZYyCLporHaiR/3D8F8qjbcaCz
         RHJm3lVHl9iDvggTq+5mUw8bh+fzSBmRc+rfCEKI63SLbsV6nHGkx8Hvpm2n8X9owC3Q
         BBp/RsIMu5ZJGIte6qCAbZInrYKqs3agWuFxWJQ+HbZFJE31CyeUHFwG2O83I5/ZnQ3Y
         NjzfYGePy+OfermXWKKZrqatvE5YJ/FttY/4YLVHq388eYZsFpNNW7ZTVeleYxd0SeEN
         /iWav+AXd0yZffPtSPO+LtjA8xJv1Z9z92TI06NAEKWgzBqnM32R9mLFVdfZw5KiExMh
         26TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XJWBhpRbEsqIJ/DPGDyokhV3NlZo8RjYnfZk7wmzygQ=;
        b=Sx0i5UFYOmuVOEBAiolhE3+/7MtvfcCOrBChS+Me9G2PNSploIk1ZZTWzsgZJUVZSM
         Zghy+M3rlyGzuE7axZ/QdPXwgDTSh7UBiyNau44dFaceaPy9AP5wReDIqEsczhA4kcNa
         jv+/vwYcyHxn3Gcrzg5WkAcg/PB7bY8VxJHWgLNbDbWt8WTVKeS6T6OzDhaWMatppc4f
         u1jDOs4+H1f2+6VUAxA+Coc7klu0zx8Za8w1QYJ4rk76gUTQicmbiYlWFFLe2WZeidbR
         PTaPoIaR1WXxqjCbx+TTt65BNUH59YgzDMXf3lZUncLIFxiueyTEa/n/hEy8t+Wn4vvf
         LbBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=XjPpCD+Z;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y103sor5401286ita.12.2019.03.20.10.44.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 10:44:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=XjPpCD+Z;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XJWBhpRbEsqIJ/DPGDyokhV3NlZo8RjYnfZk7wmzygQ=;
        b=XjPpCD+ZJTMYSk/BqhuSEWRGlQaW/hyey9PaU3FV5gAeNwYyxO4i7aKuB5YbiCbZAt
         hr/e/rN2zuXCyeU7jZSmgzLrhktYCTGIqP21ysoYS4nnJOyKaxvWSjnfNmLqRu/wPpJX
         9F7CSp4UdH4UlhCsCtrdKWgaRnIAztFvwZgVo=
X-Google-Smtp-Source: APXvYqxfZ6ixIH0xqyyWhq2SKkFOcfrQCZEajo6cJAAjo4EckoJs3VPKsrPtHoDwKk0p7K/roLqpIt5pOLfXha6zckw=
X-Received: by 2002:a05:660c:11cb:: with SMTP id p11mr4418477itm.105.1553103876286;
 Wed, 20 Mar 2019 10:44:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190320152315.82758-1-thellstrom@vmware.com> <20190320152315.82758-2-thellstrom@vmware.com>
In-Reply-To: <20190320152315.82758-2-thellstrom@vmware.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 20 Mar 2019 10:44:25 -0700
Message-ID: <CAADWXX9N+mCN5Vg1eVz9k-UFMQPzc5QXUm6fieBf0oEnC1-=OA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/3] mm: Allow the [page|pfn]_mkwrite callbacks to
 drop the mmap_sem
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: DRI mailing list <dri-devel@lists.freedesktop.org>, linux-graphics-maintainer@vmware.com, 
	Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, 
	Rik van Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, 
	Huang Ying <ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 8:23 AM Thomas Hellstrom <thellstrom@vmware.com> wrote:
>
> Driver fault callbacks are allowed to drop the mmap_sem when expecting
> long hardware waits [...]

No comment on the patch itself, but please fix your email setup.

All the patches were marked as spam, because you sent them from your
vmware.com address, but without going through the proper vmware smtp
gateway.

So they lack the proper vmware DKIM hashes and proper mail handling
should (and does) consider them spam.

               Linus

