Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 69A9E9000C2
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 18:27:27 -0400 (EDT)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
Date: Tue, 5 Jul 2011 18:27:22 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B91257DCA8@nsmail.netscout.com>
In-Reply-To: <704d094e-7b81-480f-8363-327218d1b0ea@default>
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default> <D3F292ADF945FB49B35E96C94C2061B91257D65C@nsmail.netscout.com> <6147447c-ecab-43ea-9b4a-1ff64b2089f0@default D3F292ADF945FB49B35E96C94C2061B91257D6FD@nsmail.netscout.com> <704d094e-7b81-480f-8363-327218d1b0ea@default>
From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, netdev@vger.kernel.org
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

> -----Original Message-----
> From: Dan Magenheimer [mailto:dan.magenheimer@oracle.com]
> Sent: July 05, 2011 3:19 PM
> To: Loke, Chetan; netdev@vger.kernel.org
> Cc: Konrad Wilk; linux-mm
> Subject: RE: [RFC] non-preemptible kernel socket for RAMster
>=20

> Actually, RAMster is using a much more flexible type of
> RAM-drive; it is built on top of Transcendent Memory
> and on top of zcache (and thus on top of cleancache and
> frontswap).  A RAM-drive is fixed size so is not very suitable
> for the flexibility required for RAMster.  For example,
> suppose you have two machines A and B.  At one point in
> time A is overcommitted and needs to swap and B is relatively
> idle.  Then later, B is overcommitted and needs to swap and
> A is relatively idle.  RAMster can handle this entirely
> dynamically, a RAM-drive cannot.


Again, iff NBD works with a ram-drive then you really wouldn't need to
do anything. How often are you going to re-size your remote-SWAP?  Plus,
you can make nbd-server listen on multiple ports - Google(Linux NBD)
returned: http://www.fi.muni.cz/~kripac/orac-nbd/ . Look at the
nbd-server code to see if it launches multiple kernel-threads for
servicing different ports. If not, one can enhance it and scale that way
too. But nbd-server today can service multiple-ports(that is effectively
servicing multiple clients). So why not add NBD-filesystem-filters to
make it point to local/remote swap?


>=20
> Thanks.  Could you provide a pointer for this?  I found
> the SCST sourceforge page but no obvious references to
> scst-in-ram-mode.  (But also, since it appears to be
> SCSI-related, I wonder if it also assumes a fixed size
> target device, RAM or disk or ??)
>=20

Yes, it is SCSI. You should be looking for SCST I/O modes. Read some
docs and then send an email to the scst-mailing-list. If you speak about
block-IO-performance then FC(in its class of price/performance factor)
is more than capable of handling any workload. FC is a protocol designed
for storage. No exotic fabric other than FC is needed.
Folks who start with ethernet for block-IO, always start with bare
minimal code and then for squeezing block-IO performance(aka version 2
of the product), keep hacking repeatedly or go for a link-speed upgrade.
Start with FC, period.


> Dan

Chetan Loke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
