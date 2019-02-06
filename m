Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4824C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:16:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 747AC20823
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:16:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 747AC20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EFFC8E00F7; Wed,  6 Feb 2019 15:16:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A24B8E00F3; Wed,  6 Feb 2019 15:16:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFA798E00F7; Wed,  6 Feb 2019 15:16:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C38D98E00F3
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:16:10 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n39so7880029qtn.18
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:16:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=hLkOpA+BTt8I9+MQ5clK7NA9/A7ghD9xV6awSsgOXDU=;
        b=WVGyWNPBYCis+WMk/Pnj0PWQfV+7AK3ruUNZ98Gqtn/DT5HN678qiQMex2GIGsmCgI
         biej1NobMYpEPGlU6o0vXDzKfihn7Z/oD2H3oTEUAHorjOPgXihLWoj8dE9yIYkplkCV
         kQFBZd4q+XKp/elBy4nEd4jvP45ty+QwOYVTRceOMwBirZEfWKiVbENVPEoYHbYWIHLK
         3/GcQx0hXAS4J4s86IE5/aDw+oAJN7aRMa7X24nIO5E9EZ/+u0Igmty9IBAoixcan8kY
         7Itwnvn62CTEUuGw+55ySSqlR5+I4n5ewlxmU2vjoZEDMuP9Awu/b6NxfeVdbV+dAbTl
         yxug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubcuwm3BkyPwPokUZfa31aICkzIEAT0Ix6Zs9G2oe+K0w+a7Kgl
	jsU/B2pZWIguyaFZBLAL0zwLz7Qfh5DQ7zWhGl9aoUXurrnSzZQEsB/Eeyv/BfyM88QPqIGZOJe
	F1xFU0uAmx0LFsGuyRYoP6XT7/n5K0AIbK7XyaEtOtylFQ/ThvhjTiI0LtZyvV9Zz6w==
X-Received: by 2002:a37:884:: with SMTP id 126mr9103631qki.56.1549484170565;
        Wed, 06 Feb 2019 12:16:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ9q7fsBgrnjKb85DkGVUXD+f8WaBsvYJnX23zEsz0B696K7TrmrVvAqzgLZB9hoapCrI9E
X-Received: by 2002:a37:884:: with SMTP id 126mr9103610qki.56.1549484170230;
        Wed, 06 Feb 2019 12:16:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549484170; cv=none;
        d=google.com; s=arc-20160816;
        b=sjqJRJxUyYL4RRDNMe9N6f2nXcAy9iTiJOh6tdja+MGmq1G7c0jTSWNCuc+0T1WHmi
         uw3RJAHh6Pe0o3W/3Y28bjEofDK/DejajlHVoMEKEZjHxMHY4aFU04CmPO2AfNFW8GLM
         obWfc5e+r+fewMunyJXcIgRJb21mRZtJSFz8lkdmb7JIfBIbby7aV8CGy4GZLXJTgULm
         D8g9fs0unjhQKxe3U6qSqxgoicnd4r8iX2FIBOe7rRoS+8Tx0ArTr30UKdQPm/Hy4Dde
         Ik/I/4aUblGCVrjVHbK8tkX39CtTaJm/WsneMvQYCK+SyMpC7hCJ5nWp/brTsFv8SjsU
         BdXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=hLkOpA+BTt8I9+MQ5clK7NA9/A7ghD9xV6awSsgOXDU=;
        b=kgnXirsKn6FssEHu12lQ4pTxRRNfQBcgQ22yPLsjT5AGUcm+mL+XecTUxAkr/2KYQD
         tpLMLdwzPZkKd5GSKZpDjlY11JvDuCKBJVAsSnZ8UbmJD1+5nI7EA8L2iIkz/tjnOQyw
         9/5nbF/fZdMc0ikNu8Zzvsk1cLZb5lsPGsHl1gi0Kc0Pkac01yXTbeNBGPglPpS0bQZ8
         gCwwml58vzThl45Ftlxk4cTxYWfNavFtudesfJvM7oY2rIEjbeSyrPhwj2DX8Z6bz2li
         IERabfefd69vTRLu2EIuCNefQBJ0AsLMZ2nauqZYK+b57mYzucjIbv7feFmNAQiDjjpa
         Km1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s1si822085qvc.125.2019.02.06.12.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 12:16:10 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D6A933DBFE;
	Wed,  6 Feb 2019 20:16:08 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6D26D6247B;
	Wed,  6 Feb 2019 20:16:05 +0000 (UTC)
Message-ID: <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, Ira Weiny
 <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
 linux-rdma@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  John Hubbard <jhubbard@nvidia.com>, Jerome
 Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave
 Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>
Date: Wed, 06 Feb 2019 15:16:02 -0500
In-Reply-To: <20190206194055.GP21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
	 <20190206194055.GP21860@bombadil.infradead.org>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-1dGH+hKU+Z7r3DIuLEHD"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 06 Feb 2019 20:16:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-1dGH+hKU+Z7r3DIuLEHD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 11:40 -0800, Matthew Wilcox wrote:
> On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> >=20
> > though? If we only allow this use case then we may not have to worry ab=
out
> > long term GUP because DAX mapped files will stay in the physical locati=
on
> > regardless.
>=20
> ... except for truncate.  And now that I think about it, there was a
> desire to support hot-unplug which also needed revoke.

We already support hot unplug of RDMA devices.  But it is extreme.  How
does hot unplug deal with a program running from the device (something
that would have returned ETXTBSY)?

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-1dGH+hKU+Z7r3DIuLEHD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbQIIACgkQuCajMw5X
L90bChAAgL7lcxfXKSmYLGA1OFdVg5chnIDS93XRvqgpb+yb4Tpb+DhVqhoT3bHY
gUpE9yFtWmLsUVrtn0xquWw8VG5Ciqm3T+EA1l2yfD0deu7WchyEG6Ezg90IefFl
BSl6rXHScee62dUztlmRPuj9Tu9x8zQlWzeYQ+HXWbXKbY1L47bYLaFgaHdYnDUX
NdI+Dw84LQTpBxPjiQV+mBWPFaGSX1dxC6RKKxPHNMFLpEq9qt1Z2Z3NkceEc39v
jCUmCkvDdYhLgk2Mb7rHIl8IrTrt3q2ASte9Qane1B/AQoKDvf+icpqggzrljbA4
gFnNLeIphEsj4RdxS8Jj4oAf80I57Od236KprxjfHNxWv6tpmuMpVuO8+2Wve9YF
rskQFW76KIViYuvQpb8FHhmVQDZ+4fAsAoKlucf0lMbUaIyIbsR13qlyrsHViOfv
fx7RPeVPNC+uct0qWeHkAJuivBZym/dqTHVuNVXkNOFAoiOXRpfIXA26XJlnT1aX
CpRspY8yFawWEZonppyKyjbt3fMs3rZIFmxSh6vTEV8oXSlFYsIRG2Cu9bInZC1N
B7ZuDVLvjCyizywq0VobCgEf3mlpG056WLSu9vXqO1BPT6ASI/GcI+JEG+NcitIX
nz9Q1Dewt67LDUWm61KTkkiMEON8ljYxRgSkREIm6ksW3G35M48=
=WK6h
-----END PGP SIGNATURE-----

--=-1dGH+hKU+Z7r3DIuLEHD--

