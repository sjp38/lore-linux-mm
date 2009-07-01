Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0549B6B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 19:03:16 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <79a405e4-3c4c-4194-aed4-a3832c6c5d6e@default>
Date: Wed, 1 Jul 2009 16:02:38 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] transcendent memory for Linux
In-Reply-To: <4A4A95D8.6020708@goop.org>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>, Keir Fraser <keir.fraser@eu.citrix.com>
List-ID: <linux-mm.kvack.org>

> From: Jeremy Fitzhardinge [mailto:jeremy@goop.org]
> On 06/30/09 14:21, Dan Magenheimer wrote:
> > No, the uuid can't be verified.  Tmem gives no indication
> > as to whether a newly-created pool is already in use (shared)
> > by another guest.  So without both the 128-bit uuid and an
> > already-in-use 64-bit object id and 32-bit page index, no data
> > is readable or writable by the attacker.
>=20
> You have to consider things like timing attacks as well (for=20
> example, a
> tmem hypercall might return faster if the uuid already exists).
>=20
> Besides, you can tell whether a uuid exists, by at least a couple of
> mechanisms (from a quick read of the source, so I might have=20
> overlooked something):

All of these still require a large number of guesses
across a 128-bit space of possible uuids, right?
It should be easy to implement "guess limits" in xen
that disable tmem use by a guest if it fails too many guesses.
I'm a bit more worried about:

> You also have to consider the case of a domain which was once part of
> the ocfs cluster, but now is not - it may still know the uuid, but not
> be otherwise allowed to use the cluster.

But on the other hand, the security model here can be that
if a trusted entity becomes untrusted, you have to change
the locks.

> Yeah, a shared namespace of accessible objects is an entirely=20
> new thing
> in the Xen universe.  I would also drop Xen support until=20
> there's a good
> security story about how they can be used.

While I agree that the security is not bulletproof, I wonder
if this position might be a bit extreme.  Certainly, the NSA
should not turn on tmem in a cluster, but that doesn't mean that
nobody should be allowed to.  I really suspect that there are
less costly / more rewarding attack vectors at several layers
in the hardware/software stack of most clusters.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
