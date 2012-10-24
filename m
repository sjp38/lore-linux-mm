Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 0F0856B006E
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 05:13:45 -0400 (EDT)
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00331-06 for <linux-mm@kvack.org>; Wed, 24 Oct 2012 10:13:42 +0100 (BST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Subject: RE: [RFC PATCH v2 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
Date: Wed, 24 Oct 2012 10:06:36 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7060@saturn3.aculab.com>
In-Reply-To: <CACVXFVN+=XH_f5BmRkXeagTNowz0o0-Pd7GcxCneO0FSq8xqEw@mail.gmail.com>
References: <CACVXFVMmszZWHaeNS6LSG4nHR4wWBLwM_BvynRwUW8X=nO+JWA@mail.gmail.com><Pine.LNX.4.44L0.1210231022230.1635-100000@iolanthe.rowland.org> <CACVXFVN+=XH_f5BmRkXeagTNowz0o0-Pd7GcxCneO0FSq8xqEw@mail.gmail.com>
From: "David Laight" <David.Laight@ACULAB.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>, Alan Stern <stern@rowland.harvard.edu>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

> Looks the problem is worse than above, not only bitfields are =
affected, the
> adjacent fields might be involved too, see:
>=20
>            http://lwn.net/Articles/478657/

Not mentioned in there is that even with x86/amd64 given
a struct with the following adjacent fields:
	char a;
	char b;
	char c;
then foo->b |=3D 0x80; might do a 32bit RMW cycle.
This will (well might - but probably does) happen
if compiled to a 'BTS' instruction.
The x86 instruction set docs are actually unclear
as to whether the 32bit cycle might even be misaligned!
amd64 might do a 64bit cycle (not checked the docs).

	David



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
