Date: Thu, 19 Feb 2004 12:11:17 +0100
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040219111116.GA16733@devserv.devel.redhat.com>
References: <20040217073522.A25921@infradead.org> <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org> <1077108694.4479.4.camel@laptop.fenrus.com> <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040219102900.GC14000@marowsky-bree.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
Content-Disposition: inline
In-Reply-To: <20040219102900.GC14000@marowsky-bree.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lars Marowsky-Bree <lmb@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, paulmck@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


On Thu, Feb 19, 2004 at 11:29:00AM +0100, Lars Marowsky-Bree wrote:
> > b) Does the IBM filsystem meet the kernel's licensing requirements?
> 
> If you are worried about this one, you can export it GPL-only, which as
> an Open Source developer I'd appreciate, but from a real-world business
> perspective would be unhappy about ;-)

It already is exported GPL-only, this is all about changing it to be for
linking bin only modules as well...

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFANJnSxULwo51rQBIRAjxIAJ4gz33/PrBa8r0mMAS3KX8uufq0ggCgixbV
aHMeoUmCUO2RHR+5XyF8Yy8=
=/TvR
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
