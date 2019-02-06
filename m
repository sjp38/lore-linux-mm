Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4159FC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:48:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA827217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:48:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA827217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82BC78E00D1; Wed,  6 Feb 2019 15:48:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D9768E00CE; Wed,  6 Feb 2019 15:48:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C8F38E00D1; Wed,  6 Feb 2019 15:48:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8698E00CE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:48:00 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q3so8143685qtq.15
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:48:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=2YxGeMIws+59fN/fDtm5Ge77uqAKKFfWrDJfhqFp2H4=;
        b=Zhc7dgm/I68jX41fsPP+dxl7jjLlMfB95swCw9xPjnhsea4vvBeUwIUwxkf1GF15G7
         wdn6Z5a/y055MW1DrZ45JkUxdD2Bn3ZVR1dMoGeN5nUmImptG9dmkm2HuIZAXZd+EAq6
         LjKGWcm/kZYWDDBjrVla890WzsOtbAfr/TmRz+AmtpoW2CPjJ2bfuzk4wpq7fu0ILPrj
         EbENtDZRU2wimOmJ2aIJpbkIl83W1lfAO/oWCUmUiF0QaEaMQ9xnc9KQEQ4XkIrB3KUq
         iQkRXRvBeKmWitL98fgD1LpL7kn1/klycy+CjLfULd4PBUHFeZzYouHMiHVb8ysSI4k4
         lC7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub/vf2v0vaCs9TcwDOcjmg656VfcnSccY58kgVT3GE95PiRhKeO
	v/2g/rAp9Uz3oWW7GBlf2gBkYgy17s0Ley6b8gLmdNHPp6dhvuvuH8TRRKlFAwsTXSIacJj72IJ
	s7NpO0Oc3hSN7GQ9pLL1V4S1dzDxxi6q1ZOodtSyyEoejV9iE5ZJIgmC65/b0IC2yDw==
X-Received: by 2002:a0c:fb43:: with SMTP id b3mr9277411qvq.13.1549486079951;
        Wed, 06 Feb 2019 12:47:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaRnEJ1seDjffXsDrVo5qAQVFOdv0pp0UOCdpq0pBosYhF436M7Mq6FNf7Q+ab4Oq1d63Ab
X-Received: by 2002:a0c:fb43:: with SMTP id b3mr9277391qvq.13.1549486079525;
        Wed, 06 Feb 2019 12:47:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549486079; cv=none;
        d=google.com; s=arc-20160816;
        b=t1p2TALC5xKMqDfK4WBPz/jLMpMFOgHXOhLMj8lPItUW0diXr3aoSuG3tOY+72eFzV
         lF3uKPZxcGvl3RLFBKJLz+ppeEtcWlJC0p0u/H/hD0vhU5ICb+fi1jSJ7OnuGBBH0kZ4
         Bs6Nx3XuuM2KoGPDIv5Xhkn9cF3j+ew8OYHr86UGIZ7IigB390uMRxl0ZnVRwMAC+RgV
         jMvmikg2Lk37knclojLkKxiRCT2w5t9CNAR5CyBUvYdrky5jnHtpJTBOd5/ll7SVqmpn
         hFNI+c1OWEvAi/Pl9e337eXu6J4WPQDKOwZLCbXfSJyk9JiS5O5TDuc1Udyud0iQfY1S
         p4Sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=2YxGeMIws+59fN/fDtm5Ge77uqAKKFfWrDJfhqFp2H4=;
        b=l5CDLI6BYrlI1r34ie7Mfuf+QTpxQtgQFWm1bnO8zhv+6/NeffTKaApDBnr8H5xPrZ
         IA7GxngHF4zm3CixrRfIK7bwMNla+LTxAO5KU2qC9vKygMYVlM9escxMg98/Ga/QjVQW
         gU+dSUL9D2oI6FoO014l5PO+CwRZ7F2/2lfra9CCzSb7y3dSDOIPaPAbH53EorL+sUCX
         m9Agp3+P5QUU3CKyJA7gkppW801jcpc1OF0rRW7gyZYDVEtISEIFqKrndMaQ1fwDyDVf
         YXPQM4I+ZGcCjKRFupnUsjnry+wRE6K3KLXlNoy3Dbvkl0T/tSTDYZQxb0RP/mWwgECE
         wjjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e17si5023069qkj.109.2019.02.06.12.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 12:47:59 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3FFAF804F4;
	Wed,  6 Feb 2019 20:47:58 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CECC55C1B2;
	Wed,  6 Feb 2019 20:47:55 +0000 (UTC)
Message-ID: <fbdeccb01f7d0ba2f6ebb69660b7aa3d99690042.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Jan
 Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
 lsf-pc@lists.linux-foundation.org,  linux-rdma@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,  John Hubbard
 <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, Dan Williams
 <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Michal
 Hocko <mhocko@kernel.org>
