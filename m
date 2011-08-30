Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 89CEC6B00EE
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 19:13:01 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <4599ff4c-5273-4605-9a61-d26a9a6484fe@default>
Date: Tue, 30 Aug 2011 14:51:39 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V8 4/4] mm: frontswap: config and doc files
References: <20110829164949.GA27238@ca-server1.us.oracle.com
 19213.1314737185@turing-police.cc.vt.edu>
In-Reply-To: <19213.1314737185@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: Valdis.Kletnieks@vt.edu [mailto:Valdis.Kletnieks@vt.edu]
> Subject: Re: [PATCH V8 4/4] mm: frontswap: config and doc files
>=20
> On Mon, 29 Aug 2011 09:49:49 PDT, Dan Magenheimer said:
>=20
> > --- linux/mm/Kconfig=092011-08-08 08:19:26.303686905 -0600
> > +++ frontswap/mm/Kconfig=092011-08-29 09:52:14.308745832 -0600
> > @@ -370,3 +370,20 @@ config CLEANCACHE
> >  =09  in a negligible performance hit.
> >
> >  =09  If unsure, say Y to enable cleancache
> > +
> > +config FRONTSWAP
> > +=09bool "Enable frontswap to cache swap pages if tmem is present"
> > +=09depends on SWAP
> > +=09default n
>=20
> > +
> > +=09  If unsure, say Y to enable frontswap.
>=20
> Am I the only guy who gets irked when the "default" doesn't match the
> "If unsure" suggestion?  :)  (and yes, I know we have guidelines for
> what the "default" should be...)

Hi Valdis --

Thanks for the review!

Count me as irked.  The default should be "y" because the
overhead is extremely tiny when not enabled at runtime by
a backend (though admittedly non-zero), but I got flamed by
Linus last time I tried that (for cleancache), so I'm not
going to try it for frontswap! :-)  The "if unsure" is the
best I can do for now to encourage distros to enable it.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
