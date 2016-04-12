Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id CC3AD6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 17:14:42 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id f52so27464880qga.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 14:14:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b32si17484979qgb.109.2016.04.12.14.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 14:14:42 -0700 (PDT)
Date: Tue, 12 Apr 2016 23:14:35 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Ideas for SLUB allocator
Message-ID: <20160412231435.3cbf3aeb@redhat.com>
In-Reply-To: <1460484828.7134.4.camel@redhat.com>
References: <20160412120215.000283c7@redhat.com>
	<alpine.DEB.2.20.1604121057490.14315@east.gentwo.org>
	<1460484828.7134.4.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: brouer@redhat.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, js1304@gmail.com, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, lsf-pc@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 12 Apr 2016 14:13:48 -0400
Rik van Riel <riel@redhat.com> wrote:

> On Tue, 2016-04-12 at 11:01 -0500, Christoph Lameter wrote:
> > On Tue, 12 Apr 2016, Jesper Dangaard Brouer wrote:
> >  =20
> > > I have some ideas for improving SLUB allocator further, after my
> > > work
> > > on implementing the slab bulk APIs.=C2=A0=C2=A0Maybe you can give me =
a small
> > > slot, I only have 7 guidance slides.=C2=A0=C2=A0Or else I hope we/I c=
an talk
> > > about these ideas in a hallway track with Christoph and others
> > > involved
> > > in slab development... =20
> >=20
> > I will be there.
> >  =20
> > > I've already published the preliminary slides here:
> > > =C2=A0http://people.netfilter.org/hawk/presentations/MM-summit2016/sl=
ab_
> > > mm_summit2016.odp =20
> >=20
> > Re Autotuning: SLUB obj per page:
> > 	SLUB can combine pages of different orders in a slab cache so
> > this would
> > 	be possible.
> >=20
> > per CPU freelist per page:
> > 	Could we drop the per cpu partial lists if this works?
> >=20
> > Clearing memory:
> > 	Could exploit the fact that the page is zero on alloc and also
> > zap
> > 	when no object in the page is in use? =20
>=20
> Between the SLUB things both of you want to
> discuss, do you think one 30 minute slot will
> be enough to start with, or should we schedule
> a whole hour?
>=20
> We have some free slots left on the second day,
> where discussions can overflow if necessary.

30 min slot is fine by me :-)

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
