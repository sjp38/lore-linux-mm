Message-Id: <200301241934.h0OJYf0V005773@turing-police.cc.vt.edu>
Subject: Re: 2.5.59-mm5 
In-Reply-To: Your message of "Sat, 25 Jan 2003 04:22:39 +1100."
             <3E31765F.4010900@cyberone.com.au>
From: Valdis.Kletnieks@vt.edu
References: <XFMail.20030124180942.pochini@shiny.it>
            <3E31765F.4010900@cyberone.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-1046921216P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 24 Jan 2003 14:34:41 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Giuliano Pochini <pochini@shiny.it>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-kernel@alex.org.uk, Alex Tomas <bzzz@tmi.comex.ru>, Andrew Morton <akpm@digeo.com>, Oliver Xymoron <oxymoron@waste.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_-1046921216P
Content-Type: text/plain; charset=us-ascii

On Sat, 25 Jan 2003 04:22:39 +1100, Nick Piggin said:
> We probably wouldn't want to go that far as you obviously can
> only merge reads with reads and writes with writes, a flag would
> be fine. We have to get the basics working first though ;)

"obviously can only"?  Admittedly, merging reads and writes is a lot
trickier, and probably "too hairy to bother", but I'm not aware of a
fundamental "cant" that applies across IDE/SCSI/USB/1394/fiberchannel/etc.
-- 
				Valdis Kletnieks
				Computer Systems Senior Engineer
				Virginia Tech


--==_Exmh_-1046921216P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQE+MZVQcC3lWbTT17ARAirtAKD+vdxMTQ7XTuj3ys3j+eCl+RTVEgCfWIfu
SdYafBlBqlHPsPw841b1FmQ=
=iqYo
-----END PGP SIGNATURE-----

--==_Exmh_-1046921216P--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
