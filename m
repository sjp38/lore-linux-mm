Date: Thu, 2 Oct 2003 22:58:00 +0200
From: Bongani Hlope <bonganilinux@mweb.co.za>
Subject: Re: 2.6.0-test6-mm2
Message-Id: <20031002225800.165b4f05.bonganilinux@mweb.co.za>
In-Reply-To: <20031002134504.A12141@osdlab.pdx.osdl.net>
References: <20031002022341.797361bc.akpm@osdl.org>
	<20031002223545.55611ef6.bonganilinux@mweb.co.za>
	<20031002134504.A12141@osdlab.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1"; boundary="Multipart_Thu__2_Oct_2003_22_58_00_+0200_=.OcPwvV'8L'O_Jj"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Multipart_Thu__2_Oct_2003_22_58_00_+0200_=.OcPwvV'8L'O_Jj
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Thu, 02 Oct 2003 13:45:04 -0700
Chris Wright <chrisw@osdl.org> wrote:

> * Bongani Hlope (bonganilinux@mweb.co.za) wrote:
> > -mm1 had a lot of events/0 zombies, and vanilla 2.6.0-test6 does not. I will test -mm2 and let you know how it goes. Alt-SysRq shows this:
> > 
> > 
> > events/0      Z 77361907  1834      3          1836  1831 (L-TLB)
> > c46abfc4 00000046 cf901940 77361907 00000058 c5dfa080 00000011 77361907
> >        00000058 cf901940 cf901960 00011d32 77361907 00000058 cffeeaf8 00000000
> >        c5dfa080 00000000 c0124b60 c5dfa080 00000000 00000000 00000000 c01322f0
> > Call Trace:
> >  [do_exit+560/1040] do_exit+0x230/0x410
> >  [<c0124b60>] do_exit+0x230/0x410
> >  [wait_for_helper+0/224] wait_for_helper+0x0/0xe0
> >  [<c01322f0>] wait_for_helper+0x0/0xe0
> >  [kernel_thread_helper+11/12] kernel_thread_helper+0xb/0xc
> >  [<c010ae5f>] kernel_thread_helper+0xb/0xc
> 
> Just to be clear, this sysrq trace is from -mm1, correct?  A fix has
> gone into -mm2 for this, which is why I'm asking.
> 
> thanks,
> -chris

Yes this is from -mm1, I'm busy compiling -mm2

--Multipart_Thu__2_Oct_2003_22_58_00_+0200_=.OcPwvV'8L'O_Jj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/fJFY+pvEqv8+FEMRAqm5AJ4+ARGs/HoCIxGKc8SeNIMuWCDscwCgiVBt
EmOKssoDOnaoa6Eg+VDC0DE=
=Q7W8
-----END PGP SIGNATURE-----

--Multipart_Thu__2_Oct_2003_22_58_00_+0200_=.OcPwvV'8L'O_Jj--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
