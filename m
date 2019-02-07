Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1B67C282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:25:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75CBE21908
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:25:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75CBE21908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA3678E0046; Thu,  7 Feb 2019 11:25:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E55A28E0002; Thu,  7 Feb 2019 11:25:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D42D38E0046; Thu,  7 Feb 2019 11:25:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE408E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:25:42 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u32so406713qte.1
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:25:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=UlDRjokCZxjPPaAcH8LUtW623yZ43lSgy/QjVuWBctM=;
        b=YQMxZyI13a6of/bmLpk+n3p4lE2q0hGd+pC+9TO4dQh7rakhUmLA9Wb+eha7cysDIf
         0LW6luF3bQAMOWLtNJY8ofRXkqr6c4UYaXgQZI4mQAr2GuDa+teLGLzzCv9A3JuHf/sI
         VcyMtUxAtMJrZp+TH1a55kglVE+KsBEdXZ4qaI6M2leS1F2z4+PT38WPRoZ8jrl78nkL
         UK3INlyzd+PaANmElggjqYpC8iGQKmS1kDIihMXmz0uqmXQsdLQh1NlqltIopZYvZhQa
         cByUs900A1SuSWWZFwmea4B6XfFucx6P1YHqSB3pnTTokPjhKFVy9Wld3JBDcpY5Jg4I
         gnxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYt4AIl8ZQE0ealGQPWCE20oNr0PCtG1rUddn2cPYwY/j8zLw0S
	YkEQO41zvKxMUEJyjnrhaZ+iGWqejl4C9gfhS9YUaHA2gQje67AwM/2++V1W9HzjycyM5raUQJ2
	Rg5fc0Oko9q4nG7ezNlC+ztNHXgv0Hz00N7NV4fLnLHroVRSw+FUI7Tp6xojopPrlMQ==
X-Received: by 2002:ac8:7311:: with SMTP id x17mr10936505qto.109.1549556742190;
        Thu, 07 Feb 2019 08:25:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib6NNMhP3KGizstZDxRZ+c9wMQ/rvl3b/xH2OPi+DOK0dA2BkYmtp54MjHd2eJSjg//ULZx
X-Received: by 2002:ac8:7311:: with SMTP id x17mr10936448qto.109.1549556741306;
        Thu, 07 Feb 2019 08:25:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549556741; cv=none;
        d=google.com; s=arc-20160816;
        b=gh99XN/9DG/gTDr9ikPARm8Aec32J/FpFLKAfpVI83txrP1Ny2IjJR8shZS7LRDfGE
         DcvKJAFLIhLNYTdEVAh21XczK/ThnwG6Oq+vWBFE+Xc4SmsgzfpzINAcG86e4BIGRywk
         aUr5PE/nl2ecbA/gHzl2AsrPhO/VHLxb0WdxkAI2RUvbMNAmpIMl6PCspu/4MwGCIWUA
         ZXncLSybeihJQq/WcDaNXzrRINwSWfpY/uIa6Bwe1U05AP9TnaASvg2VPs/qh6UkbYw7
         yn6eLyNqtxHzpQ1HULiKh0ELQWladbTa0Z+nMxmA+iXTfX/+ja3s2TLN/b9IWXauV7So
         6zEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=UlDRjokCZxjPPaAcH8LUtW623yZ43lSgy/QjVuWBctM=;
        b=RYSn359mCmUELcpjAPngD0O/v3F1XIHbrxKIbLtbA5at1oNVYapDBoO69yudTRL6hI
         LIV5bETs2c+dAJh6QdoGlXLru0VSwEyLTTb4NQxWkeF2Z1eZJ/WGi+GmFRFSXYmDTxK3
         9TLAU28OZ4S+h5cTQZrbWzClArihPF1CuF5oixy5oljWyhCMI2e9Sgp9AFe7cdH8piip
         DqjRaRFFhRXg5YuaW95avwH/IdG/bPwDXRgKupRYzwOq6B8Osnrh4CW1zRJDOzYfp0te
         YhjuqKsw1B1do+hT6s81fPU75uZIYbSPwhWbIRoRRrIsk5WlLtM0mnIgEs84ZyRXrWfs
         IZxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 3si9871533qtb.246.2019.02.07.08.25.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 08:25:41 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1B2AC432AB;
	Thu,  7 Feb 2019 16:25:40 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 93E205C22D;
	Thu,  7 Feb 2019 16:25:37 +0000 (UTC)
Message-ID: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
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
Date: Thu, 07 Feb 2019 11:25:35 -0500
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
	protocol="application/pgp-signature"; boundary="=-um3ENeAUEAAEn9LYnNJ1"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 07 Feb 2019 16:25:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-um3ENeAUEAAEn9LYnNJ1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I think I've finally wrapped my head around all of this.  Let's see if I
have this right:

* People are using filesystem DAX to expose byte addressable persistent
memory because putting a filesystem on the memory makes an easy way to
organize the data in the memory and share it between various processes.=20
It's worth noting that this is not the only way to share this memory,
and arguably not even the best way, but it's what people are doing.=20
However, to get byte level addressability on the remote side, we must
create files on the server side, mmap those files, then give a handle to
the memory region to the client side that the client then addresses on a
byte by byte basis.  This is because all of the normal kernel based
device sharing mechanisms are block based and don't provide byte level
addressability.

