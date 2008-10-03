Received: by ey-out-1920.google.com with SMTP id 21so646323eyc.44
        for <linux-mm@kvack.org>; Fri, 03 Oct 2008 05:57:57 -0700 (PDT)
Date: Fri, 3 Oct 2008 15:58:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081003125847.GA9809@localhost.localdomain>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name> <20081003080244.GC25408@elte.hu> <20081003092550.GA8669@localhost.localdomain> <20081003054431.33e19339@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Content-Disposition: inline
In-Reply-To: <20081003054431.33e19339@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 03, 2008 at 05:44:31AM -0700, Arjan van de Ven wrote:
> On Fri, 3 Oct 2008 12:25:52 +0300
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>=20
> > On Fri, Oct 03, 2008 at 10:02:44AM +0200, Ingo Molnar wrote:
> > >=20
> > > * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > >=20
> > > > -	/* for MAP_32BIT mappings we force the legact mmap base
> > > > */
> > > > -	if (!test_thread_flag(TIF_IA32) && (flags & MAP_32BIT))
> > > > +	/* for MAP_32BIT mappings and ADDR_LIMIT_32BIT
> > > > personality we force the
> > > > +	 * legact mmap base
> > > > +	 */
> > >=20
> > > please use the customary multi-line comment style:
> > >=20
> > >   /*
> > >    * Comment .....
> > >    * ...... goes here:
> > >    */
> > >=20
> > > and you might use the opportunity to fix the s/legact/legacy typo
> > > as well.
> >=20
> > Ok, I'll fix it.
> >=20
> > >=20
> > > but more generally, we already have ADDR_LIMIT_3GB support on x86.
> >=20
> > Does ADDR_LIMIT_3GB really work?
>=20
> if it's broken we should fix it.... not invent a new one.
> Also, traditionally often personalities only start at exec() time iirc.
> (but I could be wrong on that)

What is difference beetween ADDR_LIMIT_3GB and ADDR_LIMIT_32BIT? Probably,
I implement ADDR_LIMIT_3GB, not ADDR_LIMIT_32BIT...

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjmFwcACgkQbWYnhzC5v6r6bgCglPzVDYS7Gd39Fi8PObMbKTFp
bxAAnj3qsoDFpFteMNdni8jjWpqohHmq
=2ZxL
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
