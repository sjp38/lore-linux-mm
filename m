Date: Tue, 14 Sep 2004 13:44:12 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: [PATCH] shrink per_cpu_pages to fit 32byte cacheline
Message-ID: <20040914114412.GC21362@devserv.devel.redhat.com>
References: <20040913233835.GA23894@logos.cnet> <1095142204.2698.12.camel@laptop.fenrus.com> <20040914093407.GA23935@logos.cnet> <20040914111329.GB21362@devserv.devel.redhat.com> <20040914100152.GB23935@logos.cnet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eRtJSFbw+EEWtPj3"
Content-Disposition: inline
In-Reply-To: <20040914100152.GB23935@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: akpm@osdl.org, "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--eRtJSFbw+EEWtPj3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 14, 2004 at 07:01:52AM -0300, Marcelo Tosatti wrote:
> On Tue, Sep 14, 2004 at 01:13:29PM +0200, Arjan van de Ven wrote:
> > On Tue, Sep 14, 2004 at 06:34:07AM -0300, Marcelo Tosatti wrote:
> > > How come short access can cost 1 extra cycle? Because you need two "read bytes" ?
> > 
> > on an x86, a word (2byte) access will cause a prefix byte to the
> > instruction, that particular prefix byte will take an extra cycle during execution
> > of the instruction and potentially reduces the parallal decodability of
> > instructions....
> 
> OK thanks Arjan, where did you read this? The "Intel IA32 Optimization Guide" ?

some version of that; I can't find it in my current one though. Hrmpf
Maybe there's someone from intel or amd on this list who can confirm the
performance impact of the 0x66 operand size override prefix


--eRtJSFbw+EEWtPj3
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBRtmMxULwo51rQBIRAuDHAKCCFMxroh49RdiKe8nzltcYiBhvDACeJ2XY
RFoMTegVtEGJuih+BFVCv5A=
=tKLu
-----END PGP SIGNATURE-----

--eRtJSFbw+EEWtPj3--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
