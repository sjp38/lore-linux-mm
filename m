Date: Wed, 18 Aug 2004 08:11:21 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: arch_get_unmapped_area_topdown vs stack reservations
Message-ID: <20040818061121.GB21740@devserv.devel.redhat.com>
References: <170170000.1092781114@flay>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jho1yZJdad60DJr+"
Content-Disposition: inline
In-Reply-To: <170170000.1092781114@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--jho1yZJdad60DJr+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 17, 2004 at 03:18:34PM -0700, Martin J. Bligh wrote:
> I worry that the current code will allow us to intrude into the 
> reserved stack space with a vma allocation if it's requested at
> an address too high up. One could argue that they got what they
> asked for ... but not sure we should be letting them do that?

well even the non-flexmmap code allows this.... what is the problem ?


--jho1yZJdad60DJr+
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBIvMIxULwo51rQBIRAvo9AJ9rOuuo9KirDsr9quFJ+XjxI2v3IQCeNoO/
WFyTSJmRPBaCOlWx8KtDaXU=
=PYTp
-----END PGP SIGNATURE-----

--jho1yZJdad60DJr+--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
