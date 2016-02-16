Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 44BED6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:12:28 -0500 (EST)
Received: by mail-qk0-f170.google.com with SMTP id s5so68527258qkd.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:12:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x145si41239253qka.105.2016.02.16.08.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 08:12:27 -0800 (PST)
Message-ID: <1455639143.15821.21.camel@redhat.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
From: Rik van Riel <riel@redhat.com>
Date: Tue, 16 Feb 2016 11:12:23 -0500
In-Reply-To: <20160216052852.GW19486@dastard>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
	 <20160214211856.GT19486@dastard> <56C216CA.7000703@cisco.com>
	 <20160215230511.GU19486@dastard> <56C264BF.3090100@cisco.com>
	 <20160216052852.GW19486@dastard>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-YWDzmM/d9uaLkMpyOzLk"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Daniel Walker <danielwa@cisco.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Khalid Mughal <khalidm@cisco.com>, xe-kernel@external.cisco.com, dave.hansen@intel.com, hannes@cmpxchg.org, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Nag Avadhanam (nag)" <nag@cisco.com>


--=-YWDzmM/d9uaLkMpyOzLk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-16 at 16:28 +1100, Dave Chinner wrote:
> On Mon, Feb 15, 2016 at 03:52:31PM -0800, Daniel Walker wrote:
> > On 02/15/2016 03:05 PM, Dave Chinner wrote:
> > >=C2=A0
> > > As for a replacement, looking at what pages you consider
> > > "droppable"
> > > is really only file pages that are not under dirty or under
> > > writeback. i.e. from /proc/meminfo:
> > >=20
> > > Active(file):=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0220128 kB
> > > Inactive(file):=C2=A0=C2=A0=C2=A0=C2=A060232 kB
> > > Dirty:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00 kB
> > > Writeback:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A00 kB
> > >=20
> > > i.e. reclaimable file cache =3D Active + inactive - dirty -
> > > writeback.
> .....
>=C2=A0
> > As to his other suggestion of estimating the droppable cache, I
> > have considered it but found it unusable. The problem is the
> > inactive file pages count a whole lot pages more than the
> > droppable pages.
>=20
> inactive file pages are supposed to be exactly that - inactive. i.e.
> the have not been referenced recently, and are unlikely to be dirty.
> They should be immediately reclaimable.

Inactive file pages can still be mapped by
processes.

The reason we do not unmap file pages when
moving them to the inactive list is that
some workloads fill essentially all of memory
with mmapped file pages.

Given that the inactive list is generally a
considerable fraction of file memory, unmapping
pages that get deactivated could create a lot
of churn and unnecessary page faults for that
kind of workload.

--=C2=A0
All rights reversed

--=-YWDzmM/d9uaLkMpyOzLk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJWw0pnAAoJEM553pKExN6DVLcIAKciv8mUmBSSojyQ7zoraptg
cHC5xnP3kcavpvq+uWBQvnQ9XnkKAWUQFj7KfZHTb0ny6QFK1LVoqS9rtLiiVwQQ
u7I6V5z6W3ZoJhVzKuvVuIRRDPm34ypoUMCi138WwaP9LQVA4hGpI2x1MzRC3AFq
DAsh/Rn4wPLkZ6UK2+EyW1VUxSoURICJXQed15mEUt6Kn/mAlZKv+U68soUVqUT2
/RT/zWlwzUaymkcmCT00DfsP2hZJz0meWm/lCH9nnPxS3sn68vs1nLkmAXg+E7Ib
vxYiXt2f6AXTxbuwg+yWX9pL5YzLNexsiEXCamCIzJu6kEhvZje00xPH5xyLkeE=
=C8VL
-----END PGP SIGNATURE-----

--=-YWDzmM/d9uaLkMpyOzLk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
