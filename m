Subject: Re: [PATCH 00/23] per device dirty throttling -v8
In-Reply-To: Your message of "Fri, 10 Aug 2007 00:04:45 EDT."
             <46BBE3DD.2090209@tmr.com>
From: Valdis.Kletnieks@vt.edu
References: <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804224834.5187f9b7@the-village.bc.nu> <20070805071320.GC515@elte.hu> <20070805152231.aba9428a.diegocg@gmail.com> <Pine.LNX.4.64.0708051158260.6905@asgard.lang.hm>
            <46BBE3DD.2090209@tmr.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1186809557_3018P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Sat, 11 Aug 2007 01:19:17 -0400
Message-ID: <10215.1186809557@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: david@lang.hm, Diego Calleja <diegocg@gmail.com>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

--==_Exmh_1186809557_3018P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Fri, 10 Aug 2007 00:04:45 EDT, Bill Davidsen said:

> > I never imagined that itwas the 20%+ hit that is being described, and=
=20
> > with so little impact, or I would have switched to it across the boar=
d=20
> > years ago.
> >=20
> To get that magnitude you need slow disk with very fast CPU. It helps=20
> most of systems where the disk hardware is marginal or worse for the i/=
o=20
> load. Don't take that as typical.

I suspect that almost every single laptop with a Core2 Duo in it falls in=
to
that classification, and it's getting worse every year, as we see more
disparity between CPU speeds (increasing) and disk seek times (basically =
nailed
to the floor for the last decade).


--==_Exmh_1186809557_3018P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGvUbVcC3lWbTT17ARAuPXAJ9SqM6bwtjumsVtyAuumj927ov+KgCeO7v9
zXyrLmOV51EQiA3Js4pUJ1k=
=wgKI
-----END PGP SIGNATURE-----

--==_Exmh_1186809557_3018P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
