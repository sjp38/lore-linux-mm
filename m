Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0CA6B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 17:21:29 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c31ca108-9b68-40ba-936f-3ed2a56fd90b@default>
Date: Tue, 30 Jun 2009 14:21:35 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] transcendent memory for Linux
In-Reply-To: <4A493D19.4050908@goop.org>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

> From: Jeremy Fitzhardinge [mailto:jeremy@goop.org]
> On 06/29/09 14:57, Dan Magenheimer wrote:
> > Interesting question.  But, more than the 128-bit UUID must
> > be guessed... a valid 64-bit object id and a valid 32-bit
> > page index must also be guessed (though most instances of
> > the page index are small numbers so easy to guess).  Once
> > 192 bits are guessed though, yes, the pages could be viewed
> > and modified.  I suspect there are much more easily targeted
> > security holes in most data centers than guessing 192 (or
> > even 128) bits.
>=20
> If its possible to verify the uuid is valid before trying to find a
> valid oid+page, then its much easier (since you can concentrate on the
> uuid first).

No, the uuid can't be verified.  Tmem gives no indication
as to whether a newly-created pool is already in use (shared)
by another guest.  So without both the 128-bit uuid and an
already-in-use 64-bit object id and 32-bit page index, no data
is readable or writable by the attacker.

> You also have to consider the case of a domain which was once part of
> the ocfs cluster, but now is not - it may still know the uuid, but not
> be otherwise allowed to use the cluster.
> If the uuid is derived from something like the
> filesystem's uuid - which wouldn't normally be considered sensitive
> information - then its not like its a search of the full=20
> 128-bit space.=20
> And even if it were secret, uuids are not generally 128=20
> randomly chosen bits.

Hmmm... that is definitely a thornier problem.  I guess the
security angle definitely deserves more design.  But, again,
this affects only shared precache which is not intended
to part of the proposed initial tmem patchset, so this is a futures
issue.)

Thanks again for the feedback!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
