Date: Wed, 7 Nov 2007 11:00:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 04/23] dentries: Extract common code to remove dentry
 from lru
In-Reply-To: <20071107185452.GD8918@lazybastard.org>
Message-ID: <Pine.LNX.4.64.0711071100350.12363@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011227.298491275@sgi.com>
 <20071107085027.GA6243@cataract> <20071107094348.GB7374@lazybastard.org>
 <Pine.LNX.4.64.0711071054240.11906@schroedinger.engr.sgi.com>
 <20071107185452.GD8918@lazybastard.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-535107522-1194462056=:12363"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Cc: Johannes Weiner <hannes-kernel@saeurebad.de>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

---1700579579-535107522-1194462056=:12363
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 7 Nov 2007, J=F6rn Engel wrote:

> > Acked-by: Joern Engel <joern@logfs.org>
> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> >=20
> > Index: linux-2.6/fs/dcache.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6.orig/fs/dcache.c=092007-11-07 10:26:20.000000000 -0800
> > +++ linux-2.6/fs/dcache.c=092007-11-07 10:26:27.000000000 -0800
> > @@ -610,7 +610,7 @@ static void shrink_dcache_for_umount_sub
> >  =09=09=09spin_lock(&dcache_lock);
> >  =09=09=09list_for_each_entry(loop, &dentry->d_subdirs,
> >  =09=09=09=09=09    d_u.d_child) {
> > -=09=09=09=09dentry_lru_remove(dentry);
> > +=09=09=09=09dentry_lru_remove(loop);
> >  =09=09=09=09__d_drop(loop);
> >  =09=09=09=09cond_resched_lock(&dcache_lock);
> >  =09=09=09}
>=20
> Erm - wouldn't this break git-bisect?

Well Andrew will merge it into the earlier patch.

---1700579579-535107522-1194462056=:12363--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
