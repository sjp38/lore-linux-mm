Received: from fsuj20.rz.uni-jena.de (fsuj20.rz.uni-jena.de [141.35.1.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA20626
	for <linux-mm@kvack.org>; Wed, 24 Mar 1999 02:42:20 -0500
Message-ID: <36F8974A.D4EB4BAD@imsid.uni-jena.de>
Date: Wed, 24 Mar 1999 08:42:02 +0100
From: Matthias Arnold <Matthias.Arnold@edda.imsid.uni-jena.de>
MIME-Version: 1.0
Subject: [Fwd: LINUX-MM]
Content-Type: multipart/mixed; boundary="------------015E290428FAC0B1C9653924"
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------015E290428FAC0B1C9653924
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit



--

*****************************************************************
* Matthias Arnold
* Klinikum der Friedrich-Schiller-Universitaet
* Institut fuer Med. Statistik, Informatik und Dokumentation
* Jahnstrasse 3
* D-07743 Jena
*
* email:iia@imsid.uni-jena.de
* Tel. :+49-3641-934130
* FAX  :+49-3641-933200
******************************************************************



--------------015E290428FAC0B1C9653924
Content-Type: message/rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Message-ID: <36F895C4.1801DBE6@imsid.uni-jena.de>
Date: Wed, 24 Mar 1999 08:35:32 +0100
From: Matthias Arnold <Matthias.Arnold@imsid.uni-jena.de>
Organization: imsid.uni-jena.de
X-Mailer: Mozilla 4.05 [en] (X11; I; Linux 2.1.128 i686)
MIME-Version: 1.0
To: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: LINUX-MM
References: <Pine.LNX.4.03.9903231514290.10060-100000@mirkwood.dummy.home>
		<199903231549.KAA20478@x15-cruise-basselope> <14071.53276.848923.609704@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Stephen C. Tweedie wrote:

> Hi,
>
> On Tue, 23 Mar 1999 10:49:11 EST, Kev <klmitch@MIT.EDU> said:
>
> >> IIRC there's a slight bug in some of the newer kernels
> >> where the swap cache isn't being freed when you exit
> >> your program, but only later on when the system tries
> >> to reclaim memory...
>
> > I believe the problem lies in the fact that there is not enough
> > SysV shared memory available.
>
> It's nothing to do with SysV shared memory.
>
> The behaviour is there, but the only impact on the normal user will be
> that "free" lies a little.  No big deal: it just shows up as cache.  The
> effect is only a matter of when we recover the memory, not whether we
> recover it.

Thanks to the community for dealing with my problems.Before we go  on to
discuss this as bug or feature I emphasize
that this memory effect is really disastrous for me.
I hope that changing the kernel (as Rik told me) helps.
Any suggestion is very welcome.

Matthias


--

*****************************************************************
* Matthias Arnold
* Klinikum der Friedrich-Schiller-Universitaet
* Institut fuer Med. Statistik, Informatik und Dokumentation
* Jahnstrasse 3
* D-07743 Jena
*
* email:iia@imsid.uni-jena.de
* Tel. :+49-3641-934130
* FAX  :+49-3641-933200
******************************************************************




--------------015E290428FAC0B1C9653924--

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
