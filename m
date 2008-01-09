Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in msync()
In-Reply-To: Your message of "Wed, 09 Jan 2008 15:50:15 EST."
             <20080109155015.4d2d4c1d@cuia.boston.redhat.com>
From: Valdis.Kletnieks@vt.edu
References: <1199728459.26463.11.camel@codedot>
            <20080109155015.4d2d4c1d@cuia.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1199912777_3223P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 09 Jan 2008 16:06:17 -0500
Message-ID: <26932.1199912777@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Anton Salikhmetov <salikhmetov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_1199912777_3223P
Content-Type: text/plain; charset=us-ascii

On Wed, 09 Jan 2008 15:50:15 EST, Rik van Riel said:

> Could you explain (using short words and simple sentences) what the
> exact problem is?
> 
> Eg.
> 
> 1) program mmaps file
> 2) program writes to mmaped area
> 3) ???                   <=== this part, in equally simple words :)
> 4) data loss

It's like this:

Monday  9:04AM:  System boots, database server starts up, mmaps file
Monday  9:06AM:  Database server writes to mmap area, updates mtime/ctime
Monday <many times> Database server writes to mmap area, no further update..
Monday 11:45PM:  Backup sees "file modified 9:06AM, let's back it up"
Tuesday 9:00AM-5:00PM: Database server touches it another 5,398 times, no mtime
Tuesday 11:45PM: Backup sees "file modified back on Monday, we backed this up..
Wed  9:00AM-5:00PM: More updates, more not touching the mtime
Wed  11:45PM: *yawn* It hasn't been touched in 2 days, no sense in backing it up..

Lather, rinse, repeat....

--==_Exmh_1199912777_3223P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHhTdJcC3lWbTT17ARAtytAKCxm4JJmxFMV7xD6Lhqad5vNk0sxgCgzb0V
m5TQFMylvvkifttlOXMEypE=
=9BM7
-----END PGP SIGNATURE-----

--==_Exmh_1199912777_3223P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
