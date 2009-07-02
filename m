Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 628326B004F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 09:59:30 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <87cb4d6e-dbfe-497b-b651-9b912dc3fbc8@default>
Date: Thu, 2 Jul 2009 07:03:46 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] transcendent memory for Linux
In-Reply-To: <20090702063813.GA18157@elf.ucw.cz>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>, Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>, Keir Fraser <keir.fraser@eu.citrix.com>
List-ID: <linux-mm.kvack.org>

OK, OK, I give up.  I will ensure all code for shared pools
is removed from the next version of the patch.

Though for future reference, I am interested in what
problems it has other than "just" security (offlist
if you want).

> -----Original Message-----
> From: Pavel Machek [mailto:pavel@ucw.cz]
>=20
> > > Yeah, a shared namespace of accessible objects is an entirely=20
> > > new thing
> > > in the Xen universe.  I would also drop Xen support until=20
> > > there's a good
> > > security story about how they can be used.
> >=20
> > While I agree that the security is not bulletproof, I wonder
> > if this position might be a bit extreme.  Certainly, the NSA
> > should not turn on tmem in a cluster, but that doesn't mean that
> > nobody should be allowed to.  I really suspect that there are
>=20
> This has more problems than "just" security, and yes, security should
> be really solved at design time...
> =09=09=09=09=09=09=09=09
> =09=09=09Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
