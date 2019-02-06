Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF5E2C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:44:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8979720663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:44:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8979720663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C2578E00EB; Wed,  6 Feb 2019 13:44:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24C798E00E8; Wed,  6 Feb 2019 13:44:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1394E8E00EB; Wed,  6 Feb 2019 13:44:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAA2F8E00E8
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:44:23 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k1so5527506qta.2
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:44:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=laiof55HCDMenvPuXo0LpjVlHiqgonuDwq7OTfSpkEE=;
        b=LdbMr5dZ+FM8PlW1k2UuAPAFdQNL0fOnTFe/OsoGwYlOygCDpRdEujn4gFqzfrjin7
         PJxSGosXEisoYSrNQqdR+7j4H+jVjoMlHRQZ2PBy3OYJmEntKOXrhVHb6xmGtt4xgilD
         ydgjNz9Js/2Q744XWNW2Dc/1aBdLWp1oNTxkcqFRPYYXc4hm/999JlR8VHBBaoCqXR5J
         qNMkm0ksEC28mMPQknrlu7tZ23t5+s/rzO/FcrMV0tvnIc49aIpNSrLUQxWynyRLhBg4
         HmLdG4TCHNVbKmFG0VzEeWdXjAdSu/GGYweYUEvk9aGi7iD75ctCHeuXNyQ8dq0Pq2L3
         cejw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYgOD6VNuLh/yD4HetU+4EXSAdfJGHUgx7kGYi5/FZKMsK3rECZ
	onAjGbj4S/K7S7VYmuWICZNv2xHQuUGYR7oDzbdobZg06sifxR6diPG+i4cgf71+fpibPto6wzA
	zbxtfJEVzenZ0sTalRO5c5f4s0j4kSwrnjILD52jhT3J8g4DL8Tqh4NR0vgfPiDHzDQ==
X-Received: by 2002:aed:21d2:: with SMTP id m18mr8941864qtc.121.1549478663606;
        Wed, 06 Feb 2019 10:44:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZRSAPG//QdbD/8x9Lbe15iS/pXwpOeay59LNx+apSwF7cmTTL8gLpKZ+ARBSB8g0MXQLgL
X-Received: by 2002:aed:21d2:: with SMTP id m18mr8941841qtc.121.1549478663218;
        Wed, 06 Feb 2019 10:44:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549478663; cv=none;
        d=google.com; s=arc-20160816;
        b=tyRJQEhft92yloy0r49egsir/DaAlhdAiTepiIdkhJ8j64OIkSyqcS5wC1JUGX45M2
         AqyB7xFBovIPscZlpeTCv7b071CVdJnNvIS8QvHGhd4wFKPe/pmJ84HYttkUJeghmDyx
         bJDrJ1JoQYKPU/m7Rf0Xzp6mUpfbKdcg6PCUtvV8yqvaNSlEIueXOI+KoZNAdlNzgWT2
         eOwJ26ReM7CWCfg3U7q5gFm0eJhzb5HL3i5ppDHVwEZzLDrSq+twunaorLYeEEbgwIg1
         Grq9R+9jfqxSjvalvokgqfnQXrSz8zpfNxIiJJBdwAg/VX8AdBlbnf163KuBrGu61Oiq
         c6PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=laiof55HCDMenvPuXo0LpjVlHiqgonuDwq7OTfSpkEE=;
        b=fhIlQ4RyXBFudEJieiGPjErWiJrg0YL3a8zW8Ir4mUGi3cI2+qjDBHXInGGFM/EOZn
         TjCGHy4oERmzBJFX8i5Gk9AmMF4t8DPagMST+eqlr16utmSYKMpMIqkW3VI1jKasT8ia
         uWyA8CWv/hOLiKS+oHRTySlG9434bdwMdH0UdLgmugtdragDLwZlAYYPgC9AigsYgWKJ
         brto7kK0N4F0jtKzF6vAhQzDvCfaRmDLXtc3MPWgmLTFzA0eDppFy+CpaX/hxb7XbpAD
         ZxK9rddWKJPx9ujP5VrDOKRMNF3WoFW8b4ZvjLulG29UMkSICSvSpicReazkCQa0l+JD
         VMCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e32si898919qvd.6.2019.02.06.10.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 10:44:23 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 38F08E6A65;
	Wed,  6 Feb 2019 18:44:22 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0DF4917CFF;
	Wed,  6 Feb 2019 18:44:19 +0000 (UTC)
Message-ID: <411ec0e65f4aa430f5af71afc0a726226e962f61.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, Ira Weiny
 <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
 linux-rdma@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  John Hubbard <jhubbard@nvidia.com>, Jerome
 Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave
 Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>
