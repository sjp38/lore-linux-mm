Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id BEFB46B0033
	for <linux-mm@kvack.org>; Tue, 21 May 2013 06:13:51 -0400 (EDT)
Message-ID: <20130521101349.30660.qmail@stuge.se>
Date: Tue, 21 May 2013 12:13:49 +0200
From: Peter Stuge <peter@stuge.se>
Subject: Re: [PATCH] Finally eradicate CONFIG_HOTPLUG
References: <20130521134935.d18c3f5c23485fb5ddabc365@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Content-Disposition: inline
In-Reply-To: <20130521134935.d18c3f5c23485fb5ddabc365@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arch@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-pcmcia@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, cluster-devel@redhat.com, linux-mm@kvack.org, Hans Verkuil <hans.verkuil@cisco.com>, Pavel Machek <pavel@ucw.cz>, Doug Thompson <dougthompson@xmission.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Whitehouse <swhiteho@redhat.com>, linux-arm-kernel@lists.infradead.org, linux-edac@vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Are you changing the code to have HOTPLUG always -on- or -off- ?

=46rom the commit message I had expected always -on-.


Stephen Rothwell wrote:
> --- a/include/asm-generic/vmlinux.lds.h
> +++ b/include/asm-generic/vmlinux.lds.h
> @@ -68,14 +68,6 @@
>   * are handled as text/data or they can be discarded (which
>   * often happens at runtime)
>   */
> -#ifdef CONFIG_HOTPLUG
> -#define DEV_KEEP(sec)    *(.dev##sec)
> -#define DEV_DISCARD(sec)
> -#else
> -#define DEV_KEEP(sec)
> -#define DEV_DISCARD(sec) *(.dev##sec)
> -#endif
> -
>  #ifdef CONFIG_HOTPLUG_CPU
>  #define CPU_KEEP(sec)    *(.cpu##sec)
>  #define CPU_DISCARD(sec)
> @@ -182,8 +174,6 @@
>  	*(.data)							\
>  	*(.ref.data)							\
>  	*(.data..shared_aligned) /* percpu related */			\
> -	DEV_KEEP(init.data)						\
> -	DEV_KEEP(exit.data)						\
=2E.
> @@ -503,7 +489,6 @@
>  /* init and exit section handling */
>  #define INIT_DATA							\
>  	*(.init.data)							\
> -	DEV_DISCARD(init.data)						\

Shouldn't the effect of one of the above remain?


//Peter

--ibTvN161/egqYuK8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iD8DBQFRm0jdhR3Q0dhIfEgRAtAtAKDxeofcdUGqWjn2AyXb/CxbZP4X8ACgvEte
zomgM5roARu65KybTU/PIcM=
=bMNu
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
