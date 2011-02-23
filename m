Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 92E3B8D003D
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 10:31:25 -0500 (EST)
Received: by vxc38 with SMTP id 38so2961315vxc.14
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 07:31:23 -0800 (PST)
Date: Wed, 23 Feb 2011 10:31:18 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 5/5] have smaps show transparent huge pages
Message-ID: <20110223153118.GE2810@mgebm.net>
References: <20110222015338.309727CA@kernel>
 <20110222015345.BF949720@kernel>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZInfyf7laFu/Kiw7"
Content-Disposition: inline
In-Reply-To: <20110222015345.BF949720@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, akpm@osdl.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>


--ZInfyf7laFu/Kiw7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 21 Feb 2011, Dave Hansen wrote:

>=20
> Now that the mere act of _looking_ at /proc/$pid/smaps will not
> destroy transparent huge pages, tell how much of the VMA is
> actually mapped with them.
>=20
> This way, we can make sure that we're getting THPs where we
> expect to see them.
>=20
> v3 - * changed HPAGE_SIZE to HPAGE_PMD_SIZE, probably more correct
>        and also has a nice BUG() in case there was a .config mishap
>      * remove direct reference to ->page_table_lock, and used the
>        passed-in ptl pointer insteadl
>=20
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Reviewed-and-tested-by: Eric B Munson <emunson@mgebm.net>

--ZInfyf7laFu/Kiw7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNZShGAAoJEH65iIruGRnNUYwH+gNDTiqWFnERc/nD72V5k8zj
PEd9BqE0XqfyfXAaIySAgT6JfWJzlDG1zumNHNPXbtvHgSIn/5V92I3o+WIm2Jpi
7n+wxcFt9q4D5DDqa9BsHnr7bAANe3AjKjA6+yDET3dUlQpfPFG2iMvDCQ0V3mPk
Mdr7a6ZSP9eMVcZKkE2V+z/M3PO84qT7Qd3j7e8GGKY35fQocHlbvKsPGu4sicGg
v1sRHr/jtH/NyrEE5xhVvgskVbj4pcgyMKIxX/0uVU5Yq/Dc2LIjkF6ZYl9sHnIt
qA4lVAbNxaOtYsCWE39hT26VgmC/72IWmolhRTk7A6tDO+E58ipodLRoMNYwxhQ=
=Pyxw
-----END PGP SIGNATURE-----

--ZInfyf7laFu/Kiw7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
