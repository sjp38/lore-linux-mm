Date: Tue, 12 Oct 2004 17:20:59 +0200
From: Jan-Benedict Glaw <jbglaw@lug-owl.de>
Subject: Re: NUMA: Patch for node based swapping
Message-ID: <20041012152059.GB5033@lug-owl.de>
References: <Pine.LNX.4.58.0410120751010.11558@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LtWARj4qtdVynAWs"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0410120751010.11558@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--LtWARj4qtdVynAWs
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 2004-10-12 08:02:40 -0700, Christoph Lameter <clameter@sgi.com>
wrote in message <Pine.LNX.4.58.0410120751010.11558@schroedinger.engr.sgi.c=
om>:
> --- linux-2.6.9-rc4.orig/mm/page_alloc.c	2004-10-10 19:57:03.000000000 -0=
700
> +++ linux-2.6.9-rc4/mm/page_alloc.c	2004-10-11 12:54:51.000000000 -0700
> @@ -483,6 +486,13 @@
>  	p =3D &z->pageset[cpu];
>  	if (pg =3D=3D orig) {
>  		z->pageset[cpu].numa_hit++;
> +		/*
> +		 * If zone allocation leaves less than a (sysctl_node_swap * 10) %
> +		 * of the zone free then invoke kswapd.
> +		 * (to make it efficient we do (pages * sysctl_node_swap) / 1024))
> +		 */
> +		if (z->free_pages < (z->present_pages * sysctl_node_swap) << 10)
> +			wakeup_kswapd(z);
>  	} else {
>  		p->numa_miss++;
>  		zonelist->zones[0]->pageset[cpu].numa_foreign++;

Shouldn't the comment read "less than (sysctl_node_swap / 10) %",
because the value in sysctl_node_swap is actually percent*10, so you
need the reverse action here?!

MfG, JBG

--=20
Jan-Benedict Glaw       jbglaw@lug-owl.de    . +49-172-7608481             =
_ O _
"Eine Freie Meinung in  einem Freien Kopf    | Gegen Zensur | Gegen Krieg  =
_ _ O
 fuer einen Freien Staat voll Freier B=FCrger" | im Internet! |   im Irak! =
  O O O
ret =3D do_actions((curr | FREE_SPEECH) & ~(NEW_COPYRIGHT_LAW | DRM | TCPA)=
);

--LtWARj4qtdVynAWs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBa/ZaHb1edYOZ4bsRAi4DAJ408cUnPWVqcbS93ncV6qHSueeL3ACfd01W
5Ni66rH7QktvlXyrSxZVpiY=
=Y40U
-----END PGP SIGNATURE-----

--LtWARj4qtdVynAWs--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
