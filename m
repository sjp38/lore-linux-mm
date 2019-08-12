Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEA20C41514
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:02:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 813CC20842
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:02:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="VMgdsQq0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 813CC20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 202796B0003; Mon, 12 Aug 2019 09:02:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18C7D6B0005; Mon, 12 Aug 2019 09:02:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 053256B0006; Mon, 12 Aug 2019 09:02:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0202.hostedemail.com [216.40.44.202])
	by kanga.kvack.org (Postfix) with ESMTP id CF5676B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:02:54 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7F9EB124C
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:02:54 +0000 (UTC)
X-FDA: 75813790668.13.712FE66
Received: from filter.hostedemail.com (10.5.16.251.rfc1918.com [10.5.16.251])
	by smtpin13.hostedemail.com (Postfix) with ESMTP id 5F9EE18140B60
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:02:54 +0000 (UTC)
X-HE-Tag: game46_8db43b0f6754d
X-Filterd-Recvd-Size: 6477
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:02:53 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id e8so2137060qtp.7
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 06:02:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=I794i5k43EsX/FqVLogBrtzHtLMobYzeCJsdWXiK9Gc=;
        b=VMgdsQq00foWkXG/3nO+dBstUoK1bGkCBdbj9tS6O2XJlAF+Gd74zMHMUkA+Njtq4M
         1/R9J5gzrQ28tiWtpEqv2TjemV4M0eUiyIrSXf3PQ8hy0bwMcgJk12CEU13SqDS3og6j
         JNN5DHxPwGYfzdPhRKhbUFwfch3e+YN+7HQiep9xP8CG++3zdsw5PnkTxkB2wXiq4SvK
         Jc/cZ3HS14Cb68kj4QXOugj+o8lOW80EABX+K7Y83ls68HVVwPHmyEC64WGA0jWTztDl
         Bgnp7cqMgeUbOoIkbiXSIXIHXYfgIR+WzAN3wNxJXn3/4k/pz1vaR9bWK24wuzC3Bdl/
         +Scg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=I794i5k43EsX/FqVLogBrtzHtLMobYzeCJsdWXiK9Gc=;
        b=SbEtgd6OkBopAAahlgzSknqbGdmb1fSun1kc6fctKFWfC3JKkc/IT5rVo36kjtS5Ys
         PIWdHTuhmRxVEz4buswY0RN0aHJnneEvOAzh1Z5/aZ8vFbyNMubYlIHAD2u7aktHXSL/
         neuRDEHtW+u71XRaUwM/lkhc3MD8OmqCZmluLA9DpaTl9YO+fETg067p8HANIbuEmWc0
         ForAXAaSkiMeKLYf6vXFP5M2NcP3F8gf8L7dds2PSNRXUDK2Nc/P/kSjTL1lF/+CNX2Y
         /eJpofPIVJTV5IyEml6TzO2ruco5gLvvtzXnabxjOK9qgRCEnAtxYRXCfNsiMq67VGVX
         7WGA==
X-Gm-Message-State: APjAAAWC3V4aEVmbQ/38JQ16pllEvYuMTgvWUqDZjqzHZc6M8ORtGUa7
	G1fALk+xd8aUPoIjzm57W3Y7BQ==
X-Google-Smtp-Source: APXvYqxZv3qaTOwcS5IthcJTSrZw2AL6CRuxLGSASG1s5/gI7k9gv8676nfdtEsaySWFu9y0gecVIg==
X-Received: by 2002:a0c:f687:: with SMTP id p7mr8778029qvn.160.1565614973155;
        Mon, 12 Aug 2019 06:02:53 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f22sm42714130qkk.45.2019.08.12.06.02.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Aug 2019 06:02:52 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hx9yO-0007Sg-5c; Mon, 12 Aug 2019 10:02:52 -0300
Date: Mon, 12 Aug 2019 10:02:52 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Message-ID: <20190812130252.GE24457@ziepe.ca>
References: <20190809054851.20118-1-jasowang@redhat.com>
 <20190810134948-mutt-send-email-mst@kernel.org>
 <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
 <20190812054429-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190812054429-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 05:49:08AM -0400, Michael S. Tsirkin wrote:
> On Mon, Aug 12, 2019 at 10:44:51AM +0800, Jason Wang wrote:
> >=20
> > On 2019/8/11 =E4=B8=8A=E5=8D=881:52, Michael S. Tsirkin wrote:
> > > On Fri, Aug 09, 2019 at 01:48:42AM -0400, Jason Wang wrote:
> > > > Hi all:
> > > >=20
> > > > This series try to fix several issues introduced by meta data
> > > > accelreation series. Please review.
> > > >=20
> > > > Changes from V4:
> > > > - switch to use spinlock synchronize MMU notifier with accessors
> > > >=20
> > > > Changes from V3:
> > > > - remove the unnecessary patch
> > > >=20
> > > > Changes from V2:
> > > > - use seqlck helper to synchronize MMU notifier with vhost worker
> > > >=20
> > > > Changes from V1:
> > > > - try not use RCU to syncrhonize MMU notifier with vhost worker
> > > > - set dirty pages after no readers
> > > > - return -EAGAIN only when we find the range is overlapped with
> > > >    metadata
> > > >=20
> > > > Jason Wang (9):
> > > >    vhost: don't set uaddr for invalid address
> > > >    vhost: validate MMU notifier registration
> > > >    vhost: fix vhost map leak
> > > >    vhost: reset invalidate_count in vhost_set_vring_num_addr()
> > > >    vhost: mark dirty pages during map uninit
> > > >    vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
> > > >    vhost: do not use RCU to synchronize MMU notifier with worker
> > > >    vhost: correctly set dirty pages in MMU notifiers callback
> > > >    vhost: do not return -EAGAIN for non blocking invalidation too=
 early
> > > >=20
> > > >   drivers/vhost/vhost.c | 202 +++++++++++++++++++++++++----------=
-------
> > > >   drivers/vhost/vhost.h |   6 +-
> > > >   2 files changed, 122 insertions(+), 86 deletions(-)
> > > This generally looks more solid.
> > >=20
> > > But this amounts to a significant overhaul of the code.
> > >=20
> > > At this point how about we revert 7f466032dc9e5a61217f22ea34b2df932=
786bbfc
> > > for this release, and then re-apply a corrected version
> > > for the next one?
> >=20
> >=20
> > If possible, consider we've actually disabled the feature. How about =
just
> > queued those patches for next release?
> >=20
> > Thanks
>=20
> Sorry if I was unclear. My idea is that
> 1. I revert the disabled code
> 2. You send a patch readding it with all the fixes squashed
> 3. Maybe optimizations on top right away?
> 4. We queue *that* for next and see what happens.
>=20
> And the advantage over the patchy approach is that the current patches
> are hard to review. E.g.  it's not reasonable to ask RCU guys to review
> the whole of vhost for RCU usage but it's much more reasonable to ask
> about a specific patch.

I think there are other problems here too, I don't like that the use
of mmu notifiers is so different from every other driver, or that GUP
is called under spinlock.

So I favor the revert and try again approach as well. It is hard to
get a clear picture with these endless bug fix patches

Jason

