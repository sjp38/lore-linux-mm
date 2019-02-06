Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F73EC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:54:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49DDA20823
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:54:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49DDA20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2EC38E00FD; Wed,  6 Feb 2019 15:54:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB7748E00E6; Wed,  6 Feb 2019 15:54:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7FB58E00FD; Wed,  6 Feb 2019 15:54:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 896C68E00E6
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:54:07 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v64so7639923qka.5
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:54:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=8+Rg4wWkUqa0+r7reInWP2k0E0kFj4cqF2t2Qup82ZA=;
        b=U1AUROHzDzHPq3MJVix1qDezyJUwFIKIVzE/WNmC4uGbDx1xjJSNqiPT2h6chT2QVj
         5X41ATm6YhtUeQ2BXWOELXT2DSIs0PVWWRos5z2ygyfiWpLbf9g7Mrx1Tkis+2n2fyyU
         n0y/7R+RzJKomh0eu6akJfbhtzAMWtXt5MCNRDz1UyKOKVwZorLdwVJqvDQhDuyUrno+
         a+MOdpu2MOVvdAlp4U+mrFtS/S2E9glS1WmmVrPmdAQcM/d6Xtw67zlf2V5ehQgczmQX
         TnqIjb1TQmgpy+JFoEQRkLRY4/aYPHHe5ZSRctTIl4DxWEvSI7qyuEMRjcIhs+tv2PFb
         P6Lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZrFYPBGGeWVDzcYNSWPenzqZIOHrSHBvNxXmv6rLzrH4Jh2Nj+
	hd85anKBgQNZmT1rgFow/hn364TBMsMgCDdHEaXNgUvW8r7sBfv7eQpBbRK3VeM2R/oPtAZJ5Zm
	b23OyQQVDP9GHqR9Fp41AAqjdTAgShptd25pTzOcdl7BBtBygiQsbr5kTrPsSBNKqqQ==
X-Received: by 2002:ac8:ecf:: with SMTP id w15mr9110852qti.359.1549486447328;
        Wed, 06 Feb 2019 12:54:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYRYdwIKv9Ok0bHZQ63pJB1u1v6LUpgiSeu1seH7I8KXMh9YqR+l985/KM0r+UYg8btdAnN
X-Received: by 2002:ac8:ecf:: with SMTP id w15mr9110839qti.359.1549486447001;
        Wed, 06 Feb 2019 12:54:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549486446; cv=none;
        d=google.com; s=arc-20160816;
        b=SMtsHApPDNCeuj+i4ZqoxGXrmT95+ZPSGG7amJrYN9nGeR0Lup8a8CEfvdWGsua6jX
         Y46hb8PI18//0U7qcXc9+LhhXWTL8Lrm1yOinY6JUL/Y7uOHlDuEhz1OzyDwG+rG4PGn
         BuHMJx6gOnXoGBtstecSoE7Rcb/IBUEb5UFO1kHeMyExxcq7RIDRM+c8bt83GhSa1C+Q
         PTxb4cLqpBfEOvkGcWS+49ssAcieOkDq1OjIHjtFKm+KoA0kqm7mv+E6ZUwZgIxLOJyn
         KbPWYRzeSoAEhxCVcMiI0sGqfkUxhlJmcGM9Jl9P0+dDm7gLZ41t8hiN5F1DZa8t8Do9
         HOYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=8+Rg4wWkUqa0+r7reInWP2k0E0kFj4cqF2t2Qup82ZA=;
        b=LAtlKAcY0lj4/WZwNtqBttcX+y8s+aCVcRlKePmqnum5vcXSTdLCnGDDNRX0ASMwVK
         5AIuTVZQkbjaJY5X1REZafgBEtEl7FQ7ktoYCE4wc713efPtc0Qf+YyC8G1dxQPDeh0M
         yOseLCcsv13lqC25iI2Bi4TVSyoINIjbYKyszt9cxQgrSmq+UpxvYuaFnLlrjTr1kyud
         GU0vbuq+KY5LiQteShTfZo1ggdA/PVGbsYt7DY3u0Liix+Pa540zKqRZGv5sjUPMplI0
         731c+EbUCrRSjfFjx11ziycbmVOJ0USW3JXDWh3nGTRnXtVrKDtrfCvZLfDVjloNFYbr
         qF3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f4si5318054qtk.237.2019.02.06.12.54.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 12:54:06 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 06BED7AE99;
	Wed,  6 Feb 2019 20:54:06 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 993DC62481;
	Wed,  6 Feb 2019 20:54:03 +0000 (UTC)
