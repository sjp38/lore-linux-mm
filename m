Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E12925F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 17:46:01 -0500 (EST)
Subject: Re: marching through all physical memory in software
In-Reply-To: Your message of "Mon, 02 Feb 2009 12:29:45 CST."
             <49873B99.3070405@nortel.com>
From: Valdis.Kletnieks@vt.edu
References: <715599.77204.qm@web50111.mail.re2.yahoo.com> <m1wscc7fop.fsf@fess.ebiederm.org>
            <49873B99.3070405@nortel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1233614746_15229P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Mon, 02 Feb 2009 17:45:46 -0500
Message-ID: <37985.1233614746@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Doug Thompson <norsk5@yahoo.com>, ncunningham-lkml@crca.org.au, Pavel Machek <pavel@suse.cz>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

--==_Exmh_1233614746_15229P
Content-Type: text/plain; charset=us-ascii

On Mon, 02 Feb 2009 12:29:45 CST, Chris Friesen said:
> The next question is who handles the conversion of the various different 
> arch-specific BIOS mappings to a standard format that we can feed to the 
> background "scrub" code.  Is this something that belongs in the edac 
> memory controller code, or would it live in /arch/foo somewhere?

If it's intended to be something basically stand-alone that doesn't require
an actual EDAC chipset, it should probably live elsewhere.  Otherwise, you get
into the case of people who don't enable it because they "know" their hardware
doesn't have an EDAC ability, even if they *could* benefit from the function.

On the other hand, if it's an EDAC-only thing, maybe under drivers/edac/$ARCH?


--==_Exmh_1233614746_15229P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJh3eacC3lWbTT17ARAsqrAKDNNbwYhjwFzQ3MXRkOi9qqTIOMXgCfZfBp
TObEc4Qd+Ohdh/Zr/FmDlec=
=j6YP
-----END PGP SIGNATURE-----

--==_Exmh_1233614746_15229P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