Date: Wed, 06 Feb 2019 13:44:17 -0500
In-Reply-To: <20190206183503.GO21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <20190206183503.GO21860@bombadil.infradead.org>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-STkidJ/sDmjPcGJyIwmW"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 06 Feb 2019 18:44:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-STkidJ/sDmjPcGJyIwmW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 10:35 -0800, Matthew Wilcox wrote:
> On Wed, Feb 06, 2019 at 01:32:04PM -0500, Doug Ledford wrote:
> > On Wed, 2019-02-06 at 09:52 -0800, Matthew Wilcox wrote:
> > > On Wed, Feb 06, 2019 at 10:31:14AM -0700, Jason Gunthorpe wrote:
> > > > On Wed, Feb 06, 2019 at 10:50:00AM +0100, Jan Kara wrote:
> > > >=20
> > > > > MM/FS asks for lease to be revoked. The revoke handler agrees wit=
h the
> > > > > other side on cancelling RDMA or whatever and drops the page pins=
.=20
> > > >=20
> > > > This takes a trip through userspace since the communication protoco=
l
> > > > is entirely managed in userspace.
> > > >=20
> > > > Most existing communication protocols don't have a 'cancel operatio=
n'.
> > > >=20
> > > > > Now I understand there can be HW / communication failures etc. in
> > > > > which case the driver could either block waiting or make sure fut=
ure
> > > > > IO will fail and drop the pins.=20
> > > >=20
> > > > We can always rip things away from the userspace.. However..
> > > >=20
> > > > > But under normal conditions there should be a way to revoke the
> > > > > access. And if the HW/driver cannot support this, then don't let =
it
> > > > > anywhere near DAX filesystem.
> > > >=20
> > > > I think the general observation is that people who want to do DAX &
> > > > RDMA want it to actually work, without data corruption, random proc=
ess
> > > > kills or random communication failures.
> > > >=20
> > > > Really, few users would actually want to run in a system where revo=
ke
> > > > can be triggered.
> > > >=20
> > > > So.. how can the FS/MM side provide a guarantee to the user that
> > > > revoke won't happen under a certain system design?
> > >=20
> > > Most of the cases we want revoke for are things like truncate().
> > > Shouldn't happen with a sane system, but we're trying to avoid users
> > > doing awful things like being able to DMA to pages that are now part =
of
> > > a different file.
> >=20
> > Why is the solution revoke then?  Is there something besides truncate
> > that we have to worry about?  I ask because EBUSY is not currently
> > listed as a return value of truncate, so extending the API to include
> > EBUSY to mean "this file has pinned pages that can not be freed" is not
> > (or should not be) totally out of the question.
> >=20
> > Admittedly, I'm coming in late to this conversation, but did I miss the
> > portion where that alternative was ruled out?
>=20
> That's my preferred option too, but the preponderance of opinion leans
> towards "We can't give people a way to make files un-truncatable".

Has anyone looked at the laundry list of possible failures truncate
already has?  Among others, ETXTBSY is already in the list, and it
allows someone to make a file un-truncatable by running it.  There's
EPERM for multiple failures.  In order for someone to make a file
untruncatable using this, they would have to have perms to the file
already anyway as well as perms to get the direct I/O pin.  I see no
reason why, if they have the perms to do it, that you don't allow them
to.  If you don't want someone else to make a file untruncatable that
you want to truncate, then don't share file perms with them.  What's the
difficulty here?  Really, creating this complex revoke thing to tear
down I/O when people really *don't* want that I/O getting torn down
seems like forcing a bad API on I/O to satisfy not doing what is an
entirely natural extension to an existing API.  You *shouldn't* have the
right to truncate a file that is busy, and ETXTBSY is a perfect example
of that, and an example of the API done right.  This other....

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-STkidJ/sDmjPcGJyIwmW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbKwEACgkQuCajMw5X
L93yBRAAhRGEMpj2vV32qd66hnUXo3c/jfmEjxn5HXrp5Gqq1PT+ppU7gsJc9GjC
X1m2Dd9q6QfoV8rNlDiG9xHkXxu+AUmxOg24dCqJyOVji0kb0rhIgjgGobR9s7em
/9lSxKrbSJmSVFFjhX7UnTc97MgVugE94wSuOGCcVsBljT5ZGM4Gvkwk3uXxSwDx
juDfnuEKgcjs45ZA0DvZ/10u422pDHrHHCxjC9dVGA0BmaMK44hx2e7/XWWdiUV4
bn1vJM1t0Y3gavQwAXXV7uwS/55DZ9gFtOtTOb+qBnx59BzdZ0ntp3UxsZ3lPKG+
IjOW1gHlgI0m1NdDzFJwZC7o1ZGnTBMrhMRhMOUSjHS+qX4HZnvXcWEZJ9bGtbvT
SWJE3zZ2P+0ssvLHD9iQKEBoZQaDnLzZmXlFWraHTAGgPTmxF9WId3rK6YPSWieC
Vf7oyQNl7N3mxsmTlzB/Zz1f4OE7W4F3di6NntJaePOQ26L7yY7kMNDtGzKjF+GV
F1DWnT7NDunXRHTnNgc6/dEOfcFrPQ79UZK2AHxy3wHRhljQvBxaJ5AHJWjAOz+8
TcOljAVacnW5oZb3i83NdLa6eg9ZBT4p/3PuehjjfaewOtMPzcFkW2jofSqqhZgY
pUthVtuy3HEjYRrwKdZyz5G+LNUiu7iF84Q8KomsuDC1Sd6NTYw=
=rH71
-----END PGP SIGNATURE-----

--=-STkidJ/sDmjPcGJyIwmW--

