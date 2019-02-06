Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24050C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:32:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1EF02186A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:32:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1EF02186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BA1B8E00E9; Wed,  6 Feb 2019 13:32:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 190648E00E8; Wed,  6 Feb 2019 13:32:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A6228E00E9; Wed,  6 Feb 2019 13:32:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4E318E00E8
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:32:20 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id i18so2560562qtm.21
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:32:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=ds9w2i+hSlptjkxNA9Bejn/oe0vCN/T2/ie7S+Niks0=;
        b=nW0/Q8vBNChqAOwgJQ21KvAXDrW3KAwVqI8yMbq5+FsT8cfTa5czRjQiGNL45w+rvh
         FLTdNkR3++mH7ezPpJdttnr81mAW92P8LLtFDfX5SdkQONSaOYzU90M/Adr4fFsU9DYa
         YanThX0xTs1OiCzPdKl7cIOY9u7gOHxQNi/sOJutafzVNHC0KEFs0mpUdx/fua6Juenx
         nmgBaIjL8Vn/FB+IG2bsEf/goUch08fgVN6UM4/nzch5e1YBXrJUk+Fk0Euvb8Ucn5wB
         MwjdEIwerLWXciYqbhco9+9iEckswlatRSaxMbgoczhZx3P0x12TAZYGkr4EEOSNgHhK
         ccew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub2AwoazgXkM7+XvkuP8dzPYQcL2yaT6MlMI4EgA/ELs4/cud1M
	m1+fydTKDVnaT7M7sKZ5gV4SNDKQ9dxxA8W9FfAFrCiZbh+eFSYRo6wK5e+aYcKZ17NWQ7dLoMV
	ax69bh3ya3JGbxingpiFgInBzcgGc2Go1cV47QqG4mmFCwedAfIrm3jb53M5laX6Ypg==
X-Received: by 2002:a05:620a:149c:: with SMTP id w28mr8047900qkj.321.1549477940527;
        Wed, 06 Feb 2019 10:32:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib5lxkteGGKQxeT9LfxnXZxgfvVCgeD+oWc3YpNW2Tck5d+8SUWMcaWoEx+nVdGVXCIhsCG
X-Received: by 2002:a05:620a:149c:: with SMTP id w28mr8047876qkj.321.1549477940051;
        Wed, 06 Feb 2019 10:32:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549477940; cv=none;
        d=google.com; s=arc-20160816;
        b=Pp+bu3HFoncBfAOQ61Z1zwqQI389wFFHJKkijtrjigIB3k70jBwHSg9vcZz01bLG7L
         aPJiqhFxuVRAMH1B1UFfs7q/oyTLyINmZh6hfo/nFIgd1+T731RJFo80uSoKyep3BLCR
         672LkhgznLUpMHl3RLWXDzA8+LTtJQEOOW8nWGFOT1AAFBKcJhTXAYRXkWBl1+KYOdrR
         b3sR1ugPOpS3hHWJbooXi20jkcb0Ct3fBy4rGYiZcWUghuqLMsT1+U+L1bGBhnh7/pZ+
         six9V5Jah58MZmOflhu3KbqWkxVPejWYgT1nlh/VnBjSQshkhTpL0E1CHkiWKFCsUiBu
         hfVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=ds9w2i+hSlptjkxNA9Bejn/oe0vCN/T2/ie7S+Niks0=;
        b=TCTIv81HmjvrVGJhXIuX48YJkUbpkg8dsfYL/3l1J1TtxcUbaxto1jqBOpoS9z769D
         UWkoCg7/31/oy9mlX6WVmdXo5k7vYUEsqHVopZzMeR48RPcMclzADkqOiMwPAyZXTVv/
         Ty4MUyuV2xqj118WjW7wO2eO9MPVQyWrHpCAudGNL7pSfKbT/DW1VZHNUFKwKWVkm48Y
         9gd+hrV76wRNQCDzvyk3JkwY94W+PWO40JYUU3FQQX8wmYU7omqVqpZ1u+z/j/i9SX4T
         QvyAcJRXRkhgbPe37tEayIDxu4xrJKcKhEgpdEE3Cki7YqvPamy08ewAWUekNHZsx8iT
         FYbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 35si17580qth.228.2019.02.06.10.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 10:32:20 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DF9EFC070142;
	Wed,  6 Feb 2019 18:32:18 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7B25B600CC;
	Wed,  6 Feb 2019 18:32:16 +0000 (UTC)
