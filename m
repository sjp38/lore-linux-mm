Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64C19C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 21:08:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30D8622CEC
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 21:08:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30D8622CEC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0A856B0005; Mon, 19 Aug 2019 17:08:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABAC66B0006; Mon, 19 Aug 2019 17:08:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D1C76B000A; Mon, 19 Aug 2019 17:08:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0103.hostedemail.com [216.40.44.103])
	by kanga.kvack.org (Postfix) with ESMTP id 7DA066B0005
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 17:08:35 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D7C12181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:08:34 +0000 (UTC)
X-FDA: 75840416148.02.train01_850b2c3c77500
X-HE-Tag: train01_850b2c3c77500
X-Filterd-Recvd-Size: 6038
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:08:34 +0000 (UTC)
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C39785859E
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:08:32 +0000 (UTC)
Received: by mail-wr1-f69.google.com with SMTP id j16so5833582wrn.5
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 14:08:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to;
        bh=LPz289eUqMdVK44r3XmdrIn3iZGWOuftMF6bJgSrgXw=;
        b=gvQQ47OXNKMSP5wXT2GYucjIKAhxz6RMDaefnlyH/kHAWaBs0CnKSJ5ae8aIzZ++55
         /vitkJpvkaaSbGcf8Bds7D0VI+0eKye8FtE5FNUKRcuiJVCB5xBLMXU9fT7Yh44VzL+U
         4zH3k5D6PnRR7mpFrq3BemrFsfFIZ+mWw6o1HlHPpXizC4St1tbdTsbIA4bY366cduim
         4Ja4QhJoblOFZf5bWMjUiDoV7+cLX7pYEu/Koelfnuwv31wVZGOHanfr7Et2YEpeQ2If
         UHVSxVul9NT3XpGNEeVlEOSg0sicMuD++5Wvd/nmJpH2WYl9GWWuR7rOW2Y6OhEuhxNL
         CAOg==
X-Gm-Message-State: APjAAAVxVwsc29AcriazUNhHVyRdcMOAMFueJvtqXT5Q/ZNZ2/YRqi6i
	NSz9iWjBtwgW2dDRtxmJyW6t7FWoefvA+k74GBmO8hQrkTVfSM6+FEuxYSWRifZkX1saxT59t7f
	6DPo5IC96fcQ=
X-Received: by 2002:a1c:1ac2:: with SMTP id a185mr22464976wma.96.1566248911492;
        Mon, 19 Aug 2019 14:08:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzkGtqGEh4bXvK+QUgFZWjgeN4BxKK01EdaQMhbc46GISjxsEbgjr0J/8MhISgz5u3RfrvFQ==
X-Received: by 2002:a1c:1ac2:: with SMTP id a185mr22464968wma.96.1566248911216;
        Mon, 19 Aug 2019 14:08:31 -0700 (PDT)
Received: from redhat.com (bzq-79-180-62-110.red.bezeqint.net. [79.180.62.110])
        by smtp.gmail.com with ESMTPSA id 74sm28893350wma.15.2019.08.19.14.08.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Aug 2019 14:08:30 -0700 (PDT)
Date: Mon, 19 Aug 2019 17:08:22 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, jgg@ziepe.ca
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Message-ID: <20190819162733-mutt-send-email-mst@kernel.org>
References: <20190809054851.20118-1-jasowang@redhat.com>
 <20190810134948-mutt-send-email-mst@kernel.org>
 <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
 <20190812054429-mutt-send-email-mst@kernel.org>
 <663be71f-f96d-cfbc-95a0-da0ac6b82d9f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <663be71f-f96d-cfbc-95a0-da0ac6b82d9f@redhat.com>
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 04:12:49PM +0800, Jason Wang wrote:
>=20
> On 2019/8/12 =E4=B8=8B=E5=8D=885:49, Michael S. Tsirkin wrote:
> > On Mon, Aug 12, 2019 at 10:44:51AM +0800, Jason Wang wrote:
> > > On 2019/8/11 =E4=B8=8A=E5=8D=881:52, Michael S. Tsirkin wrote:
> > > > On Fri, Aug 09, 2019 at 01:48:42AM -0400, Jason Wang wrote:
> > > > > Hi all:
> > > > >=20
> > > > > This series try to fix several issues introduced by meta data
> > > > > accelreation series. Please review.
> > > > >=20
> > > > > Changes from V4:
> > > > > - switch to use spinlock synchronize MMU notifier with accessor=
s
> > > > >=20
> > > > > Changes from V3:
> > > > > - remove the unnecessary patch
> > > > >=20
> > > > > Changes from V2:
> > > > > - use seqlck helper to synchronize MMU notifier with vhost work=
er
> > > > >=20
> > > > > Changes from V1:
> > > > > - try not use RCU to syncrhonize MMU notifier with vhost worker
> > > > > - set dirty pages after no readers
> > > > > - return -EAGAIN only when we find the range is overlapped with
> > > > >     metadata
> > > > >=20
> > > > > Jason Wang (9):
> > > > >     vhost: don't set uaddr for invalid address
> > > > >     vhost: validate MMU notifier registration
> > > > >     vhost: fix vhost map leak
> > > > >     vhost: reset invalidate_count in vhost_set_vring_num_addr()
> > > > >     vhost: mark dirty pages during map uninit
> > > > >     vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
> > > > >     vhost: do not use RCU to synchronize MMU notifier with work=
er
> > > > >     vhost: correctly set dirty pages in MMU notifiers callback
> > > > >     vhost: do not return -EAGAIN for non blocking invalidation =
too early
> > > > >=20
> > > > >    drivers/vhost/vhost.c | 202 +++++++++++++++++++++++++-------=
----------
> > > > >    drivers/vhost/vhost.h |   6 +-
> > > > >    2 files changed, 122 insertions(+), 86 deletions(-)
> > > > This generally looks more solid.
> > > >=20
> > > > But this amounts to a significant overhaul of the code.
> > > >=20
> > > > At this point how about we revert 7f466032dc9e5a61217f22ea34b2df9=
32786bbfc
> > > > for this release, and then re-apply a corrected version
> > > > for the next one?
> > >=20
> > > If possible, consider we've actually disabled the feature. How abou=
t just
> > > queued those patches for next release?
> > >=20
> > > Thanks
> > Sorry if I was unclear. My idea is that
> > 1. I revert the disabled code
> > 2. You send a patch readding it with all the fixes squashed
> > 3. Maybe optimizations on top right away?
> > 4. We queue *that* for next and see what happens.
> >=20
> > And the advantage over the patchy approach is that the current patche=
s
> > are hard to review. E.g.  it's not reasonable to ask RCU guys to revi=
ew
> > the whole of vhost for RCU usage but it's much more reasonable to ask
> > about a specific patch.
>=20
>=20
> Ok. Then I agree to revert.
>=20
> Thanks

Great, so please send the following:
- revert
- squashed and fixed patch

--=20
MST

