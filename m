Date: Tue, 14 Sep 2004 13:13:29 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: [PATCH] shrink per_cpu_pages to fit 32byte cacheline
Message-ID: <20040914111329.GB21362@devserv.devel.redhat.com>
References: <20040913233835.GA23894@logos.cnet> <1095142204.2698.12.camel@laptop.fenrus.com> <20040914093407.GA23935@logos.cnet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GRPZ8SYKNexpdSJ7"
Content-Disposition: inline
In-Reply-To: <20040914093407.GA23935@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: akpm@osdl.org, "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--GRPZ8SYKNexpdSJ7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 14, 2004 at 06:34:07AM -0300, Marcelo Tosatti wrote:
> How come short access can cost 1 extra cycle? Because you need two "read bytes" ?

on an x86, a word (2byte) access will cause a prefix byte to the
instruction, that particular prefix byte will take an extra cycle during execution
of the instruction and potentially reduces the parallal decodability of
instructions....

--GRPZ8SYKNexpdSJ7
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBRtJZxULwo51rQBIRAlf6AJ9gWfR/xjSybRxBBOW/Gx/Hj284LACeK49m
gqxhGFAiEUkWeOEYBEjP6ik=
=BcWc
-----END PGP SIGNATURE-----

--GRPZ8SYKNexpdSJ7--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
