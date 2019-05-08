Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78BD2C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 13:50:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13E1121530
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 13:50:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="GgArHWlW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13E1121530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 829C66B0003; Wed,  8 May 2019 09:50:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DA646B0005; Wed,  8 May 2019 09:50:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67B9C6B0007; Wed,  8 May 2019 09:50:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC8A6B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 09:50:39 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 72so2054486otv.23
        for <linux-mm@kvack.org>; Wed, 08 May 2019 06:50:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2EurxZMr2RolSsa7vNYJaos3juIlj/g/eKIBE0b5hok=;
        b=paahf8rwy+srg4WJfGhfYLzVH/c0cB+6A8Lj/shvnWbeHDnQvUVQHFuZKDwtAyxamy
         L0rAsYeM2FAUXe40qL/mugfUm0xySxlt3JIMIvvvWxfCOt4Ve0+AsuNXH/K+gxhprcOK
         fXFH5jhnNHEx8KUo1P1obNJy2etWgAhkLGz2Xgz5HP/AvnZ3xLR2vcgBv4iJFEVN7goC
         KS5UbFw9FVExHwLwsmGDQulWpN92mumAhaEoaL239rxC9zqPnNau/sPKHIZgaYgxtxrd
         CDnofhl3TMUWPnJIkcmGpFDJRTBgjNF9uRo4d6B2v6wCzFwjj85ptMukp278O6dIhMUY
         2ong==
X-Gm-Message-State: APjAAAW+q5Eq3v8VxwUynJGAh+Na3C1elDVF3Jcd17qHVPIlcJbzoZu6
	1RC9IhBWf3ctQ2KhUwqbzfZ1ko/TXVSXREqHtludnYZsvN0hmyrr4fF3S77Tu25+KmyoUT9RlVv
	3hTlus+hZMgSdqq6WUVXcwKr9Eys3xu0VZ7qD1fsItMVbm/ZaqfivFy5W6Jxej/BEmA==
X-Received: by 2002:aca:3d57:: with SMTP id k84mr2157307oia.106.1557323438921;
        Wed, 08 May 2019 06:50:38 -0700 (PDT)
X-Received: by 2002:aca:3d57:: with SMTP id k84mr2157269oia.106.1557323438129;
        Wed, 08 May 2019 06:50:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557323438; cv=none;
        d=google.com; s=arc-20160816;
        b=EjSYa6q4d1NfkeGwjpVYG3xiOH3mxpEP0kREaEG2+t1/opLPncuhfpU+cq6B1WNaCn
         ACvlpf39ZUtbbXxkhzDaIqU9vOxd78FQ5ZVRRFxU/WSp+par3cu3us1wqxOPLwXB9PxG
         Q/WqLrJGD0QUKJKhaQOVs0YykRO5gmpAYnVcfmqQcua3pDKTJpjkJYRgwyA9U0YLCw6w
         l0gSvcTN1bPR7jd7/3YZ6jZ8+KIjcANbxm0SRXNSbfFBEayjINK1pnONz3EAop4Jm58b
         KGebQbJTwT8CQzqaAHHygej2QtsSqDGIQV2AbCAt74cL49Hva4WZsGTZ1ZVij9gCKBYc
         rNMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2EurxZMr2RolSsa7vNYJaos3juIlj/g/eKIBE0b5hok=;
        b=yzqSnyaiYJOkYwsUCIa/7+RtRt+7k8vaT3McfDBOFsAWoU99tU0nmAMEHhpXobLDa1
         Lyv1pxyk3kePaLRp2T9lV21a7+Fghf8+Q5GFhPisFDd0YHfWtwTd6XL8bBfQlzE3+KWE
         xNLpuAhnSHK+dVSdHYnwn6fYtPVD93BlmHqfHEzRj+Y7d1exNKwPr5k8mZh1NNcxdc4D
         xCRBnUp251yoLsI1gbF2jVRC11RGUJqwd81fW6FiRxQ+Q3uhvNhX/t3xoUau64t0/qGC
         8eYupEo5XC0jpwv3/rnJ8VDzSJwe4ZLzsavf1k6cCQF6qIuM5tGmbfYMmExsmVYs9dZO
         zAxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GgArHWlW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s84sor7148231oib.9.2019.05.08.06.50.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 06:50:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GgArHWlW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2EurxZMr2RolSsa7vNYJaos3juIlj/g/eKIBE0b5hok=;
        b=GgArHWlWkQXoHwkDnK52AErLjHNxY5Gtmfi45DghAvzYSBWNm6e7PeK3JgF31tT39u
         Q8JR+JNhhGsG4Y7l9oZGDgiuq1Vd5RwpB/qtfTMetqQ89+0JLpGSnC6dCfhpwx19hpSY
         dW71jKTymLLEW0H/kPBh86F7O8Pl6ugXsxDoo7RkHtzfBaDJhKBBOLKKOiQUz6mX4dfy
         /qJ/gwBQBKlIHCytwcPCDVmTqECvadxzkRYOgECHpEhiJhC26ncnwbpfGzSI5baBNh4g
         EXfGGgHq+v/FJ3xWAj5JIAmNaj4uBs1RsRNGNVmeAZDVHZ7DoyszSVQnNrDKMABq0UGH
         +EKw==
X-Google-Smtp-Source: APXvYqyeIjtF65mpJyGOqNS4h3BV3LQvlNHfYva0fI5IeZSoAKQb2exqaAUh3L7sY+Pt68OUPCAnfn3ZcLOt3M41mPQ=
X-Received: by 2002:aca:4208:: with SMTP id p8mr2432775oia.105.1557323437130;
 Wed, 08 May 2019 06:50:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-8-david@redhat.com>
 <CAPcyv4h2PgzQZrD0UU=4Qz_yH2C_hiYQyqV9U7CCkjpmHZ5xjQ@mail.gmail.com> <1d369ae4-7183-b455-646a-65bbbe697281@redhat.com>
In-Reply-To: <1d369ae4-7183-b455-646a-65bbbe697281@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 8 May 2019 06:50:25 -0700
Message-ID: <CAPcyv4jtS6G_ZqLCdO4gOjS9K2cuX=ywFHemhSb46aQvS8pa8A@mail.gmail.com>
Subject: Re: [PATCH v2 7/8] mm/memory_hotplug: Make unregister_memory_block_under_nodes()
 never fail
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, "David S. Miller" <davem@davemloft.net>, 
	Mark Brown <broonie@kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>, 
	Oscar Salvador <osalvador@suse.de>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 8, 2019 at 12:22 AM David Hildenbrand <david@redhat.com> wrote:
>
>
> >>  drivers/base/node.c  | 18 +++++-------------
> >>  include/linux/node.h |  5 ++---
> >>  2 files changed, 7 insertions(+), 16 deletions(-)
> >>
> >> diff --git a/drivers/base/node.c b/drivers/base/node.c
> >> index 04fdfa99b8bc..9be88fd05147 100644
> >> --- a/drivers/base/node.c
> >> +++ b/drivers/base/node.c
> >> @@ -803,20 +803,14 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
> >>
> >>  /*
> >>   * Unregister memory block device under all nodes that it spans.
> >> + * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
> >
> > Given this comment can bitrot relative to the implementation lets
> > instead add an explicit:
> >
> >     lockdep_assert_held(&mem_sysfs_mutex);
>
> That would require to make the mutex non-static. Is that what you
> suggest, or any other alternative?

If the concern is other code paths taking the lock when they shouldn't
then you could make a public "lockdep_assert_mem_sysfs_held()" to do
the same, but I otherwise think the benefit of inline lock validation
is worth the price of adding a new non-static symbol.

