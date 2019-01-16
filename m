Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D216C43444
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 02:01:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0FC420883
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 02:01:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ZcjEfkym"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0FC420883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 883D98E0004; Tue, 15 Jan 2019 21:01:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 833958E0002; Tue, 15 Jan 2019 21:01:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 749EB8E0004; Tue, 15 Jan 2019 21:01:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4717E8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:01:22 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id g4so2012877otl.14
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 18:01:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WlE9B/Ts/5kmVoT/yhWaCE6Kcc8ieumx6zA59spU9wM=;
        b=doGNsbHO5G6nB6BxxeCYQ525VQEKVyCXCJx+du+9FLbZ8GLeuKm+6Bu1UlUJawI587
         MOx8EQfZh4NEE0awI4Hui+8e4VveFQ/AWSCJfYX4ZMRecK2GYJEFqmqSuAzuP6zug59g
         WNIxEczVFNJYlzFb6HhA0th3Zkm0DblopvdENDqbkxIT9/0pTPD+xkaDOYGv+RIXVeB/
         UgEdZQxjEQrsCMGHwnZYGPgxRNoYqRjEMuAQKrszwKsSi80SwU3gIt0dKQ+olXtlllbp
         vb7YCWIH2QMTznKjNxiTG0lLvYhp3+rjITDSfFfjd85+4StBFozJpNBVGfn4clUVvrTK
         6hRA==
X-Gm-Message-State: AJcUukfQZCUezY7jfZPPi+NU2s6uyZj7HpUNoWWR2pocRdlaSdnXt86Y
	kgYkVF/rw6i40Xk8CfA9sRF2E/ZbsWVNOKIzvB7aBKglGmxZ8uLMKUzJm/rrF98bh/+I/hjM4rh
	zlVos/QPFSjEg8mJYgDFAu6vx88LnXM84uSo2EIsN/rsoM9KnXMXCxSThnyGK0ms4rvbyGjHSJO
	8INlOsrPVbtcEUDVCfHFTijZ96ZFQ/6z93tWNMSyqEJ2dzFtRfV8MLu0zf9ntWsVtlKA5G0nyEO
	cu7cUWb9Zfra3OmwZeLYjCD6cnTZKqjgyrByap+L8E8PQUzx42biN2NXKpw3hLREl4uB7FC06v9
	paa8tK9J5XLcL1pwBTgrIokoMxEWUh3wRrvTi63BcRzMcVEWevL+HMgv+0UTs4+ku9MpXT4X31q
	G
X-Received: by 2002:a05:6830:1005:: with SMTP id a5mr3899984otp.113.1547604081956;
        Tue, 15 Jan 2019 18:01:21 -0800 (PST)
X-Received: by 2002:a05:6830:1005:: with SMTP id a5mr3899952otp.113.1547604081374;
        Tue, 15 Jan 2019 18:01:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547604081; cv=none;
        d=google.com; s=arc-20160816;
        b=PcAxg0JfvQ9eFfS3L2w0vbzekeGbPuvhiOHAX25+JobJiNB4ILV6wvFUmKzyvXihIl
         wlGhgQQDDo4vIIbd7Tol7EMU+IWpQ6128QSrpoKIR5s/3ZJ46yUrvEvbOstk1Esjo/7G
         ehdmXTQlqoDPKclTwfDn7qX0XinITNXvJ+l4yW8GCvkEVHVYnRXJEmgSd/I3Xm+k/VDx
         ORh7R5n5F4fLd9GLrVgAUJTYVfWnmzbNzdd9nFYi+9ALcC/Xni4cKu/dmPXgSDIkQfVX
         fYfeMa07J5V7zOZcWmI7TsACfVDvmxy5Cn1eZfm92ypDi/XJuYBsttlp6y0sQlbeLtlc
         IzbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WlE9B/Ts/5kmVoT/yhWaCE6Kcc8ieumx6zA59spU9wM=;
        b=i18eC4m0sRzgz1pXOSbVjkz4qux9IlIFwXwoPHS9gZp0LqgOJW8AKfM/HwLHDmlG9H
         TP094QOz5qUE5CY/VbZHtv9fTYb63V0NicMDwaIEd+GY0H95a9LSiRXTF0jsn2m4r5qs
         PtUo6yN/owPRt0TL7T5lIb188QCsHLEV8jQbi1Da/PDuakp3L8Vbm8zPcRAvTU/DQey4
         mRX6aGGHgSKOz8QcESX0xPtPChLP+Ic4r6zCKnV6OuXwjCUMFVbRK5DQujvEC7oSZl2a
         DKBT3VqUXQ8f3fx9gGQaAlW8R31isklJuaENB1Gvhok82o9l8V8MIGOIbW4sa+oWyMK3
         xX3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ZcjEfkym;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m11sor2778459otk.110.2019.01.15.18.01.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 18:01:21 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ZcjEfkym;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WlE9B/Ts/5kmVoT/yhWaCE6Kcc8ieumx6zA59spU9wM=;
        b=ZcjEfkymRud+McOoMAGPl889LVxFLq9vkOsP1QNATBMKgaqrQOPz6MtyzbcVfyGAkc
         0Yl06YQHlc1R1J/eeVn+mK/RQbunD0e5K0xdkXRdFKepSghykgphHf2IA24dbwScw3c1
         itLPsab/d8bvPzuZhvdz77tqG2cxAjfkxLIQMZgmaZSx1x+m/B8lSirYZc1uis66F72i
         Ar8XgfQnAvw2PkL+Fi981CILyrHtdEXxpxdNpYWCwUlp4hcjOEfGJqROMW3MzFO5GKIT
         AXJ/JM/OOHMqjunkHi2HPmnkLGtPXys7dyGWhGmRYdKdraXzLm+KdFihB49Lx9kVJuqY
         HDgQ==
