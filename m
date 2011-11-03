Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 76E676B006E
	for <linux-mm@kvack.org>; Thu,  3 Nov 2011 06:30:22 -0400 (EDT)
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=windows-1252
From: Theodore Tso <tytso@MIT.EDU>
In-Reply-To: <2baa4c1a-1fe0-4395-a428-f30703e8c435@default>
Date: Thu, 3 Nov 2011 06:30:07 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <86F488BC-2F99-4397-9467-A52AE1511FE0@mit.edu>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default> <75efb251-7a5e-4aca-91e2-f85627090363@default> <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy> <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com> <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default> <20111031181651.GF3466@redhat.com> <1320142590.7701.64.camel@dabdike> <49255b17-02bb-4a4a-b85a-cd5a879beb98@default 1320221686.3091.40.camel@dabdike> <2baa4c1a-1fe0-4395-a428-f30703e8c435@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Theodore Tso <tytso@mit.edu>, James Bottomley <James.Bottomley@HansenPartnership.com>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>


On Nov 2, 2011, at 4:08 PM, Dan Magenheimer wrote:

> By "infinite" I am glibly describing any environment where the
> data centre administrator positively knows the maximum working
> set of every machine (physical or virtual) and can ensure in
> advance that the physical RAM always exceeds that maximum
> working set.  As you say, these machines need not be configured
> with a swap device as they, by definition, will never swap.
>=20
> The point of tmem is to use RAM more efficiently by taking
> advantage of all the unused RAM when the current working set
> size is less than the maximum working set size.  This is very
> common in many data centers too, especially virtualized.

That doesn't match with my experience, especially with "cloud" =
deployments, where in order to make the business plans work, the =
machines tend to be memory constrained, since you want to pack a large =
number of jobs/VM's onto a single machine, and high density memory is =
expensive and/or you are DIMM slot constrained.   Of course, if you are =
running multiple Java runtimes in each guest OS (i.e., an J2EE server, =
and another Java VM for management, and yet another Java VM for the =
backup manager, etc. --- really, I've seen cloud architectures that work =
that way), things get worst even faster=85.

-- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
