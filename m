Received: from nitc.ac.in (csed.nitc.ac.in [210.212.228.78])
	by cnet.nitc.ac.in (8.11.6/8.11.6) with SMTP id h14D7mm08723
	for <linux-mm@kvack.org>; Tue, 4 Feb 2003 18:37:48 +0530
Date: Tue, 4 Feb 2003 18:49:44 +0100
From: John Navil Joseph <cs99185@nitc.ac.in>
Subject: Doubt in pagefault handler..!
Message-ID: <20030204174944.GA836@192.168.3.73>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lrZ03NoBR/3+SXJZ"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

	I am trying to implement Distributed Shared Memory for LInux. I am plannin=
g to
implement this in the same lines as of SystemV IPC shared Memory. Well in t=
his case the processes involved in the DSM may be present in any computer a=
cross the network.

*) on the occurence of a pagefault (in the VMA correspnding to the DSM) it =
may be necessary for me to fetch
the physical pages remotely across the network. So my page fault handler ma=
y need to prempt the faulting process
till the page is fetched from across the network. I am not sure how this is=
 to be done.

I assume that i can deal with the page fault handler just as any other inte=
rrupt handler and proceed to do the=20
following.

	1) add the current process to a wait queue=20
	2) invoke schedule() from the page fault handler
	3) wake up the process after the transfer has been completed.

now my question is=20

	is it possible to invoke schedule() from page fault handler. ?

	I know that the hardware restarts the faulting instruction after handling =
the interrupt..
	so if i invoke schedule() from the pf handler.. then how will the interupt=
 return..
	and how does hardware handle this situation ?

	i tried to trace pagefault handler all the way down to where the acutal IO=
 takes palce incase
	of the transfer of page from swap to memory..But i never saw schedule() an=
ywhere. But i know that
	process sleeps on page I/O .. then how and where does this sleeping takes =
place.?

please forgive me as my knowledge about the linux MM is inconsistent.=20
I hope that my questions are clear.

TIA
	john
=09










=09

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQE+P/04oUm9LrSG9ykRAtyZAJ9P1Ecush9qFAx6q/0uKPwesmsrbQCcCPY4
P9RSjlpe/cDJN1TW509Abxw=
=QsFB
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
