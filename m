Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AB8C16B004A
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 14:12:07 -0400 (EDT)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
Date: Wed, 6 Jul 2011 14:12:04 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B912622709@nsmail.netscout.com>
In-Reply-To: <d19811cc-a722-4d30-8a43-aedb1cd978c9@default>
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default> <D3F292ADF945FB49B35E96C94C2061B91257D65C@nsmail.netscout.com> <6147447c-ecab-43ea-9b4a-1ff64b2089f0@default> <D3F292ADF945FB49B35E96C94C2061B91257D6FD@nsmail.netscout.com> <704d094e-7b81-480f-8363-327218d1b0ea@default D3F292ADF945FB49B35E96C94C2061B91257DCA8@nsmail.netscout.com> <d19811cc-a722-4d30-8a43-aedb1cd978c9@default>
From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, netdev@vger.kernel.org
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>

> -----Original Message-----
> From: Dan Magenheimer [mailto:dan.magenheimer@oracle.com]
> Sent: July 05, 2011 9:06 PM
> To: Loke, Chetan; netdev@vger.kernel.org
> Cc: Konrad Wilk; linux-mm
> Subject: RE: [RFC] non-preemptible kernel socket for RAMster
>=20
> > From: Loke, Chetan [mailto:Chetan.Loke@netscout.com]
> > Subject: RE: [RFC] non-preemptible kernel socket for RAMster
> >
> > > From: Dan Magenheimer [mailto:dan.magenheimer@oracle.com]
>=20
> > How often are you going to re-size your remote-SWAP?
>=20
> is "as often as the working set changes on any machine in the
> cluster", meaning *constantly*, entirely dynamically!  How
> about a more specific example:  Suppose you have 2 machines,
> each with 8GB of memory.  99% of the time each machine is
> chugging along just fine and doesn't really need more than 4GB,
> and may even use less than 1GB a large part of the time.
> But very now and then, one of the machines randomly needs
> 9GB, 10GB, maybe even 12GB  of memory.  This would normally
> result in swapping.  (Most system administrators won't even
> have this much information... they'll just know they are
> seeing swapping and decide they need to buy more RAM.)
>=20

Ok, I understand there is interest in implementing
'remote-volatile-ballooning-variant' but how do you pick a remote
candidate(hypervisor)? Let's say, memory could be available on remote
system but what if the remote-p{NIC,CPU} is overloaded? Sure, sysadmins
won't have this info because this so dynamic(and it's quite possible as
you mentioned above). But does the trans-remote-API know about this
resource-availability before opening a remote-channel?

Stressing the remote-p{NIC/CPU} might trick hypervisor-vmotion-plugin to
vmotion VM[s] to another hypervisor. How is trans-remote-API integrating
with remote/global vmotion policies to avoid this false vmotion?


> Dan

Chetan Loke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
