Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33538C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:42:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CED5822CE3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:42:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="cbZ/eIqa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CED5822CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B89D6B02E1; Thu, 22 Aug 2019 04:42:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06A886B02E2; Thu, 22 Aug 2019 04:42:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC0A76B02E3; Thu, 22 Aug 2019 04:42:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id C67966B02E1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 04:42:52 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 72AF2181AC9BA
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:42:52 +0000 (UTC)
X-FDA: 75849423384.14.drop08_361d5fbcf2823
X-HE-Tag: drop08_361d5fbcf2823
X-Filterd-Recvd-Size: 4764
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:42:51 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id b1so4740075otp.6
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 01:42:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NfCKuFdEeNBAgpgY3GQU9evNY2kKtJpvRWsNwL+v9LE=;
        b=cbZ/eIqa3UOnq5kZcw9ViWpQlwY6IoHQWwYFtH4j5KLaJRU0py33AbPiPiAJVlbc/Y
         BKVPPwYWmhbkGDR1ys452Hfk/wY38q87dT/NiRbDk43nh9KoZQCtcGVi2a+huvT45BW1
         DTkTcnHBZzI/xbpSr6wkE8INN5L/ml6Sq3+ak=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=NfCKuFdEeNBAgpgY3GQU9evNY2kKtJpvRWsNwL+v9LE=;
        b=ZJiTH2rjjgdsW9tIm8xbBsl1GkNd979aU+JUAsSjHCEP1DlzJcbZj4uAZKjnWMLQpr
         e4CHC0+iHzeD8HLjxzE5qaF4z8T9jMeQo2iqxNppacmq9YTFr705Yu4vlV/CMnOz9otW
         A+QizV6RjSY2EtanPd7latZ3/mqLgGRhCcaE8Zg3KdBf+LP5Wm9FNfHx0z4lguO2KnBm
         4pmc5wXpoZhCiVJVPscHsfubrfR82ErAB2urnb/y1xyRJmHn+rCA1ik6qD15yfIxeGML
         /+gx3z1jsHvMwWHkuQSnvR1Xc1GJwSGDNMRyhy1zVf55Z0dshS8Ysu4TwaqeY2ivVJdd
         T7fA==
X-Gm-Message-State: APjAAAWqP+TdWFKqxXRNZ0NTZNNWtZi6zf6/OuJeORhAnsAz7g+J1Lse
	J4kwMXqVum+pdMsUvHTbGTITQH/oQuBlh4OTsMmAdw==
X-Google-Smtp-Source: APXvYqxpz8kgbP+ugs1KUhnBtoipkM40G0JFM2B8mwDRWFu9+c1XE/VWtgoMVi8Vtvm95XZX33AsAYp4bMyumd0+MLk=
X-Received: by 2002:a9d:7cc9:: with SMTP id r9mr31457513otn.188.1566463370802;
 Thu, 22 Aug 2019 01:42:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-5-daniel.vetter@ffwll.ch> <20190820133418.GG29246@ziepe.ca>
 <20190820151810.GG11147@phenom.ffwll.local> <20190821154151.GK11147@phenom.ffwll.local>
 <20190821161635.GC8653@ziepe.ca>
In-Reply-To: <20190821161635.GC8653@ziepe.ca>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Thu, 22 Aug 2019 10:42:39 +0200
Message-ID: <CAKMK7uERsmgFqDVHMCWs=4s_3fHM0eRr7MV6A8Mdv7xVouyxJw@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm, notifier: Catch sleeping/blocking for !blockable
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Daniel Vetter <daniel.vetter@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 10:16 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Wed, Aug 21, 2019 at 05:41:51PM +0200, Daniel Vetter wrote:
>
> > > Hm, I thought the page table locks we're holding there already prevent any
> > > sleeping, so would be redundant? But reading through code I think that's
> > > not guaranteed, so yeah makes sense to add it for invalidate_range_end
> > > too. I'll respin once I have the ack/nack from scheduler people.
> >
> > So I started to look into this, and I'm a bit confused. There's no
> > _nonblock version of this, so does this means blocking is never allowed,
> > or always allowed?
>
> RDMA has a mutex:
>
> ib_umem_notifier_invalidate_range_end
>   rbt_ib_umem_for_each_in_range
>    invalidate_range_start_trampoline
>     ib_umem_notifier_end_account
>       mutex_lock(&umem_odp->umem_mutex);
>
> I'm working to delete this path though!
>
> nonblocking or not follows the start, the same flag gets placed into
> the mmu_notifier_range struct passed to end.

Ok, makes sense.

I guess that also means the might_sleep (I started on that) in
invalidate_range_end also needs to be conditional? Or not bother with
a might_sleep in invalidate_range_end since you're working on removing
the last sleep in there?

> > From a quick look through implementations I've only seen spinlocks, and
> > one up_read. So I guess I should wrape this callback in some unconditional
> > non_block_start/end, but I'm not sure.
>
> For now, we should keep it the same as start, conditionally blocking.
>
> Hopefully before LPC I can send a RFC series that eliminates most
> invalidate_range_end users in favor of common locking..

Thanks, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