* People are asking for thin allocations, reflinks, deduplication,
whatever else because persistent memory is still small in terms of size
compared to the amount of data people want to put on it, so these
techniques stretch its usefulness.

* Because there is no kernel level mechanism for sharing byte
addressable memory, this only works with specific applications that have
been written to create files on byte addressable memory, mmap them, then
share them out via RDMA.  I bring this up because in the video linked in
this email, Oracle is gushing about how great this feature is.  But it's
important to understand that this only works because the Oracle
processes themselves are the filesystem sharing entity.  That means at
other points in this conversation where we've talked about the need for
forward progress, and non-ODP hardware, and the talk has come down to
sending SIGKILL to a process in order to free memory reservations, I
feel confident in saying that Oracle would *never* agree to this.  If
you kill an Oracle process to make forward progress, you are probably
also killing the very process that needed you to make progress in the
first place.  I'm pretty confident that Oracle will have no problem
what-so-ever saying that ODP capable hardware is a hard requirement for
using their software with DAX.

* So if Oracle is likely to demand ODP hardware, period, are there other
scenarios that might be more accepting of a more limited FS on top of
DAX that doesn't support reflinks and deduplication?  I can think of a
possible yes to that answer rather easily.  Message brokerage servers
(amqp, qpid) have strict requirements about receiving a message and then
making sure that it makes it once, and only once, to all subscribed
receivers.  A natural way of organizing this sort of thing is to create
a persistent ring buffer for incoming messages, one per each connecting
client that is sending messages.  Then a log file for each client you
are sending messages back out to.  Putting these files on persistent
memory and then mapping the ring buffer to the clients, and writing your
own transmission journals to the persistent memory, would allow the
program to be very robust in the face of a program or system crash.=20
This sort of usage would not require any thin allocations, reflinks, or
other such features, and yet would still find the filesystem
organization useful.  Therefore I think the answer is yes, there are at
least some use cases that would find a less featureful filesystem that
works with persistent memory and RDMA but without ODP to be of value.

* Really though, as I said in my email to Tom Talpey, this entire
situation is simply screaming that we are doing DAX networking wrong.=20
We shouldn't be writing the networking code once in every single
application that wants to do this.  If we had a memory segment that we
shared from server to client(s), and in that memory segment we
implemented a clustered filesystem, then applications would simply mmap
local files and be done with it.  If the file needed to move, the kernel
would update the mmap in the application, done.  If you ask me, it is
the attempt to do this the wrong way that is resulting in all this
heartache.  That said, for today, my recommendation would be to require
ODP hardware for XFS filesystem with the DAX option, but allow ext2
filesystems to mount DAX filesystems on non-ODP hardware, and go in and
modify the ext2 filesystem so that on DAX mounts, it disables hole punch
and ftrunctate any time they would result in the forced removal of an
established mmap.


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
>=20
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
>=20
> > Do they need to stick with xfs?
>=20
> Can you clarify the motivation for that question? This problem exists
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



--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-um3ENeAUEAAEn9LYnNJ1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxcW/8ACgkQuCajMw5X
L91/3RAAn/t0azp+g0ydwFXoYi7Glyb8+kYEztIcXGo2gFnCTyTT32j4YlcZYeQY
+sb7jSH2fkBbAj69y5pXzuGGg52NvcaGMi8ZzDkxaHxNYIwGXVcT89uNJ5Jri+jD
RbCD4MnreNx8+YTPy/K9NZGwrG2jemXaN+8Ln0g3UOSV+pBbMTOD6xYXOgPwxmPG
0sgd2a+Lj5hou8kRIjGk7sbAWCV0kg5Ss4M3gKGt80ny+9CagJHyD49ffhxzU679
of9gegyRRVBJrFD4zh+qZNEUhhITv3+11kIYU0CwFiwAXT3eMQwhEHL70YwWALuJ
dOSy1Hy9hDpUqcrkBV2pB9KyaYpDKd84Yt0aS++wNI85i4oZNgjxwtGMmyFb8Fbf
4S9HePUn5oJarlwzJJYm8pjMWO0daESEqKqIaP9IN1VDp/Mjvw51e1TOmoygshyU
6zxeaCIfeaJ76EZj1pajXKiA2wE/ONQhIuEsemPthbMxz9py920tOQHlGg39kbys
rcqym6ZACGXA7Z4myCnpCxTNm5aaEk7isXe4i56GkohCFRostUsqeDBLdr2aqQ0f
m2TbCHxEuHh6HmhklrHg81w7MJeKl7dOSK71gLwFJoyWZJ3NgSS5OEwwA3kL2TG5
pBCerjLCZbPYrjgFMod6p+1C8IGNSUMvLycrNscgTn5nfiwjur0=
=H0zA
-----END PGP SIGNATURE-----

--=-um3ENeAUEAAEn9LYnNJ1--

