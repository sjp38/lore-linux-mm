Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A42EC8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:32:56 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f13-v6so7928904pgs.15
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:32:56 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id p126-v6si36531770pfb.77.2018.09.24.08.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 08:32:55 -0700 (PDT)
Date: Mon, 24 Sep 2018 16:32:35 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: Warning after memory hotplug then online.
Message-ID: <20180924163235.0000184b@huawei.com>
In-Reply-To: <20180924124203.GA4885@techadventures.net>
References: <20180924130701.00006a7b@huawei.com>
	<20180924123917.GA4775@techadventures.net>
	<20180924124203.GA4885@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linuxarm@huawei.com

On Mon, 24 Sep 2018 14:42:03 +0200
Oscar Salvador <osalvador@techadventures.net> wrote:

> On Mon, Sep 24, 2018 at 02:39:17PM +0200, Oscar Salvador wrote:
> > On Mon, Sep 24, 2018 at 01:07:01PM +0100, Jonathan Cameron wrote: =20
> > >=20
> > > Hi All,
> > >=20
> > > This is with some additional patches on top of the mm tree to support
> > > arm64 memory hot plug, but this particular issue doesn't (at first gl=
ance)
> > > seem to be connected to that.  It's not a recent issue as IIRC I
> > > disabled Kconfig for cgroups when starting to work on this some time =
ago
> > > as a quick and dirty work around for this. =20
> >=20
> > Hi Jonathan,
> >=20
> > would you mind to describe the steps you are taking?
> > You are adding the memory, and then you online it? =20
>=20
> I forgot to ask.
> Does this warning only show up with 4.19.0-rc4-mm1-00209-g70dc260f963a, o=
r you can
> trigger it with an older version?
> Do you happen to know the last one that did not trigger that warning?
>=20
> Thanks

=46rom memory perhaps 6 months back. Will take a while to backport the patch =
stack
far enough to try anything old now.

I'll look at this later in the week.

Thanks,

Jonathan
