Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF6AE6B025F
	for <linux-mm@kvack.org>; Sun,  2 May 2010 11:06:47 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <47d6b5d9-beb5-4e49-9910-064d6f7b13e5@default>
Date: Sun, 2 May 2010 08:05:29 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD3377E.6010303@redhat.com>
 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>
 <ce808441-fae6-4a33-8335-f7702740097a@default> <20100428055538.GA1730@ucw.cz>
 <1272591924.23895.807.camel@nimitz> <4BDA8324.7090409@redhat.com>
 <084f72bf-21fd-4721-8844-9d10cccef316@default> <4BDB026E.1030605@redhat.com>
 <4BDB18CE.2090608@goop.org4BDB2069.4000507@redhat.com>
 <3a62a058-7976-48d7-acd2-8c6a8312f10f@default 20100502071059.GF1790@ucw.cz>
In-Reply-To: <20100502071059.GF1790@ucw.cz>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Avi Kivity <avi@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > So there are two users of frontswap for which the synchronous
> > interface makes sense.  I believe there may be more in the
> > future and you disagree but, as Jeremy said, "a general Linux
> > principle is not to overdesign interfaces for hypothetical users,
> > only for real needs."  We have demonstrated there is a need
> > with at least two users so the debate is only whether the
> > number of users is two or more than two.
> >
> > Frontswap is a very non-invasive patch and is very cleanly
> > layered so that if it is not in the presence of either of
> > the intended "users", it can be turned off in many different
> > ways with zero overhead (CONFIG'ed off) or extremely small overhead
> > (frontswap_ops is never set; or frontswap_ops is set but the
> > underlying hypervisor doesn't support it so frontswap_poolid
> > never gets set).
>=20
> Yet there are less invasive solutions available, like 'add trim
> operation to swap_ops'.

As Nitin pointed out much earlier in this thread:

"No: trim or discard is not useful"

I also think that trim does not do anything for the widely
varying dynamically changing size that frontswap provides.
=20
> So what needs to be said here is 'frontswap is XX times faster than
> swap_ops based solution on workload YY'.

Are you asking me to demonstrate that swap-to-hypervisor-RAM is
faster than swap-to-disk?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
