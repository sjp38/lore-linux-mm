Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C1FE56B007E
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 13:25:45 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6147447c-ecab-43ea-9b4a-1ff64b2089f0@default>
Date: Tue, 5 Jul 2011 10:25:21 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default
 D3F292ADF945FB49B35E96C94C2061B91257D65C@nsmail.netscout.com>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B91257D65C@nsmail.netscout.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>, netdev@vger.kernel.org
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

> From: Loke, Chetan [mailto:Chetan.Loke@netscout.com]
> Sent: Tuesday, July 05, 2011 10:37 AM
> To: Dan Magenheimer; netdev@vger.kernel.org
> Cc: Konrad Wilk; linux-mm
> Subject: RE: [RFC] non-preemptible kernel socket for RAMster
>=20
> > In working on a kernel project called RAMster* (where RAM on a
> > remote system may be used for clean page cache pages and for swap
> > pages), I found I have need for a kernel socket to be used when
>=20
> How is RAMster+swap different than NBD's (pending etc?)support for SWAP
> over NBD?

Hi Chetan --

Thanks for your question.

I may be ignorant of details about NBD, but did some quick
research using google.  If I understand correctly, swap over
NBD is still writing to a configured swap disk on the remote
machine.  RAMster is swapping to *RAM* on the remote machine.
The idea is that most machines are very overprovisioned in
RAM, and are rarely using all of their RAM, especially when
a machine is (mostly) idle.  In other words, the "max of
the sums" of RAM usage on a group of machines is much lower
than the "sum of the max" of RAM usage.

So if the network is sufficiently faster than disk for
moving a page of data, RAMster provides a significant
performance improvement.  OR RAMster may allow a significant
reduction in the total amount of RAM across a data center.

The version of RAMster I am working on now is really
a proof-of-concept that works over sockets, using the
ocfs2 cluster layer.  One can easily envision a future
"exo-fabric" which allows one machine to write to the
RAM of another machine... for this future hardware,
RAMster becomes much more interesting.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
