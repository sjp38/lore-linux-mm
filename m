Date: Thu, 19 Feb 2004 19:38:22 +0100
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040219183821.GA1935@devserv.devel.redhat.com>
References: <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040218230055.A14889@infradead.org> <20040218162858.2a230401.akpm@osdl.org> <20040219123110.A22406@infradead.org> <20040219091129.GD1269@us.ibm.com> <20040219183210.GX14000@marowsky-bree.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5vNYLRcllDrimb99"
Content-Disposition: inline
In-Reply-To: <20040219183210.GX14000@marowsky-bree.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lars Marowsky-Bree <lmb@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


On Thu, Feb 19, 2004 at 07:32:10PM +0100, Lars Marowsky-Bree wrote:
> 
> A rule of thumb might be whether any code in the tree uses a given
> export, and if not, prune it. Anything which even we don't use or export
> across the user-land boundary certainly qualifies as a kernel interna.

political issues aside, this sounds like a decent rule-of-thumb in general;
if NO module uses it, it is most likely the wrong API (for example obsoleted API left
around) or something really internal.
--5vNYLRcllDrimb99
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFANQKcxULwo51rQBIRAmFZAJ4+fydVzl9fr0cFnGo6mf8/JMdp5QCgoAsw
x42ySutl48VR3Yo8m6bljlg=
=ylm8
-----END PGP SIGNATURE-----

--5vNYLRcllDrimb99--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
