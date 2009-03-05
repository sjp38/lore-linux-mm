Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 20B086B00C6
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 08:50:27 -0500 (EST)
From: Markus <M4rkusXXL@web.de>
Subject: Re: drop_caches ...
Date: Thu, 5 Mar 2009 14:50:22 +0100
References: <200903041057.34072.M4rkusXXL@web.de> <200903051255.35407.M4rkusXXL@web.de> <20090305133603.GA22442@localhost>
In-Reply-To: <20090305133603.GA22442@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Message-Id: <200903051450.23163.M4rkusXXL@web.de>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Wu Fengguang <fengguang.wu@intel.com>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lukas Hejtmanek <xhejtman@ics.muni.cz>
List-ID: <linux-mm.kvack.org>

Am Donnerstag, 5. M=E4rz 2009 schrieb Wu Fengguang:
> Hi Markus,
>=20
> On Thu, Mar 05, 2009 at 01:55:35PM +0200, Markus wrote:
> > > Markus, you may want to try this patch, it will have better chance=20
to figure out
> > > the hidden file pages.
> > >=20
> > > 1) apply the patch and recompile kernel with=20
CONFIG_PROC_FILECACHE=3Dm
> > > 2) after booting:
> > >         modprobe filecache
> > >         cp /proc/filecache filecache-`date +'%F'`
> > > 3) send us the copied file, it will list all cached files,=20
including
> > >    the normally hidden ones.
> >=20
> > The file consists of 674 lines. If I interpret it right, "size" is=20
the=20
> > filesize and "cached" the amount of the file being in cache (why can=20
> > this be bigger than the file?!).
>=20
>           size =3D file size in bytes
>         cached =3D cached pages
>=20
> So it's normal that (size > cached).

Yeah, I just wondered because sometimes its size < cached, buts thats=20
because cached must obviously be a multiple of 4 KB. So no problem=20
here ;)

Thanks,
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