X-Google-Smtp-Source: ALg8bN6k8VrGhTAZgUFWUdDqFrNSRRsUbvN1vUk1Q2Umc4ZqtlUPFAky5MZDBtlAzecZCdF4Uq+DYAZ1LrB+c1jrak8=
X-Received: by 2002:a9d:5cc2:: with SMTP id r2mr4061912oti.367.1547604081096;
 Tue, 15 Jan 2019 18:01:21 -0800 (PST)
MIME-Version: 1.0
References: <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com> <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz> <20190115171557.GB3696@redhat.com>
 <752839e6-6cb3-a6aa-94cb-63d3d4265934@nvidia.com> <20190115221205.GD3696@redhat.com>
 <99110c19-3168-f6a9-fbde-0a0e57f67279@nvidia.com> <20190116015610.GH3696@redhat.com>
In-Reply-To: <20190116015610.GH3696@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 15 Jan 2019 18:01:09 -0800
Message-ID:
 <CAPcyv4h2hX_CJ=Ffzip4YzryOX0NPo9yy+yDsSPnyp20xat94Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
To: Jerome Glisse <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, 
	Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, 
	John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, 
	benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, 
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, 
	Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116020109.qgc5z_x_H6oo_Rw9ygm75gNEwYxqljNthNcPaaBKjHU@z>

On Tue, Jan 15, 2019 at 5:56 PM Jerome Glisse <jglisse@redhat.com> wrote:
> On Tue, Jan 15, 2019 at 04:44:41PM -0800, John Hubbard wrote:
[..]
> To make it clear.
>
> Lock code:
>     GUP()
>         ...
>         lock_page(page);
>         if (PageWriteback(page)) {
>             unlock_page(page);
>             wait_stable_page(page);
>             goto retry;
>         }
>         atomic_add(page->refcount, PAGE_PIN_BIAS);
>         unlock_page(page);
>
>     test_set_page_writeback()
>         bool pinned = false;
>         ...
>         pinned = page_is_pin(page); // could be after TestSetPageWriteback
>         TestSetPageWriteback(page);
>         ...
>         return pinned;
>
> Memory barrier:
>     GUP()
>         ...
>         atomic_add(page->refcount, PAGE_PIN_BIAS);
>         smp_mb();
>         if (PageWriteback(page)) {
>             atomic_add(page->refcount, -PAGE_PIN_BIAS);
>             wait_stable_page(page);
>             goto retry;
>         }
>
>     test_set_page_writeback()
>         bool pinned = false;
>         ...
>         TestSetPageWriteback(page);
>         smp_wmb();
>         pinned = page_is_pin(page);
>         ...
>         return pinned;
>
>
> One is not more complex than the other. One can contend, the other
> will _never_ contend.

The complexity is in the validation of lockless algorithms. It's
easier to reason about locks than barriers for the long term
maintainability of this code. I'm with Jan and John on wanting to
explore lock_page() before a barrier-based scheme.

