Date: Fri, 16 May 2003 19:28:34 +0200
From: Andreas Henriksson <andreas@fjortis.info>
Subject: Re: 2.5.69-mm6
Message-ID: <20030516172834.GA9774@foo>
References: <20030516015407.2768b570.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yrj/dFKFPuw6o+aM"
Content-Disposition: inline
In-Reply-To: <20030516015407.2768b570.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline

Hi!

I had to remove "static" from the agp_init-function in
drivers/char/agp/backend.c to get the kernel to link (when building
Intel 810 Framebuffer into the kernel).

I also got unresolved symbols for two modules.
arch/i386/kernel/suspend.ko: enable_sep_cpu, default_ldt, init_tss
arch/i386/kernel/apm.ko: save_processor_state, restore_processor_state

Regards,
Andreas Henriksson

--yrj/dFKFPuw6o+aM
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE+xR/CAO9glESeBDQRApDYAJ9K8lh2ePhOyHuoxj4A1AEVjoVNpACguI+5
YDr6+BtNJCcHBMu9bMfj1eQ=
=bwlX
-----END PGP SIGNATURE-----

--yrj/dFKFPuw6o+aM--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
