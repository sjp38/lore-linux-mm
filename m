Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AB24C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:28:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E70262083B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:28:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E70262083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 838C58E00FA; Wed,  6 Feb 2019 15:28:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C1F88E00F3; Wed,  6 Feb 2019 15:28:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68AEA8E00FA; Wed,  6 Feb 2019 15:28:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2B78E00F3
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:28:44 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q11so8124259qtp.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:28:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=S7FfnmelgQa0khofuBiT78fwjlmiCCBuns8G8lb3uJ0=;
        b=kvPvGfbuG+7U7iaFSwlsIXMTUwuidA7GeM1w2/e/fXPDbKN1d63cJ6lXl+fFQAYnQ8
         5ScUc0pjCREGWeHUiTIdXdxtEzlgLud18+i9R81tsrhui3q3zFOqY8rdbi9+btVdT4Cq
         TB7VyBvNjc6rRuKR2LbHdLX/wpgkjWtNGPQbzek8hrWOuvyZu/V1F/CU0imkB6YGtgNk
         uZvykFKw5GIti+Bu1RQIktG5Y38iFq8S6qR4E7PO6hOJeEDTzaw/fFmiNRScZWN4/Cub
         S2HF3/c6S+cJp8EiOQd2oWvOVs9DCG7lapxalQGN4htDmq5/52HffzT7v5uxESfQLnBM
         QYHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua9NG1YLRR0HOpk6eI3BGm8JsOM6Ep4gSNuSLB4VjBj70pGPMVy
	nlrApS89E+46WL7JEh4NDMKEqN8j/KqGym0wTIswAlV7lv7mEYK1vqSE7AX4SGfMYfijq7NWvbC
	9pW/d2Dk4w2X3b7lILYvRXy3/3l6W269Gax/oqExGTIz9rsgC3M5p1tLFwyBB9CIFjA==
X-Received: by 2002:ac8:3855:: with SMTP id r21mr2560673qtb.91.1549484924007;
        Wed, 06 Feb 2019 12:28:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbTgm/YVynV+wd+I6EMiOHRHkAci6ZbPfzkvgR/L3Wy9QyqD+TtpQwiR6TSqaZcPCNUyP+G
X-Received: by 2002:ac8:3855:: with SMTP id r21mr2560654qtb.91.1549484923678;
        Wed, 06 Feb 2019 12:28:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549484923; cv=none;
        d=google.com; s=arc-20160816;
        b=eZUtZSfQ6yt9Sep+sxH13q7dXOM6+pkhNkAzin7PrXcUE5T1QZbAZ0st33WD+WzTwp
         5ErIDxJ9LiCVKKs+pRs4FrRDhuA+MrzQS3RXq1hX720hQuKUpxD7EaiFGbZAmfeTuhvM
         wqy3IyK+US/LTI5/mOToYrUdH8VjeFxFegoUOPy1RbwlPiK6CE0JQVWwkyV7LXou5bVX
         WAwiqdU852K+qLNU/SgyCefJRX87mhmmQFu+yPkZZeMi6qtZ8uNbLiK9Y5qBrmwAwatm
         PP/7ObuVOV9LCVaaFc/osrZsrlynGmWUvV9/MLwnclSLXA9bEpzQqRbCLwtbT4gylM2D
         1TuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=S7FfnmelgQa0khofuBiT78fwjlmiCCBuns8G8lb3uJ0=;
        b=vKT0ncVyEo102RHxhHcUxoI3g+8MYCVXqHzprdLwf5qSVDP3eEWctxEAOaM2RkMI89
         lXAIa91qDzB0gAPLzVBuuZIRj1nyEOkUyAP0B+RzTqD4SREOdXU9We8V7jBotvS4MRn8
         Df8IDgtTiKRTu6PPM8bSa2CgHC/GhMR7ctXg4aRJDb81oYjclpDRZWOlT9sRx9dy6R9E
         WEmxDmEBXWWtUg0McXbkQdu976tssr6ic5GjOrgKAruHb7r643AzJBM8t1CO7LgY0hws
         xco8uUfCbduyun41C+c85C2B9CUOXgT0VcUZrJPXc/de2LvE1wkSYTAvH5hNs8w8mqEo
         TioQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si327927qtj.134.2019.02.06.12.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 12:28:43 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B57C95947F;
	Wed,  6 Feb 2019 20:28:42 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 58EA0660BA;
	Wed,  6 Feb 2019 20:28:40 +0000 (UTC)
Message-ID: <a8dc27e81182060b3480127332c77ac624abcb22.camel@redhat.com>
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
Date: Wed, 06 Feb 2019 15:28:35 -0500
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
	protocol="application/pgp-signature"; boundary="=-T+TkLa3nZqw/GpqDXqzy"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 06 Feb 2019 20:28:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-T+TkLa3nZqw/GpqDXqzy
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
>=20
> It's straightforward to migrate text pages from one DIMM to another;
> you remove the PTEs from the CPU's page tables, copy the data over and
> pagefaults put the new PTEs in place.  We don't have a way to do similar
> things to an RDMA device, do we?

We don't have a means of migration except in the narrowly scoped sense
of queue pair migration as defined by the IBTA and implemented on some
dual port IB cards.  This narrowly scoped migration even still involves
notification of the app.

Since there's no guarantee that any other port can connect to the same
machine as any port that's going away, it would always be a
disconnect/reconnect sequence in the app to support this, not an under
the covers migration.

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-T+TkLa3nZqw/GpqDXqzy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbQ3MACgkQuCajMw5X
L91JAw/9F0R0dhIpoufg7KCt9PVbxs+Zf+ATyyHACVuBgEp7bmf0eIeWtvf/ZVKh
t7dUajXxI6xmrdnRtqvZxkU/z4ics4jUlTnXDt1NmcsO1AtnaE0iRzShBaldkKf9
LPjnfZbkdzY+RZwdIU/C9ZOvOSg2fKrCsc2xeNuEloRi6doo4MHZvakmmI3xW27k
lAl3L34KpR9Lz3Isu2MeUN+KHemKbSXYRxwKy7JlhexXLCN7jnclGC9kfL1dTJRc
WuA2FCOaj4obvMglF/LRHPCWT0k5kAOcuPLhR7r/3sR9tDcMiPJZZtqFe/SLzG8Y
Xdiy1I11Mj1+wnp5n5rZLpfVgBo29F4uo5J2zJUdGpgH113IiJMCxn3Jz986Aix5
7Ad3rzNOthv2uHEusH0XtUBd2mROVSYhk/jNNJUzZBn4N5C/1Jm/H/7dP8aGI0SS
5ZKs3o23JqOQXv5q0j0woHPIusX0RfIBftLDr9ofnHBvDvbME5PQSuhdgDu7vv5c
gMQBUHVM8vAc0fnD9j/EH8hrnAcrXrxAaIrVuR6X4dHE6hVRj1c2fFkNlu34I0+c
9bTiVIwwMc0jwHoEtwF0MgW4Wci3qBmVVOjfeSyml8FIZaPt4XNFTRSj95TGi/9v
f9gGewTehWp/nHJq5svV8R+6SF9/H/gTVEYwNIK9Li6pFoNShoU=
=Q1pC
-----END PGP SIGNATURE-----

--=-T+TkLa3nZqw/GpqDXqzy--

