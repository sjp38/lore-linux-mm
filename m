Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 736C29000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 10:04:40 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <1a2c1697-9ed6-4cb8-8da9-d252045b8a75@default>
Date: Wed, 28 Sep 2011 07:03:52 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V10 5/6] mm: cleancache: update to match akpm frontswap
 feedback
References: <20110915213446.GA26406@ca-server1.us.oracle.com
 20110928150841.fbe661fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110928150841.fbe661fe.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Subject: Re: [PATCH V10 5/6] mm: cleancache: update to match akpm frontsw=
ap feedback
>=20
> On Thu, 15 Sep 2011 14:34:46 -0700
> Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
>=20
> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Subject: [PATCH V10 5/6] mm: cleancache: update to match akpm frontswap=
 feedback
> =09err =3D sysfs_create_group(mm_kobj, &cleancache_attr_group);
> > -#endif /* CONFIG_SYSFS */
> > +#ifdef CONFIG_DEBUG_FS
> > +=09struct dentry *root =3D debugfs_create_dir("cleancache", NULL);
> > +=09if (root =3D=3D NULL)
> > +=09=09return -ENXIO;
> > +=09debugfs_create_u64("succ_gets", S_IRUGO, root, &cleancache_succ_get=
s);
> > +=09debugfs_create_u64("failed_gets", S_IRUGO,
> > +=09=09=09=09root, &cleancache_failed_gets);
> > +=09debugfs_create_u64("puts", S_IRUGO, root, &cleancache_puts);
> > +=09debugfs_create_u64("invalidates", S_IRUGO,
> > +=09=09=09=09root, &cleancache_invalidates);
> > +#endif

Hi Kame --

Thanks for the review!

> No exisiting userlands are affected by this change of flush->invalidates =
?

Not that I'm aware of.  As required by Andrew Morton, the frontswap
patchset now exposes ALL statistics through debugfs instead of sysfs.
For consistency, all cleancache statistics are also moved from sysfs
into debugfs, so this is a good time to also do the name change.
(The name change was also required by Andrew Morton, and previously
suggested by Minchan Kim.)

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