Message-ID: <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Matthew Wilcox <willy@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>, 
 lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org, 
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Hubbard
 <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, Dan Williams
 <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Michal
 Hocko <mhocko@kernel.org>
Date: Wed, 06 Feb 2019 13:32:04 -0500
In-Reply-To: <20190206175233.GN21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-DH9hcUhnriJe4f5iVPKX"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 06 Feb 2019 18:32:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-DH9hcUhnriJe4f5iVPKX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 09:52 -0800, Matthew Wilcox wrote:
> On Wed, Feb 06, 2019 at 10:31:14AM -0700, Jason Gunthorpe wrote:
> > On Wed, Feb 06, 2019 at 10:50:00AM +0100, Jan Kara wrote:
> >=20
> > > MM/FS asks for lease to be revoked. The revoke handler agrees with th=
e
> > > other side on cancelling RDMA or whatever and drops the page pins.=
=20
> >=20
> > This takes a trip through userspace since the communication protocol
> > is entirely managed in userspace.
> >=20
> > Most existing communication protocols don't have a 'cancel operation'.
> >=20
> > > Now I understand there can be HW / communication failures etc. in
> > > which case the driver could either block waiting or make sure future
> > > IO will fail and drop the pins.=20
> >=20
> > We can always rip things away from the userspace.. However..
> >=20
> > > But under normal conditions there should be a way to revoke the
> > > access. And if the HW/driver cannot support this, then don't let it
> > > anywhere near DAX filesystem.
> >=20
> > I think the general observation is that people who want to do DAX &
> > RDMA want it to actually work, without data corruption, random process
> > kills or random communication failures.
> >=20
> > Really, few users would actually want to run in a system where revoke
> > can be triggered.
> >=20
> > So.. how can the FS/MM side provide a guarantee to the user that
> > revoke won't happen under a certain system design?
>=20
> Most of the cases we want revoke for are things like truncate().
> Shouldn't happen with a sane system, but we're trying to avoid users
> doing awful things like being able to DMA to pages that are now part of
> a different file.

Why is the solution revoke then?  Is there something besides truncate
that we have to worry about?  I ask because EBUSY is not currently
listed as a return value of truncate, so extending the API to include
EBUSY to mean "this file has pinned pages that can not be freed" is not
(or should not be) totally out of the question.

Admittedly, I'm coming in late to this conversation, but did I miss the
portion where that alternative was ruled out?

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-DH9hcUhnriJe4f5iVPKX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbKCQACgkQuCajMw5X
L920cRAAnglIz8v9Y3ddVGc1YP+7FZvhUcoRrnr3eDu92uCGxJ+IzXOIR+qrE1Ja
BFWj8XxJ0AyxugPnT4qCovPLf3qQtMD3mWQAnBqlvZDsGCla+9vLgTh39uUOgLjB
tCD3jXB0XSe3+mLiSGEze+I4fx+qbnRWJaQRJlkycdl86aMHIFs930fGmaGCChoY
JobkYZZh+5kVqpx4L632T9eSq4WxkpXnkSnxqgXx2kZxO2m3S1wd5SI8dMxxlwI8
rYGHTQAOSWlK4Z+GUuZhlimosmhvCWcFworCvR0PhtS47uyDp0S8DnrSdb4+hMOP
yYKbx9LkNxRqvgfMzhzAS6l4mrq8Sd7K3iHzCtSWqBOyxk7l5N7kWnEWI8GPMgtp
hDEjR3SRiltVyURQAe1HVIB3r5IAlqTFgw7cRYi7Z39xh5CG1JXiU5jcopoX0p0c
qTFt/tMwmg6qBLgKC3i7swQtZIzPfVrvNgLvVGUoikzGmXLikviZhPvB709diIXC
la90MeW0jxlXumEWYjSVoyxRrlsSWor+zMKhBvCKbK17TIB3H+OlMalElaXjHF7j
SG4pNjFXQSBoFkpWJjK5jhtKXJeikHBp0nLS6bFxkKnDoT7SKucLdt3eITV7JAY3
sozUj0Reu4fWLF/Y1aVIxRp+kgrlUnlBbO73inPHRpnpDgeNzPc=
=GR/4
-----END PGP SIGNATURE-----

--=-DH9hcUhnriJe4f5iVPKX--

