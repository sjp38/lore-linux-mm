Return-Path: <SRS0=4eAG=W4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1099DC3A5A7
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 18:02:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BACB2190F
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 18:02:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BACB2190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 199916B0005; Sun,  1 Sep 2019 14:02:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 149846B0006; Sun,  1 Sep 2019 14:02:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 038386B0007; Sun,  1 Sep 2019 14:02:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0055.hostedemail.com [216.40.44.55])
	by kanga.kvack.org (Postfix) with ESMTP id D82FB6B0005
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 14:02:54 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7410D6D81
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 18:02:54 +0000 (UTC)
X-FDA: 75887122668.17.color59_8dab4419b1031
X-HE-Tag: color59_8dab4419b1031
X-Filterd-Recvd-Size: 6634
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 18:02:53 +0000 (UTC)
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 144DA7BDA1
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 18:02:52 +0000 (UTC)
Received: by mail-qt1-f198.google.com with SMTP id n59so1931081qtd.8
        for <linux-mm@kvack.org>; Sun, 01 Sep 2019 11:02:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to;
        bh=NtIlrG6bXqato3AHyRhqkP1r1EyQzXXXF+1WVjQfhrI=;
        b=bABw1YZIcdkjzh7jxjoBHn/E9eir4tbUZo6RizbgY3ZaNPiX0Pc0j7VndvRJqzLZ9q
         7M2hYJz90TVQMtQnUXV8TeZodMy5nbYOBmxo8W6hKHV76th2c5nH79iD8r6bzwbCRyJI
         8Mf2s/JL8tOojzUybL1VQdq3AwzFpBa+7ibH7I/wdViEDsbTJx9q7YiKwtFOtEvlw/nv
         8vuGktgrI6uZwncMmntPatS5tKlOsrmp3xoPpAqXSHj9nQ7yxUb7G10XikrW1Ro4L2vo
         JKY3UFFvJ6KL32BS5ski2aScJxoouEKLwNyieXetUjarfZS2AJ1w147QfBuqai3vbzyi
         YkCA==
X-Gm-Message-State: APjAAAU459MYJM4xpo8g+7Er2xc5LHmLjjXtVZFNU14vjpho87C7zRVA
	Qgd5xU5EIfbN8wy0OgCXA/5rnFhttmRZc3htAQPT6q5EPWiGXIxdx1v76J8GSDIsy/GPcRD9PmR
	bjuF+QxtfDgI=
X-Received: by 2002:a37:480d:: with SMTP id v13mr24849059qka.295.1567360971411;
        Sun, 01 Sep 2019 11:02:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRyGzOcE8hglKRycEb420hPDRNv3fnUOZqre0cmbUtVArhzSlANFmNqbwZR2kZ23xgEdav+Q==
X-Received: by 2002:a37:480d:: with SMTP id v13mr24849044qka.295.1567360971215;
        Sun, 01 Sep 2019 11:02:51 -0700 (PDT)
Received: from redhat.com (bzq-79-180-62-110.red.bezeqint.net. [79.180.62.110])
        by smtp.gmail.com with ESMTPSA id i20sm5379783qkk.67.2019.09.01.11.02.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Sep 2019 11:02:49 -0700 (PDT)
