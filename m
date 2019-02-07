Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72802C169C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 01:57:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21757218EA
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 01:57:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21757218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA1E48E000F; Wed,  6 Feb 2019 20:57:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A50848E0002; Wed,  6 Feb 2019 20:57:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9407A8E000F; Wed,  6 Feb 2019 20:57:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6585F8E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 20:57:30 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a65so3898511qkf.19
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 17:57:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=5vz9vLPgJIpzSijCtCvQfNoHeC+86byLKOmZP8KbT/s=;
        b=BOq2joaBHb5MBaY5memIIkfDWpJN3rAQC640LbDlmaqFb7FPZ/rvMCFqWiV0tLSdtv
         V4iN/fV9PYqsY7l/Woi8FFrZ6zPhg7RoQ+XngGnIrsP6jH4lvKacfHdpPhv5DKTw2bfF
         lG0+eaGsqM16QIAHuzhsIPrAv+CXOMn6svCLCzMJg5bnqFxsGezXA62jUFPnLYC2GfQ0
         5m7SAtMwgKUc2TO/8OuGEXGx108MY+vTkqOw2DILgUHqapjiapq4bN61g5vchAqwdENQ
         r0MrknmlgFm3m71s6DJjqj0Ewc2Lj3OcyUiL1SDca/QzHyAhrdebzeDxcR9kwM0qYRo8
         zcDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub8pT4Pcc2UlC38X9jdl/zfzx82NJvN/H1D1rOhNz5u78BY6Zlq
	ueyVdXkytnXxm7m4EdUlD/mpOP6/PlUkyyzQYWddy0J9A89RI5h9mTIPiccYCMK5lgGwjNGyVaZ
	pCBKj0rSQA1KGcyfQyf59Hkf/8xkiKGs+6eCRcPX1FpQYoHnOe9WksPrrQHE8EYWugg==
X-Received: by 2002:ac8:1695:: with SMTP id r21mr8075097qtj.226.1549504650152;
        Wed, 06 Feb 2019 17:57:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJb5eBs1VuhIv5XfhZCDxD1ZMMB2MPxSgwTghhRfIONMEnPULmZkbf5BifG0MUxwg4c8va
X-Received: by 2002:ac8:1695:: with SMTP id r21mr8075075qtj.226.1549504649436;
        Wed, 06 Feb 2019 17:57:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549504649; cv=none;
        d=google.com; s=arc-20160816;
        b=H5zObKTmfw6e3Ln1j/orW7yYQbVAkXlbirdMLy6dviYOSqObDEIUhOWo5PTtdoR4wp
         USelemFA3WYr/Wg5n6hJfXRm/d/dOoc6wTuYoRVBmG+KdHecKcOmt6MLbiZdPRwieRyV
         H4haIbHOGiZ8c4nuD/WBScFH4Z6aRk8M7p/oonsLW2MnlmZTQCeR/P1e8AEMrLgCwEYn
         Mi7tjE832HlCKTSN0O/yHmn56GNH4Iy47jprADoXJFJxQrucFGIMpro9nwShIoTKXIbS
         qVawOm0hDPlsuZErQrPaMdJ/LYwja/rsnsxd4KlaaHd1yT/dg+XCa0kQyv2RJNkOJcgS
         bE5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=5vz9vLPgJIpzSijCtCvQfNoHeC+86byLKOmZP8KbT/s=;
        b=FjVkOhPr9P1dGdbgugUwptUavS/LBtFtocapOYX40bt9rEyMTq5jtxI6Tj2CdaNCeK
         zh+IactFZcOIynlHmaGdbM48KwHoUC7iYw9ipmpyDDOzEvJgnt2othU1dXKF21r+y2xQ
         ueNwhfHGzHru6DEbDm5m+SuxOnArStN6YOQwuaQs9NPQ7M7GiO/vRG0JwgeqOHUQG2wv
         krBYlMuE+VRkUFq8/3GN8aQ+CB7TD7h8Sd6w9FBSZdYVWsns3psoXN8fiBAos9BxrKnV
         pDIuniEvXqVpsZFocSTwNQ4Bb7fRzMnZgFMa4E+C6LD+/7cBu+vmKwBNR3R80PIkOuUR
         QPjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x53si531760qvh.161.2019.02.06.17.57.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 17:57:29 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E915619CF24;
	Thu,  7 Feb 2019 01:57:27 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 29F6B691BA;
	Thu,  7 Feb 2019 01:57:24 +0000 (UTC)
