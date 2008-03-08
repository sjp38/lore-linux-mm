Message-ID: <47D2E197.5090806@tuxrocks.com>
Date: Sat, 08 Mar 2008 12:57:27 -0600
From: Frank Sorenson <frank@tuxrocks.com>
MIME-Version: 1.0
Subject: Re: [patch] revert "dcdbas: add DMI-based module autloading"
References: <47D02940.1030707@tuxrocks.com> <20080306184954.GA15492@elte.hu>	 <47D1971A.7070500@tuxrocks.com> <47D23B7E.3020505@tuxrocks.com>	 <20080308082243.GA18123@elte.hu> <1205000172.8748.4.camel@lov.site>
In-Reply-To: <1205000172.8748.4.camel@lov.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Cc: Ingo Molnar <mingo@elte.hu>, Matt_Domsch@dell.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Kay Sievers wrote:
> Frank, can you grep for 'dcdbas' in the modprobe config files:
>   modprobe -c | grep dcdbas
> ?
> 
> I wonder what's going on here, that modprobe calls itself.
> 
> Thanks,
> Kay

Aha.  This is indeed where the problem was.  A line in the modprobe
config files was supposed to cause dcdbas to load, but was instead
causing modprobe to call itself repeatedly for dcdbas.  I don't know why
an incorrect line was there, but removing it from the config allows
dcdbas to load without problem manually, and the autoload patch loads it
automatically.

Sincere apologies to everyone for causing the fire drill on a false
alarm.  Since fixing my config makes things work again, and nobody else
sees the problem, the autoload patch should stay.

Thanks for the help tracking down the issue.

Frank (off to hide in the corner)
- --
Frank Sorenson - KD7TZK
Linux Systems Engineer, DSS Engineering, UBS AG
frank@tuxrocks.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFH0uGTaI0dwg4A47wRApD/AKDsYtoatp/mJShgdHVDj5RKOH8GsgCg4w8D
WA8R+ZpjHPManfxvIuqD+lY=
=4c2w
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