Message-ID: <a5b976cad6a578f0a6e6573acbf547ceb9dad6c7.camel@redhat.com>
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
Date: Wed, 06 Feb 2019 15:54:01 -0500
In-Reply-To: <20190206202021.GQ21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
	 <20190206194055.GP21860@bombadil.infradead.org>
	 <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
	 <20190206202021.GQ21860@bombadil.infradead.org>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-qMmM3LVuejBi/UYuzebx"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 06 Feb 2019 20:54:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-qMmM3LVuejBi/UYuzebx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 12:20 -0800, Matthew Wilcox wrote:
> On Wed, Feb 06, 2019 at 03:16:02PM -0500, Doug Ledford wrote:
> > On Wed, 2019-02-06 at 11:40 -0800, Matthew Wilcox wrote:
> > > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > > > though? If we only allow this use case then we may not have to worr=
y about
> > > > long term GUP because DAX mapped files will stay in the physical lo=
cation
> > > > regardless.
> > >=20
> > > ... except for truncate.  And now that I think about it, there was a
> > > desire to support hot-unplug which also needed revoke.
> >=20
> > We already support hot unplug of RDMA devices.  But it is extreme.  How
> > does hot unplug deal with a program running from the device (something
> > that would have returned ETXTBSY)?
>=20
> Not hot-unplugging the RDMA device but hot-unplugging an NV-DIMM.

Is an NV-DIMM the only thing we use DAX on?


--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-qMmM3LVuejBi/UYuzebx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbSWkACgkQuCajMw5X
L91cWw/+KzistDQ9VmIIUgMW9sZm4sOOkRYqqgNNyQuR0DEr0E46tfR2Bb7tXSvu
ZL0Ut9r4TsNA0P0d+2bjykL99zyiYUuDJLJOKbBt/JxcX7tNe8BFsw23hJgItUxQ
Thd6/1PQ0Da/zgRx05Pfwd+DWnDcNPAxTgMRFoAHxMj1EWpGOwlLaX9RFz18am4A
l1W6PDbX7qJNQDIr03F+T7H/tMv9dR5ENIoI2OyzyoANQcqbFQZty/+S5NAER9BI
4ljdIJ3vcTtxLworx6S42nH/cF9KnwOWNiO58uLWKzc3tf12IAQ6aQ+zkOZTgfca
/y+gD0MKI6rAbw1sbrl+xIiDJeBwz+jaBAqRWbQbv5vEZdl4oHk1L2JgHRnuFFWr
XO30wc72FUHJXkyjbhNFGsI2Xa/smeCZn/WCIGUY5iXYmcTUkS2TrIJg9Dpo/dd/
rFNP7CmFJ+Yga8Bp7LIhDuQTAb28AFBT/QUWb/vPHg8gBregYfUE8KVPjFDjD2YH
DvBTf2VcderUcFMM5Ibjc/00rutEZbNvP917bLdY3geo1e/HqR9GEY8QteslRpOm
tKTMdMJwSB/pnXza+J5NtcRiVpDY3qdyHOzrZJNd/6cihC8L8vUl8P31IgyfKNE+
zcCOLhdMK5C+GzThv2s0upxtJa8CkmZvEzt7WkvyMet6bnrbGbY=
=Rb/V
-----END PGP SIGNATURE-----

--=-qMmM3LVuejBi/UYuzebx--