Message-ID: <645c5e11b28ff10d354ae17ed3016bc895c9028b.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dave Chinner <david@fromorbit.com>, 
 Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>,
 Jan Kara <jack@suse.cz>,  Ira Weiny <ira.weiny@intel.com>,
 lsf-pc@lists.linux-foundation.org, linux-rdma <linux-rdma@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Jerome
 Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Date: Wed, 06 Feb 2019 20:57:22 -0500
In-Reply-To: <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
	 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
	 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
	 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-wpk6Y1FXNFOa7iPpHSPR"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 07 Feb 2019 01:57:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-wpk6Y1FXNFOa7iPpHSPR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 14:44 -0800, Dan Williams wrote:
> On Wed, Feb 6, 2019 at 2:25 PM Doug Ledford <dledford@redhat.com> wrote:
> > On Wed, 2019-02-06 at 15:08 -0700, Jason Gunthorpe wrote:
> > > On Thu, Feb 07, 2019 at 08:03:56AM +1100, Dave Chinner wrote:
> > > > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote=
:
> > > > > On Wed, 6 Feb 2019, Doug Ledford wrote:
> > > > >=20
> > > > > > > Most of the cases we want revoke for are things like truncate=
().
> > > > > > > Shouldn't happen with a sane system, but we're trying to avoi=
d users
> > > > > > > doing awful things like being able to DMA to pages that are n=
ow part of
> > > > > > > a different file.
> > > > > >=20
> > > > > > Why is the solution revoke then?  Is there something besides tr=
uncate
> > > > > > that we have to worry about?  I ask because EBUSY is not curren=
tly
> > > > > > listed as a return value of truncate, so extending the API to i=
nclude
> > > > > > EBUSY to mean "this file has pinned pages that can not be freed=
" is not
> > > > > > (or should not be) totally out of the question.
> > > > > >=20
> > > > > > Admittedly, I'm coming in late to this conversation, but did I =
miss the
> > > > > > portion where that alternative was ruled out?
> > > > >=20
> > > > > Coming in late here too but isnt the only DAX case that we are co=
ncerned
> > > > > about where there was an mmap with the O_DAX option to do direct =
write
> > > > > though? If we only allow this use case then we may not have to wo=
rry about
> > > > > long term GUP because DAX mapped files will stay in the physical =
location
> > > > > regardless.
> > > >=20
> > > > No, that is not guaranteed. Soon as we have reflink support on XFS,
> > > > writes will physically move the data to a new physical location.
> > > > This is non-negotiatiable, and cannot be blocked forever by a gup
> > > > pin.
> > > >=20
> > > > IOWs, DAX on RDMA requires a) page fault capable hardware so that
> > > > the filesystem can move data physically on write access, and b)
> > > > revokable file leases so that the filesystem can kick userspace out
> > > > of the way when it needs to.
> > >=20
> > > Why do we need both? You want to have leases for normal CPU mmaps too=
?
> > >=20
> > > > Truncate is a red herring. It's definitely a case for revokable
> > > > leases, but it's the rare case rather than the one we actually care
> > > > about. We really care about making copy-on-write capable filesystem=
s like
> > > > XFS work with DAX (we've got people asking for it to be supported
> > > > yesterday!), and that means DAX+RDMA needs to work with storage tha=
t
> > > > can change physical location at any time.
> > >=20
> > > Then we must continue to ban longterm pin with DAX..
> > >=20
> > > Nobody is going to want to deploy a system where revoke can happen at
> > > any time and if you don't respond fast enough your system either lock=
s
> > > with some kind of FS meltdown or your process gets SIGKILL.
> > >=20
> > > I don't really see a reason to invest so much design work into
> > > something that isn't production worthy.
> > >=20
> > > It *almost* made sense with ftruncate, because you could architect to
> > > avoid ftruncate.. But just any FS op might reallocate? Naw.
> > >=20
> > > Dave, you said the FS is responsible to arbitrate access to the
> > > physical pages..
> > >=20
> > > Is it possible to have a filesystem for DAX that is more suited to
> > > this environment? Ie designed to not require block reallocation (no
> > > COW, no reflinks, different approach to ftruncate, etc)
> >=20
> > Can someone give me a real world scenario that someone is *actually*
> > asking for with this?
>=20
> I'll point to this example. At the 6:35 mark Kodi talks about the
> Oracle use case for DAX + RDMA.
>=20
> https://youtu.be/ywKPPIE8JfQ?t=3D395

