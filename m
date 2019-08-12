Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EF9DC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 09:49:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48D0820842
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 09:49:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48D0820842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0B0D6B0003; Mon, 12 Aug 2019 05:49:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBC1B6B0005; Mon, 12 Aug 2019 05:49:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD11C6B0006; Mon, 12 Aug 2019 05:49:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEC36B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 05:49:15 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 36CF0180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:49:15 +0000 (UTC)
X-FDA: 75813302670.19.sleet86_33a35f0ef6048
X-HE-Tag: sleet86_33a35f0ef6048
X-Filterd-Recvd-Size: 4962
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:49:14 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id r21so76519984qke.2
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 02:49:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to;
        bh=TeG3wutKuFLwVY8GXTa6M+xMk4IsoY0IuBgfuWlKI8w=;
        b=dfFsG8pjettn0DYa7sWNlrmvdsM46R0+C9Xqtrwunsc07x1HzqqR07iOjgGfsPagBP
         9zLBfkcilHf2svyImyPU7RU2Uld+HN6VgBqv/vLp7qg1PRnngzEmyprq+JNYthnftkBe
         tzFWjDmoKujO9TXe6C7RNVekjiB8jnGS9yVuFbLKWG3Vfnygk2fTvyg1/iJ51VAYpm8l
         PclZBhiNUYVYZkZpSh1evtR6dSx0aA2JQPOgvOTyGtfdOgheM+u0ls5ewxvJIKfYJEl1
         5BK6Bjjkka20/v3z43e+dCxAi33rejwEvOSgYVXyu0EHiITXLEK9dXHrD9i0GhuROXSg
         wZoQ==
X-Gm-Message-State: APjAAAWzj89CBg91Y8t7BNyTGxuP2k2fiPGBTZ7B66RowUk6cUbYVsv3
	a/jIr+NnRuVbPuAR/0Wm42XzdQ==
X-Google-Smtp-Source: APXvYqxP0GkCXonLtypbly8kLbgJ4TN28n5gWEUnHayGxRExqWLocZL6kaOvmE9QUvNpukx30J3PxA==
X-Received: by 2002:a37:79c7:: with SMTP id u190mr3917170qkc.26.1565603354162;
        Mon, 12 Aug 2019 02:49:14 -0700 (PDT)
Received: from redhat.com ([147.234.38.29])
        by smtp.gmail.com with ESMTPSA id m27sm52517604qtu.31.2019.08.12.02.49.10
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 02:49:13 -0700 (PDT)
Date: Mon, 12 Aug 2019 05:49:08 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, jgg@ziepe.ca
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Message-ID: <20190812054429-mutt-send-email-mst@kernel.org>
References: <20190809054851.20118-1-jasowang@redhat.com>
 <20190810134948-mutt-send-email-mst@kernel.org>
 <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 10:44:51AM +0800, Jason Wang wrote:
>=20
> On 2019/8/11 =E4=B8=8A=E5=8D=881:52, Michael S. Tsirkin wrote:
> > On Fri, Aug 09, 2019 at 01:48:42AM -0400, Jason Wang wrote:
> > > Hi all:
> > >=20
> > > This series try to fix several issues introduced by meta data
> > > accelreation series. Please review.
> > >=20
> > > Changes from V4:
> > > - switch to use spinlock synchronize MMU notifier with accessors
> > >=20
> > > Changes from V3:
> > > - remove the unnecessary patch
> > >=20
> > > Changes from V2:
> > > - use seqlck helper to synchronize MMU notifier with vhost worker
> > >=20
> > > Changes from V1:
> > > - try not use RCU to syncrhonize MMU notifier with vhost worker
> > > - set dirty pages after no readers
> > > - return -EAGAIN only when we find the range is overlapped with
> > >    metadata
> > >=20
> > > Jason Wang (9):
> > >    vhost: don't set uaddr for invalid address
> > >    vhost: validate MMU notifier registration
> > >    vhost: fix vhost map leak
> > >    vhost: reset invalidate_count in vhost_set_vring_num_addr()
> > >    vhost: mark dirty pages during map uninit
> > >    vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
> > >    vhost: do not use RCU to synchronize MMU notifier with worker
> > >    vhost: correctly set dirty pages in MMU notifiers callback
> > >    vhost: do not return -EAGAIN for non blocking invalidation too e=
arly
> > >=20
> > >   drivers/vhost/vhost.c | 202 +++++++++++++++++++++++++------------=
-----
> > >   drivers/vhost/vhost.h |   6 +-
> > >   2 files changed, 122 insertions(+), 86 deletions(-)
> > This generally looks more solid.
> >=20
> > But this amounts to a significant overhaul of the code.
> >=20
> > At this point how about we revert 7f466032dc9e5a61217f22ea34b2df93278=
6bbfc
> > for this release, and then re-apply a corrected version
> > for the next one?
>=20
>=20
> If possible, consider we've actually disabled the feature. How about ju=
st
> queued those patches for next release?
>=20
> Thanks

Sorry if I was unclear. My idea is that
1. I revert the disabled code
2. You send a patch readding it with all the fixes squashed
3. Maybe optimizations on top right away?
4. We queue *that* for next and see what happens.

And the advantage over the patchy approach is that the current patches
are hard to review. E.g.  it's not reasonable to ask RCU guys to review
the whole of vhost for RCU usage but it's much more reasonable to ask
about a specific patch.


--=20
MST