Date: Sun, 1 Sep 2019 14:02:44 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, jgg@ziepe.ca
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Message-ID: <20190901140220-mutt-send-email-mst@kernel.org>
References: <20190809054851.20118-1-jasowang@redhat.com>
 <20190810134948-mutt-send-email-mst@kernel.org>
 <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
 <20190812054429-mutt-send-email-mst@kernel.org>
 <663be71f-f96d-cfbc-95a0-da0ac6b82d9f@redhat.com>
 <20190819162733-mutt-send-email-mst@kernel.org>
 <9325de4b-1d79-eb19-306e-e7a8fa8cc1a5@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <9325de4b-1d79-eb19-306e-e7a8fa8cc1a5@redhat.com>
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 10:29:32AM +0800, Jason Wang wrote:
>=20
> On 2019/8/20 =E4=B8=8A=E5=8D=885:08, Michael S. Tsirkin wrote:
> > On Tue, Aug 13, 2019 at 04:12:49PM +0800, Jason Wang wrote:
> > > On 2019/8/12 =E4=B8=8B=E5=8D=885:49, Michael S. Tsirkin wrote:
> > > > On Mon, Aug 12, 2019 at 10:44:51AM +0800, Jason Wang wrote:
> > > > > On 2019/8/11 =E4=B8=8A=E5=8D=881:52, Michael S. Tsirkin wrote:
> > > > > > On Fri, Aug 09, 2019 at 01:48:42AM -0400, Jason Wang wrote:
> > > > > > > Hi all:
> > > > > > >=20
> > > > > > > This series try to fix several issues introduced by meta da=
ta
> > > > > > > accelreation series. Please review.
> > > > > > >=20
> > > > > > > Changes from V4:
> > > > > > > - switch to use spinlock synchronize MMU notifier with acce=
ssors
> > > > > > >=20
> > > > > > > Changes from V3:
> > > > > > > - remove the unnecessary patch
> > > > > > >=20
> > > > > > > Changes from V2:
> > > > > > > - use seqlck helper to synchronize MMU notifier with vhost =
worker
> > > > > > >=20
> > > > > > > Changes from V1:
> > > > > > > - try not use RCU to syncrhonize MMU notifier with vhost wo=
rker
> > > > > > > - set dirty pages after no readers
> > > > > > > - return -EAGAIN only when we find the range is overlapped =
with
> > > > > > >      metadata
> > > > > > >=20
> > > > > > > Jason Wang (9):
> > > > > > >      vhost: don't set uaddr for invalid address
> > > > > > >      vhost: validate MMU notifier registration
> > > > > > >      vhost: fix vhost map leak
> > > > > > >      vhost: reset invalidate_count in vhost_set_vring_num_a=
ddr()
> > > > > > >      vhost: mark dirty pages during map uninit
> > > > > > >      vhost: don't do synchronize_rcu() in vhost_uninit_vq_m=
aps()
> > > > > > >      vhost: do not use RCU to synchronize MMU notifier with=
 worker
> > > > > > >      vhost: correctly set dirty pages in MMU notifiers call=
back
> > > > > > >      vhost: do not return -EAGAIN for non blocking invalida=
tion too early
> > > > > > >=20
> > > > > > >     drivers/vhost/vhost.c | 202 +++++++++++++++++++++++++--=
---------------
> > > > > > >     drivers/vhost/vhost.h |   6 +-
> > > > > > >     2 files changed, 122 insertions(+), 86 deletions(-)
> > > > > > This generally looks more solid.
> > > > > >=20
> > > > > > But this amounts to a significant overhaul of the code.
> > > > > >=20
> > > > > > At this point how about we revert 7f466032dc9e5a61217f22ea34b=
2df932786bbfc
> > > > > > for this release, and then re-apply a corrected version
> > > > > > for the next one?
> > > > > If possible, consider we've actually disabled the feature. How =
about just
> > > > > queued those patches for next release?
> > > > >=20
> > > > > Thanks
> > > > Sorry if I was unclear. My idea is that
> > > > 1. I revert the disabled code
> > > > 2. You send a patch readding it with all the fixes squashed
> > > > 3. Maybe optimizations on top right away?
> > > > 4. We queue *that* for next and see what happens.
> > > >=20
> > > > And the advantage over the patchy approach is that the current pa=
tches
> > > > are hard to review. E.g.  it's not reasonable to ask RCU guys to =
review
> > > > the whole of vhost for RCU usage but it's much more reasonable to=
 ask
> > > > about a specific patch.
> > >=20
> > > Ok. Then I agree to revert.
> > >=20
> > > Thanks
> > Great, so please send the following:
> > - revert
> > - squashed and fixed patch
>=20
>=20
> Just to confirm, do you want me to send a single series or two?
>=20
> Thanks
>=20

One is fine.

--=20
MST