Thanks for the link, I'll review the panel.

> Currently the only way to get this to work is to use ODP capable
> hardware, or Device-DAX. Device-DAX is a facility to map persistent
> memory statically through device-file. It's great for statically
> allocated use cases, but loses all the nice things (provisioning,
> permissions, naming) that a filesystem gives you. This debate is what
> to do about non-ODP capable hardware and Filesystem-DAX facility. The
> current answer is "no RDMA for you".
>=20
> > Are DAX users demanding xfs, or is it just the
> > filesystem of convenience?
>=20
> xfs is the only Linux filesystem that supports DAX and reflink.

Is it going to be clear from the link above why reflink + DAX + RDMA is
a good/desirable thing?

> > Do they need to stick with xfs?
>=20
> Can you clarify the motivation for that question?

I did a little googling and research before I asked that question.=20
According to the documentation, other FSes can work with DAX too (namely
ext2 and ext4).  The question was more or less pondering whether or not
ext2 or ext4 + RDMA + DAX would solve people's problems without the
issues that xfs brings.

>  This problem exists
> for any filesystem that implements an mmap that where the physical
> page backing the mapping is identical to the physical storage location
> for the file data. I don't see it as an xfs specific problem. Rather,
> xfs is taking the lead in this space because it has already deployed
> and demonstrated that leases work for the pnfs4 block-server case, so
> it seems logical to attempt to extend that case for non-ODP-RDMA.
>=20
> > Are they
> > really trying to do COW backed mappings for the RDMA targets?  Or do
> > they want a COW backed FS but are perfectly happy if the specific RDMA
> > targets are *not* COW and are statically allocated?
>=20
> I would expect the COW to be broken at registration time. Only ODP
> could possibly support reflink + RDMA. So I think this devolves the
> problem back to just the "what to do about truncate/punch-hole"
> problem in the specific case of non-ODP hardware combined with the
> Filesystem-DAX facility.

If that's the case, then we are back to EBUSY *could* work (despite the
objections made so far).

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-wpk6Y1FXNFOa7iPpHSPR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbkIIACgkQuCajMw5X
L91Evg//SBibnwgXwOjP007M0LvpMBWOIkoB9F+nU3UqhTEPFeMUlyf2En8+5NvK
+HW7QW68QNt5kEcEVnWDB0ixvcEiaO4ma/RQeTODtB5ARtiduHXa6IFo/ndVVuwf
t8DAqtLamKEaORgQ52Km2a1QXDgIDGZzs6LrJMTIsv9NBh8hFmjA2CdgX1xk79lL
gxqdZupI18nTyzj91VaKeYUhSJSB160w2xtkfosZlx58mlrKocEOm+7irNQsj5xj
ElIDIVhcToRUROd0Qy14KNnQZWsjFcU2CDNpojGiXbHzF5I1aAcnU2WPurEMXKJ8
rl090f8TA33e1OM1ZDwpMuieE/b5IESS31KTQ06gFdtGUll+Suyr+2Ra6grEi1s6
8bc6vv1Fd2Dq7+JAISo2T1O94nTK0E1YdpyxCsuPBr/Av2Np02tpByIxND+vz7Ay
Ut52Xy5R3unsEnONn/XxkYRsXt06EMaVnd1cTZUdnvTVoiMz7P/+bbK310NzYnDL
5LSL+9W7ee5UWOngJ2Rme2p9+lZE8zzEwMr84kwzHpPfLYFLswT2FZ7ICGF3B/K+
hdowtSBW9MngzFsEfj4zUrz+wfyRa/+WHszt/CorYRkrpV7u7KQvHssoGpMVyzut
1QHb+rmYsKFwlqNDJ/Pbe+dARCq/RYvZ3UXCW6AQ+fNJjipOMVw=
=0el0
-----END PGP SIGNATURE-----

--=-wpk6Y1FXNFOa7iPpHSPR--