Date: Wed, 06 Feb 2019 15:47:53 -0500
In-Reply-To: <20190206204128.GR21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
	 <20190206194055.GP21860@bombadil.infradead.org>
	 <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
	 <20190206202021.GQ21860@bombadil.infradead.org>
	 <a8dc27e81182060b3480127332c77ac624abcb22.camel@redhat.com>
	 <20190206204128.GR21860@bombadil.infradead.org>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-v2GlgXLGc1VDjmRb7kC5"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 06 Feb 2019 20:47:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-v2GlgXLGc1VDjmRb7kC5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 12:41 -0800, Matthew Wilcox wrote:
> On Wed, Feb 06, 2019 at 03:28:35PM -0500, Doug Ledford wrote:
> > On Wed, 2019-02-06 at 12:20 -0800, Matthew Wilcox wrote:
> > > On Wed, Feb 06, 2019 at 03:16:02PM -0500, Doug Ledford wrote:
> > > > On Wed, 2019-02-06 at 11:40 -0800, Matthew Wilcox wrote:
> > > > > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wro=
te:
> > > > > > though? If we only allow this use case then we may not have to =
worry about
> > > > > > long term GUP because DAX mapped files will stay in the physica=
l location
> > > > > > regardless.
> > > > >=20
> > > > > ... except for truncate.  And now that I think about it, there wa=
s a
> > > > > desire to support hot-unplug which also needed revoke.
> > > >=20
> > > > We already support hot unplug of RDMA devices.  But it is extreme. =
 How
> > > > does hot unplug deal with a program running from the device (someth=
ing
> > > > that would have returned ETXTBSY)?
> > >=20
> > > Not hot-unplugging the RDMA device but hot-unplugging an NV-DIMM.
> > >=20
> > > It's straightforward to migrate text pages from one DIMM to another;
> > > you remove the PTEs from the CPU's page tables, copy the data over an=
d
> > > pagefaults put the new PTEs in place.  We don't have a way to do simi=
lar
> > > things to an RDMA device, do we?
> >=20
> > We don't have a means of migration except in the narrowly scoped sense
> > of queue pair migration as defined by the IBTA and implemented on some
> > dual port IB cards.  This narrowly scoped migration even still involves
> > notification of the app.
> >=20
> > Since there's no guarantee that any other port can connect to the same
> > machine as any port that's going away, it would always be a
> > disconnect/reconnect sequence in the app to support this, not an under
> > the covers migration.
>=20
> I don't understand you.  We're not talking about migrating from one IB
> card to another, we're talking about changing the addresses that an STag
> refers to.

You said "now that I think about it, there was a desire to support hot-
unplug which also needed revoke".  For us, hot unplug is done at the
device level and means all connections must be torn down.  So in the
context of this argument, if people want revoke so DAX can migrate from
one NV-DIMM to another, ok.  But revoke does not help RDMA migrate.

If, instead, you mean that you want to support hot unplug of an NV-DIMM
that is currently the target of RDMA transfers, then I believe
Christoph's answer on this is correct.  It all boils down to which
device you are talking about doing the hot unplug on.

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-v2GlgXLGc1VDjmRb7kC5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbR/kACgkQuCajMw5X
L91T8Q//aNjsSFtXDnw9aQVHjEgaDUPAYp2QhT6rVK0ClhXiUiaP32FB0XYzeCCR
zXGaQydIteslRpddKI444p3f5lf8ysE/xVFqilSCJOIt2XypGyMk/pIRyGriERXD
rf8vljgMPGUiI5tCLx/AmSIlNSDkeRI5RbAsJlvFu15Mybgyj8+zeBz+eif7d20p
7lwAX9xSXJ6t9aQKM2P/wbrttXrIZDoKGvqm8eyy7wgzldnKgoemmMIdWqpj+vqJ
fus9lfFLjvt+3IsI7tbvT2hGAoRdSDHWnR0BxDhoWpwIdsJ+0cbwKCju9F+sdWg2
kjD6Fi4XpqgIl/K+4zgGxIPNl2LJ04FfXv/sfgI3ut3zO++J1QZYbKLMQ+wjykhg
6HVDIKCbe8kN3kT+vrUNzzxKQRFApZ9xrF+khoTTxYH2zaShIWi/3hzobtXIhpBh
jpoAiYr+iI0oOrHBgeWhjkuTDJ09H/MaokkL0PqLAp8tS+ZHz6muMOHS5imAID0w
ZuSNSKPJrmuMQp7Ze761NwI+/ABvM3XhT+JZGfrrjJb+UQZwVVW5mLK7bkgG1ZCv
aaZzo8UY6TBK2QOpdENbBVra8JnVy7+QdklWtUObatYTg05lwHtiJ8cz3jqY/+rA
yigK1CEB/QbkTp705ydzbiEUl2uRG3STxqKmaCiilOiqD/olhwU=
=lD5/
-----END PGP SIGNATURE-----

--=-v2GlgXLGc1VDjmRb7kC5--

